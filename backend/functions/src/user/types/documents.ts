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
  avatarUrl: string;
  has2Fa: boolean;
  funds: number;
  createdAt: Timestamp;

  investments: string[];
}

export interface TwoFaDocument {
  enabled: boolean;
  secret: string;
  updatedAt: Timestamp;
}
