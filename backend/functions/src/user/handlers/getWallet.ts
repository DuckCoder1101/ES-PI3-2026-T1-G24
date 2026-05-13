/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getWallet } from "../repositories/userRepository";
import { getUserProfile } from "../../shared/auth";
import { logger } from "firebase-functions";

/*
 * Retorna a carteira do usuário autenticado
 */
export const getWalletHandler = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const wallet = await getWallet(uid);

  logger.log("Buscando carteira do usuário: " + uid);

  return wallet;
});