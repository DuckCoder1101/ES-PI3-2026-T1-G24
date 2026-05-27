/**
 * Autor: Cristian Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { QuestionDocument } from "../types/documents";
import { QuestionListDTO, QuestionRegisterDTO } from "../types/dtos";
import { HttpsError } from "firebase-functions/https";
import { QuestionVisibility } from "../constants/questionVisibility";

// Função auxiliar para obter a referência da sub-coleção de questões
const getQuestionsCollection = (startupId: string) =>
  database.collection("startups").doc(startupId).collection("questions");

export const saveQuestion = async (
  startupId: string,
  questionData: QuestionRegisterDTO,
): Promise<void> => {
  await getQuestionsCollection(startupId).add({
    ...questionData,
    answers: [],
    createdAt: FieldValue.serverTimestamp(),
  });
};

/*
 * Procura todas as questões que o usuário tem acesso, em uma startup
 */
export const getStartupQuestions = async (
  startupId: string,
  visibility: QuestionVisibility,
  uid: string,
): Promise<QuestionListDTO[]> => {
  let query = getQuestionsCollection(startupId).where(
    "visibility",
    "==",
    visibility,
  );

  if (visibility == "privada") {
    query = query.where("authorUId", "==", uid);
  }

  const snapshot = await query.get();
  const questions = snapshot!.docs.map((doc) => {
    const data = doc.data() as QuestionDocument;
    return {
      id: doc.id,
      isAuthor: data.authorUId === uid,
      ...data,
    };
  });

  return questions.sort((a, b) => {
    const timeA = a.createdAt?.toMillis() || 0;
    const timeB = b.createdAt?.toMillis() || 0;
    return timeB - timeA;
  });
};

/*
 * Deleta uma questão da
 */
export const deleteQuestionById = async (
  startupId: string,
  questionId: string,
  userId: string,
): Promise<void> => {
  const docRef = getQuestionsCollection(startupId).doc(questionId);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Pergunta não encontrada!");
  }

  const data = doc.data() as QuestionDocument;

  if (data.authorUId !== userId) {
    throw new HttpsError(
      "permission-denied",
      "Você não pode excluir uma pergunta feita por outro usuário!",
    );
  }

  await docRef.delete();
};
