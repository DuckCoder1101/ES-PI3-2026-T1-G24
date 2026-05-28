/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { database } from "../../shared/firebase";
import { findStartupsResumes } from "../../startup/repositories/startupsRepository";
import { TransactionDocument } from "../types/documents";
import { StartupTransactionListDTO, TransactionListDTO } from "../types/dtos";

const transactionsCollection = database.collection("transactions");

/*
 * Retorna todas as transações do usuário em ordem cronológica decrescente.
 * Para transações de investimento, adiciona o resumo da startup.
 */
export const findUserTransactions = async (
  userId: string,
): Promise<TransactionListDTO[]> => {
  const [snapshot, startups] = await Promise.all([
    transactionsCollection
      .where("userUIds", "array-contains", userId)
      .orderBy("createdAt", "desc")
      .get(),
    findStartupsResumes(userId),
  ]);

  const transactions = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as TransactionDocument[];

  return transactions.map((t) => {
    if (t.type != "funds") {
      return {
        ...t,
        startup: startups.find((s) => s.id == t.startupId) ?? {
          id: t.startupId,
          name: "Startup removida",
          currentTokenPriceCents: 0,
          initialTokenPriceCents: 0,
          isInvestor: false,
          stage: undefined,
        },
      } satisfies StartupTransactionListDTO;
    }

    return t;
  });
};
