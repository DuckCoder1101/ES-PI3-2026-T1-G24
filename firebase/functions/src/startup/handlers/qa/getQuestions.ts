/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getStartupQuestions } from "../../repositories/qaRepository";
import { getUserProfile } from "../../../shared/auth";
import { database } from "../../../shared/firebase";

/*
 * Retorna as perguntas de uma startup conforme a visibilidade solicitada.
 * Perguntas privadas são exclusivas para investidores da startup.
 */
export const getQuestions = onCall(async (req) => {
  const { startupId, visibility } = req.data;
  const { uid } = getUserProfile(req);

  if (!startupId || !visibility) {
    throw new HttpsError(
      "invalid-argument",
      "Startup ID ou Visibilidade ausentes.",
    );
  }

  // Perguntas privadas: apenas investidores têm acesso
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
        "Apenas investidores desta startup podem acessar perguntas privadas.",
      );
    }
  }

  const questions = await getStartupQuestions(startupId, visibility, uid);
  return { questions };
});
