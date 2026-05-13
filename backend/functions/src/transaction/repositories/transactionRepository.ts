/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import admin from "firebase-admin";
import { database } from "../../shared/firebase";
import { TransactionDocument } from "../types/documents";
import { StartupResumeDTO } from "../../startup/types/dtos";
import {
  InvestmentTransactionListDTO,
  TransactionListDTO,
} from "../types/dtos";
import { chunkArray } from "../../shared/dataArray";

const transactionsCollection = database.collection("transactions");
const startupsCollection = database.collection("startups");

/*
 * Retorna todas as transações (de tokens ou de fundos) associadas a um usuário.
 * Utiliza o campo userUIds para encontrar transações onde o usuário é parte envolvida.
 */

export const getStartupResumeMap = async (
  ids: string[],
): Promise<Record<string, StartupResumeDTO>> => {
  const uniqueIds = [...new Set(ids)];

  if (uniqueIds.length === 0) {
    return {};
  }

  const chunks = chunkArray(uniqueIds, 10);

  const snapshots = await Promise.all(
    chunks.map((chunk) =>
      startupsCollection
        .where(admin.firestore.FieldPath.documentId(), "in", chunk)
        .select("name")
        .get(),
    ),
  );

  const startups: Record<string, StartupResumeDTO> = {};

  snapshots.forEach((snapshot) => {
    snapshot.docs.forEach((doc) => {
      startups[doc.id] = {
        ...(doc.data() as StartupResumeDTO),
        id: doc.id,
      };
    });
  });

  return startups;
};

export const findUserTransactions = async (
  userId: string,
): Promise<TransactionListDTO[]> => {
  const snapshot = await transactionsCollection
    .where("userUIds", "array-contains", userId)
    .orderBy("createdAt", "desc")
    .get();

  const transactions = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as TransactionDocument[];

  const startupIds = [
    ...new Set(
      transactions.flatMap((t) =>
        t.type === "investment" && t.startupId ? [t.startupId] : [],
      ),
    ),
  ];

  const startups = await getStartupResumeMap(startupIds);

  return transactions.map((t) => {
    if (t.type === "investment") {
      return {
        ...t,
        startup: startups[t.startupId] ?? {
          id: t.startupId,
          name: "Startup removida",
        },
      } satisfies InvestmentTransactionListDTO;
    }

    return t;
  });
};
