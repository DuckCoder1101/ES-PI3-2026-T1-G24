/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { saveQuestion } from "../../repositories/qaRepository";
import { getAuthenticatedUser } from "../../../shared/auth";
import { isInvestor } from "../../../user/repositories/usersRepository";
import { logger } from "firebase-functions/v2";
import { QuestionVisibilities } from "../../constants/questionVisibility";

/*
 * Registra uma nova pergunta em uma startup.
 */
export const registerQuestion = onCall(async (req) => {
  const { startupId, content, visibility } = req.data;
  const { uid } = getAuthenticatedUser(req);

  if (!startupId || !content) {
    throw new HttpsError("invalid-argument", "Campos obrigatórios ausentes.");
  }

  if (!QuestionVisibilities.includes(visibility)) {
    throw new HttpsError(
      "invalid-argument",
      "Visibilidade da questão inválida!",
    );
  }

  logger.log(`[registerQuestion] uid=${uid} startupId=${startupId} visibility=${visibility}`);
  const investorCheck = await isInvestor(uid, startupId);

  if (visibility == "privada" && !investorCheck) {
    throw new HttpsError(
      "permission-denied",
      "Apenas investidores podem fazer perguntas privadas!",
    );
  }

  await saveQuestion(startupId, {
    authorUId: uid,
    content: content,
    visibility: visibility,
  });

  return {
    success: true,
  };
});
