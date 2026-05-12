/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";

export type TransactionType = "investment" | "funds" | "trade";

export interface BaseTransaction {
  id?: string;
  type: TransactionType;
  amountCents: number;
  createdAt: Timestamp;
  userUIds: string[];
}

/*
 * Transação de compra direta de tokens de uma startup (página da startup)
 */
export interface InvestmentTransaction extends BaseTransaction {
  type: "investment";
  investorUId: string;
  startupId: string;
  tokensPurchased: number;
  tokenPriceCents: number;
}

/*
 * Transação de compra/venda de tokens entre usuários via balcão
 */
export interface TradeTransaction extends BaseTransaction {
  type: "trade";
  purchaserUId: string;
  sellerUId: string;
  startupId: string;
  tokensPurchased: number;
  tokenPriceCents: number;
}

/*
 * Transação de adição de fundos fictícios à carteira
 */
export interface FundsTransaction extends BaseTransaction {
  type: "funds";
  authorUId: string;
}

export type TransactionDocument =
  | InvestmentTransaction
  | TradeTransaction
  | FundsTransaction;
