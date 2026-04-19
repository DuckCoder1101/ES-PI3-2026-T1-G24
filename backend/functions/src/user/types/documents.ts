/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";

export interface UserDocument {
  uid: string;
  name: string;
  email: string;
  cpf: string;
  phone: string;
  createdAt: Timestamp;
}

export interface twoFaDocument {
  uid: string;
  enabled: boolean;
  secret: string;
  updatedAt: Timestamp;
}
