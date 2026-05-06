import { HttpsError, onCall } from "firebase-functions/https";
import { getQuestionsByVisibility } from "../../repositories/questionsRepository";
import { getUserProfile } from "../../../shared/auth";

export const listQuestions = onCall(async (req) => {
  const { startupId, visibility } = req.data;
  const { uid } = getUserProfile(req);

  if (!startupId || !visibility) {
    throw new HttpsError(
      "invalid-argument",
      "Startup ID ou Visibilidade ausentes.",
    );
  }

  const questions = await getQuestionsByVisibility(startupId, visibility, uid);

  return { questions };
});
