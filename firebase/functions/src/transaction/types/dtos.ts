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
