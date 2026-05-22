/**
 * Autor: Cristian Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { QuestionDocument } from "../types/documents";
import { QuestionListDTO, QuestionRegisterDTO } from "../types/dtos";
import { HttpsError } from "firebase-functions/https";

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
  visibility: string,
  currentUserId: string,
): Promise<QuestionListDTO[]> => {
  const snapshot = await getQuestionsCollection(startupId)
    .where("visibility", "==", visibility)
    .get();

  const questions = snapshot.docs.map((doc) => {
    const data = doc.data() as QuestionDocument;
    return {
      id: doc.id,
      isAuthor: data.authorUId === currentUserId,
      ...data,
    };
  });

  // Ordena as questões por mais recentes -> não era possível usar o .sort()
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

  // Verificação de segurança: apenas o autor pode deletar
  if (data.authorUId !== userId) {
    throw new HttpsError(
      "permission-denied",
      "Você não pode excluir uma pergunta feita por outro usuário!",
    );
  }

  await docRef.delete();
};
