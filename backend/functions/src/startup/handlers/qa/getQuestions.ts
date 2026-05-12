/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getStartupQuestions } from "../../repositories/questionsRepository";
import { getUserProfile } from "../../../shared/auth";

export const getQuestions = onCall(async (req) => {
  const { startupId, visibility } = req.data;
  const { uid } = getUserProfile(req);

  if (!startupId || !visibility) {
    throw new HttpsError(
      "invalid-argument",
      "Startup ID ou Visibilidade ausentes.",
    );
  }

  const questions = await getStartupQuestions(startupId, visibility, uid);
  return { questions };
});