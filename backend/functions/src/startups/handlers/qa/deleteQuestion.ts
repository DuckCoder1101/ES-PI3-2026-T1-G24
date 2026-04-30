import { HttpsError, onCall } from "firebase-functions/https";
import { deleteQuestionById } from "../../repositories/questionsRepository";
import { getUserProfile } from "../../../shared/auth";

export const deleteQuestion = onCall(async (req) => {
  const { startupId, questionId } = req.data;
  const { uid } = getUserProfile(req);

  try {
    await deleteQuestionById(startupId, questionId, uid);

    return {
      success: true,
    };
  } catch {
    throw new HttpsError(
      "permission-denied",
      "Permission denied: You are not the author.",
    );
  }
});
