import { Timestamp } from "firebase-admin/firestore";

export type TransactionType = "investment" | "funds";

export interface TransactionDocument {
  userUId: string;
  startupId: string;
  type: TransactionType;
  amount: number;
  tokensPurchased?: number;
  tokenPriceCents?: number;
  createdAt: Timestamp;
}
