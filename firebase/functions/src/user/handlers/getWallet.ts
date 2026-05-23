/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getWallet } from "../repositories/usersRepository";
import { getAuthenticatedUser } from "../../shared/auth";
import { logger } from "firebase-functions";

/*
 * Retorna a carteira do usuário autenticado
 */
export const getWalletHandler = onCall(async (request) => {
  const { uid } = getAuthenticatedUser(request);
  const wallet = await getWallet(uid);

  logger.log("Buscando carteira do usuário: " + uid);

  return wallet;
});
