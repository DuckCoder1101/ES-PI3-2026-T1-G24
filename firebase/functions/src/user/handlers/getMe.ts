/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getById } from "../repositories/usersRepository";
import { getAuthenticatedUser } from "../../shared/auth";
import { logger } from "firebase-functions";

/*
 * Retorna os dados completos do usuário
 */
export const getMe = onCall(async (request) => {
  const { uid } = getAuthenticatedUser(request);
  const user = await getById(uid);

  logger.log("Buscando usuário por ID: " + uid);

  if (!user) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  return user;
});
