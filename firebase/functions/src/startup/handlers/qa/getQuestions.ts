/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getStartupQuestions } from "../../repositories/qaRepository";
import { getAuthenticatedUser } from "../../../shared/auth";
import { logger } from "firebase-functions/v2";
import { isInvestor } from "../../../user/repositories/usersRepository";

/*
 * Retorna as perguntas de uma startup conforme a visibilidade solicitada.
 */
export const getQuestions = onCall(async (req) => {
  const { startupId, visibility } = req.data;
  const { uid } = getAuthenticatedUser(req);

  if (!startupId || !visibility) {
    throw new HttpsError(
      "invalid-argument",
      "Startup ID ou Visibilidade ausentes.",
    );
  }

  logger.log(`[getQuestions] uid=${uid} startupId=${startupId} visibility=${visibility}`);
  const investorCheck = await isInvestor(uid, startupId);

  if (visibility == "privada" && !investorCheck) {
    throw new HttpsError(
      "permission-denied",
      "Apenas investidores podem ler perguntas privadas!",
    );
  }

  const questions = await getStartupQuestions(startupId, visibility, uid);
  return { questions };
});
