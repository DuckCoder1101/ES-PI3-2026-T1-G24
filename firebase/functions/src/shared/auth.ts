/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { CallableRequest, HttpsError } from "firebase-functions/https";
import { UserProfile } from "../user/types/dtos";

export const getAuthenticatedUser = (req: CallableRequest): UserProfile => {
  if (!req.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Autenticação necessária para acessar esse conteúdo!",
    );
  }

  if (!req.auth.token.email) {
    throw new HttpsError("unauthenticated", "Email não encontrado no token.");
  }

  return {
    uid: req.auth.uid,
    email: req.auth.token.email,
  };
};
