import { HttpsError, onCall } from "firebase-functions/https";
import { saveQuestion } from "../../repositories/questionsRepository";
import { getUserProfile } from "../../../shared/auth";

export const registerQuestion = onCall(async (req) => {
  const { startupId, content, visibility } = req.data;
  const { uid } = getUserProfile(req);

  if (!startupId || !content) {
    throw new HttpsError("invalid-argument", "Campos obrigatórios ausentes.");
  }

  await saveQuestion(startupId, {
    authorUId: uid,
    content: content,
    visibility: visibility,
  });

  return { success: true };
});
