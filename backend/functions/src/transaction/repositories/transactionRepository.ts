import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import {
  SearchTransactionsFilter,
  TransactionRegisterDTO,
} from "../types/dtos";
import { TransactionDocument } from "../types/documents";

const transactionsCollection = database.collection("transactions");

export const saveTransaction = async (transaction: TransactionRegisterDTO) => {
  await transactionsCollection.add({
    ...transaction,
    createdAt: FieldValue.serverTimestamp(),
  });
};

export const findUserTransactions = async (
  userId: string,
  filter: SearchTransactionsFilter,
) => {
  const snapshot = await transactionsCollection
    .where("userId", "==", userId)
    .where("type", "==", filter)
    .orderBy("createdAt")
    .get();

  return snapshot.docs.map((t) => t.data()) as TransactionDocument[];
};
