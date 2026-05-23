/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { deleteQuestionById } from "../../repositories/qaRepository";
import { getAuthenticatedUser } from "../../../shared/auth";

export const deleteQuestion = onCall(async (req) => {
  const { startupId, questionId } = req.data;
  const { uid } = getAuthenticatedUser(req);

  await deleteQuestionById(startupId, questionId, uid);

  return {
    success: true,
  };
});
