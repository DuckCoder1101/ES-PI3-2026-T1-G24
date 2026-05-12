/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";

export interface UserDocument {
  cpf: string;
  name: string;
  email: string;
  phone: string;
  createdAt: Timestamp;
}

export interface WalletDocument {
  fundsCents: number;
  lockedFundsCents: number;
  updatedAt: Timestamp;
}

export interface InvestmentDocument {
  startupId: string;
  tokenAmount: number;
  lockedTokenAmount: number;
  updatedAt: Timestamp;
}
