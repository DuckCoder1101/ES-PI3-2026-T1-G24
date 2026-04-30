/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { CallableRequest, HttpsError } from "firebase-functions/https";
import { UserProfile } from "../user/types/dtos";

export const getUserProfile = (req: CallableRequest): UserProfile => {
  if (!req.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Autenticação necessária para acessar esse conteúdo!",
    );
  }

  return {
    uid: req.auth.uid,
    email: req.auth.token.email!,
  };
};
