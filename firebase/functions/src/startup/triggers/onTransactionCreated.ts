/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

import { TransactionDocument } from "../../transaction/types/documents";
import {
  getStartupTokenInfo,
  updateTokenPrice,
  updateCurrentPriceOnly,
} from "../repositories/startupsRepository";

/*
 * Trigger disparado toda vez que uma nova transação é criada.
 */
export const onTransactionCreated = onDocumentCreated(
  "transactions/{transactionId}",
  async (event) => {
    const transactionId = event.params.transactionId;
    const transaction = event.data?.data() as TransactionDocument | undefined;

    if (!transaction) {
      logger.warn("Transação nula, ignorando trigger.", { transactionId });
      return;
    }

    if (transaction.type === "funds") {
      logger.log(`Transação de fundos ignorada: ${transactionId}`);
      return;
    }

    const startupId = (transaction as { startupId?: string }).startupId;

    if (!startupId) {
      logger.warn("Transação sem startupId, ignorando.", {
        transactionId,
        type: transaction.type,
      });
      return;
    }

    // Compra direta da startup
    if (transaction.type === "investment") {
      logger.log(`[investment] Recalculando preço para startup: ${startupId}`);

      const {
        totalTokensAvailable,
        totalTokensIssued,
        initialTokenPriceCents,
      } = await getStartupTokenInfo(startupId);

      if (totalTokensIssued === 0) {
        logger.warn("Startup sem tokens emitidos, ignorando recálculo.", {
          startupId,
        });
        return;
      }

      const tokensSold = totalTokensIssued - totalTokensAvailable;
      const occupancyRate = tokensSold / totalTokensIssued;

      /*
       * Fórmula linear ancorada no preço de lançamento:
       *
       *   preço = preçoInicial × (1 + occupancyRate × fatorDeValorização)
       *
       * Com fatorDeValorização = 1.5:
       *   - 0% ocupado  → preçoInicial × 1.0  (sem valorização)
       *   - 50% ocupado → preçoInicial × 1.75
       *   - 100% ocupado → preçoInicial × 2.5  (teto: 2.5× o preço inicial)
       */
      const APPRECIATION_FACTOR = 1.5;
      const newPriceCents = Math.round(
        initialTokenPriceCents * (1 + occupancyRate * APPRECIATION_FACTOR),
      );

      updateTokenPrice(startupId, newPriceCents, occupancyRate, transactionId);

      logger.log(
        `[investment] Preço atualizado: ${newPriceCents}¢ ` +
          `(ocupação: ${(occupancyRate * 100).toFixed(1)}%, ` +
          `âncora: ${initialTokenPriceCents}¢)`,
      );
      return;
    }

    // Trade
    if (transaction.type === "trade") {
      const tradeTx = transaction as { tokenPriceCents?: number };

      if (!tradeTx.tokenPriceCents) {
        logger.warn("[trade] Transação sem tokenPriceCents, ignorando.", {
          transactionId,
        });
        return;
      }

      updateCurrentPriceOnly(startupId, tradeTx.tokenPriceCents);

      logger.log(
        `[trade] Preço de referência atualizado: ${tradeTx.tokenPriceCents}¢ ` +
          `(sem ponto no histórico — aguarda snapshot diário)`,
      );
    }
  },
);
