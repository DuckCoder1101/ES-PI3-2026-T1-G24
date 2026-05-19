/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { database } from "../../shared/firebase";
import { TransactionDocument } from "../../transaction/types/documents";
import {
  getStartupInTransaction,
  updateTokenPriceInTransaction,
} from "../repositories/startupsRepository";

/*
 * Trigger disparado automaticamente toda vez que uma nova transação é criada.
 * Recalcula o preço do token da startup envolvida com base na taxa de ocupação
 * (tokens vendidos / tokens emitidos) e registra o novo preço no histórico.
 */
export const onTransactionCreated = onDocumentCreated(
  "transactions/{transactionId}",
  async (event) => {
    const transactionId = event.params.transactionId;
    const transaction = event.data?.data() as TransactionDocument;

    if (!transaction?.id || transaction.type == "funds") {
      return;
    }

    await database.runTransaction(async (tx) => {
      const { data: startup } = await getStartupInTransaction(
        tx,
        transaction.startupId,
      );

      // Preço sobe ou cai conforme a proporção de tokens vendidos.
      // Abaixo de 30% de ocupação o preço cai; acima, sobe — máximo de +35% com 100% vendido.
      // fatorDemanda = (tokensSoldidos/totalEmitidos - 0.3) × 0.5

      const tokensSold =
        startup.totalTokensIssued - startup.totalTokensAvailable;

      const taxaOcupacao = tokensSold / startup.totalTokensIssued;
      const fatorDemanda = (taxaOcupacao - 0.3) * 0.5;

      const newPriceCents = Math.round(
        startup.currentTokenPriceCents * (1 + fatorDemanda),
      );

      updateTokenPriceInTransaction(
        tx,
        transaction.startupId,
        newPriceCents,
        taxaOcupacao,
        transactionId,
      );
    });
  },
);
