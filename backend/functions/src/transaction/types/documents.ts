import { Timestamp } from "firebase-admin/firestore";

export type TransactionType = "investment" | "funds" | "trade";

export interface BaseTransaction {
  type: TransactionType;
  amountCents: number;
  createdAt: Timestamp;
  userUIds: string[];
}

export interface InvestmentTransaction extends BaseTransaction {
  type: "investment";
  investorUId: string;
  startupId: string;
  tokensPurchased: number;
  tokenPriceCents: number;
}

export interface TradeTransaction extends BaseTransaction {
  type: "trade";
  purchaserUId: string;
  sellerUId: string;
  startupId: string;
  tokensPurchased: number;
  tokenPriceCents: number;
}

export interface FundsTransaction extends BaseTransaction {
  type: "funds";
  authorUId: string;
}

export type TransactionDocument =
  | InvestmentTransaction
  | TradeTransaction
  | FundsTransaction;
