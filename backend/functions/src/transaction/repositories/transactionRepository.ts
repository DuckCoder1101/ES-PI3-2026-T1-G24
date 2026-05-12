/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { database } from "../../shared/firebase";
import { TransactionDocument } from "../types/documents";

const transactionsCollection = database.collection("transactions");

/*
 * Retorna todas as transações (de tokens ou de fundos) associadas a um usuário.
 * Utiliza o campo userUIds para encontrar transações onde o usuário é parte envolvida.
 */
export const findUserTransactions = async (
  userId: string,
): Promise<TransactionDocument[]> => {
  const snapshot = await transactionsCollection
    .where("userUIds", "array-contains", userId)
    .orderBy("createdAt", "desc")
    .get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as TransactionDocument[];
};
