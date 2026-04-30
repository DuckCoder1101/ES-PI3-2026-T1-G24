/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";

export interface UserSignupDTO {
  name: string;
  email: string;
  cpf: string;
  phone: string;
}

export interface UserProfile {
  uid: string;
  email: string;
}

export interface UserFullDTO {
  uid: string;
  avatarUrl: string;
  name: string;
  email: string;
  cpf: string;
  phone: string;
  createdAt: Timestamp;
  has2Fa: boolean;
}
