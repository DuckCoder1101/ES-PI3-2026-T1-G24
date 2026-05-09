/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { UserDocument } from "./documents";

export interface UserFullDTO extends UserDocument {
  uid: string;
}

export interface UserSignupDTO {
  name: string;
  email: string;
  cpf: string;
  phone: string;
}

export interface UpdateProfileDTO {
  name: string;
  phone: string;
}

export interface UserProfile {
  uid: string;
  email: string;
}
