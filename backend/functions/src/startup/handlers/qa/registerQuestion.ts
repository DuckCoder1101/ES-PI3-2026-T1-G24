/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { saveQuestion } from "../../repositories/qaRepository";
import { getUserProfile } from "../../../shared/auth";
import { database } from "../../../shared/firebase";

/*
 * Registra uma nova pergunta em uma startup.
 * Perguntas privadas só podem ser enviadas por investidores da startup.
 */
export const registerQuestion = onCall(async (req) => {
  const { startupId, content, visibility } = req.data;
  const { uid } = getUserProfile(req);

  if (!startupId || !content) {
    throw new HttpsError("invalid-argument", "Campos obrigatórios ausentes.");
  }

  // Perguntas privadas: apenas investidores podem enviar
  if (visibility === "privada") {
    const investmentDoc = await database
      .collection("investments")
      .doc(uid)
      .collection("startups")
      .doc(startupId)
      .get();

    if (!investmentDoc.exists) {
      throw new HttpsError(
        "permission-denied",
        "Apenas investidores desta startup podem enviar perguntas privadas.",
      );
    }
  }

  await saveQuestion(startupId, {
    authorUId: uid,
    content: content,
    visibility: visibility,
  });

  return { success: true };
});
