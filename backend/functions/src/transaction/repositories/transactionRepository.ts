import { database } from "../../shared/firebase";
import { TransactionDocument } from "../types/documents";

const transactionsCollection = database.collection("transactions");

export const findUserTransactions = async (userId: string) => {
  const snapshot = await transactionsCollection
    .where("userUIds", "array-contains", userId)
    .orderBy("createdAt")
    .get();

  return snapshot.docs.map((t) => t.data()) as TransactionDocument[];
};
