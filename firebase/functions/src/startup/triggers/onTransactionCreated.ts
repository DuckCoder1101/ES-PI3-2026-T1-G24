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
 * Trigger disparado toda vez que uma nova transação é criada.
 * Recalcula o preço do token da startup com base na taxa de ocupação
 * (tokens vendidos / tokens emitidos) e registra no histórico.
 * Transações do tipo "funds" são ignoradas pois não envolvem tokens.
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

    // Transações de depósito de fundos não afetam o preço dos tokens
    if (transaction.type === "funds") {
      logger.log(`Transação de fundos ignorada: ${transactionId}`);
      return;
    }

    const startupId = (transaction as { startupId?: string }).startupId;

    if (!startupId) {
      logger.warn("Transação sem startupId, ignorando.", { transactionId, type: transaction.type });
      return;
    }

    logger.log(`Recalculando preço do token para startup: ${startupId}`);

    // SYSTEM_UID: trigger de sistema não pertence a nenhum usuário.
    // getFullStartup precisa de uid apenas para calcular isInvestor,
    // que não é relevante aqui — passamos string vazia.
    const startup = await getFullStartup(startupId, "");

    if (startup.totalTokensIssued === 0) {
      logger.warn("Startup sem tokens emitidos, ignorando recálculo.", { startupId });
      return;
    }

    const tokensSold = startup.totalTokensIssued - startup.totalTokensAvailable;
    const occupancyRate = tokensSold / startup.totalTokensIssued;
    const demandFactor = (occupancyRate - 0.3) * 0.5;

    const newPriceCents = Math.round(
      startup.currentTokenPriceCents * (1 + demandFactor),
    );

    updateTokenPrice(startupId, newPriceCents, occupancyRate, transactionId);

    logger.log(`Novo preço do token: ${newPriceCents} centavos (ocupação: ${(occupancyRate * 100).toFixed(1)}%)`);
  },
);
