/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { StartupResumeDTO } from "../../startup/types/dtos";
import {
  BaseTransaction,
  FundsTransaction,
  TradeTransaction,
} from "./documents";

export interface StartupTransactionListDTO extends BaseTransaction {
  type: "investment" | "trade";
  investorUId?: string;
  startup: StartupResumeDTO;
  tokensPurchased: number;
  tokenPriceCents: number;
}

export type TransactionListDTO =
  | StartupTransactionListDTO
  | TradeTransaction
  | FundsTransaction;
