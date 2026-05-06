import { TransactionDocument, TransactionType } from "./documents";

export type TransactionRegisterDTO = Omit<TransactionDocument, "createdAt">;
export type SearchTransactionsFilter = TransactionType | "all";
