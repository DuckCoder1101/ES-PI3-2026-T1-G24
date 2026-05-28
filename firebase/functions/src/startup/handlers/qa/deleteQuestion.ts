/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { deleteQuestionById } from "../../repositories/qaRepository";
import { logger } from "firebase-functions/v2";
import { getAuthenticatedUser } from "../../../shared/auth";

export const deleteQuestion = onCall(async (req) => {
  const { startupId, questionId } = req.data;
  const { uid } = getAuthenticatedUser(req);

  logger.log(`[deleteQuestion] uid=${uid} startupId=${startupId} questionId=${questionId}`);
  await deleteQuestionById(startupId, questionId, uid);

  return {
    success: true,
  };
});
