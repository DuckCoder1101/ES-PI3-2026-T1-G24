/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

import { TransactionDocument } from "../../transaction/types/documents";
import {
  getFullStartup,
  updateTokenPrice,
} from "../repositories/startupsRepository";

/*
 * Trigger disparado automaticamente toda vez que uma nova transação é criada.
 * Recalcula o preço do token da startup envolvida com base na taxa de ocupação
 * (tokens vendidos / tokens emitidos) e registra o novo preço no histórico.
 */
export const onTransactionCreated = onDocumentCreated(
  "transactions/{transactionId}",
  async (event) => {
    logger.info("EVENT:");
    logger.info(JSON.stringify(event));

    logger.info("DATA:");
    logger.info(JSON.stringify(event.data));

    const transactionId = event.params.transactionId;
    const transaction = event.data?.data() as TransactionDocument;

    logger.info("TRANSACTION:");
    logger.info(JSON.stringify(transaction));

    logger.log("Atualizando valorização: " + transaction.id);

    if (!transaction) {
      logger.log("Transação inválida para histórico: nula.");
      return;
    }

    if (transaction?.id || transaction.type == "funds") {
      logger.log(
        `Transação inválida para histórico: ${transaction.id} - ${transaction.type}`,
      );
      return;
    }

    const startup = await getFullStartup(transaction.startupId);

    const tokensSold = startup.totalTokensIssued - startup.totalTokensAvailable;
    const occupancyRate = tokensSold / startup.totalTokensIssued;
    const fatorDemanda = (occupancyRate - 0.3) * 0.5;

    const newPriceCents = Math.round(
      startup.currentTokenPriceCents * (1 + fatorDemanda),
    );

    updateTokenPrice(
      transaction.startupId,
      newPriceCents,
      occupancyRate,
      transactionId,
    );
  },
);
