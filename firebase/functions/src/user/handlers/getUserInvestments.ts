/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { logger } from "firebase-functions/v2";
import { getInvestments } from "../repositories/usersRepository";

/*
 * Retorna todos os investimentos do usuário.
 */
export const getUserInvestments = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  logger.log(`[getUserInvestments] uid=${uid}`);
  const investments = await getInvestments(uid);

  return { investments };
});
