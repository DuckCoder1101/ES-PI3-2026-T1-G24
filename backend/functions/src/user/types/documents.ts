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
  funds: number;
  createdAt: Timestamp;
  investments: string[];
}
