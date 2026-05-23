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

export interface InvestmentTransactionListDTO extends BaseTransaction {
  type: "investment";
  investorUId: string;
  startup: StartupResumeDTO;
  tokensPurchased: number;
  tokenPriceCents: number;
}

export type TransactionListDTO =
  | InvestmentTransactionListDTO
  | TradeTransaction
  | FundsTransaction;
