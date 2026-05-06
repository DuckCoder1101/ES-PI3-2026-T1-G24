/**
 * Autor: Cristian Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { QuestionDocument } from "../types/documents";
import { QuestionListDTO, QuestionRegisterDTO } from "../types/dtos";

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

export const getQuestionsByVisibility = async (
  startupId: string,
  visibility: string,
  currentUserId: string,
): Promise<QuestionListDTO[]> => {
  // REMOVIDO: .orderBy("createdAt", "desc") para evitar a necessidade de índice composto
  const snapshot = await getQuestionsCollection(startupId)
    .where("visibility", "==", visibility)
    .get();

  const questions = snapshot.docs.map((doc) => {
    const data = doc.data() as QuestionDocument;
    return {
      ...data,
      isAuthor: data.authorUId === currentUserId,
    };
  });

  // ORDENAÇÃO MANUAL: Ordenamos na memória antes de retornar ao Flutter
  return questions.sort((a, b) => {
    const timeA = a.createdAt?.toMillis() || 0;
    const timeB = b.createdAt?.toMillis() || 0;
    return timeB - timeA; // Descendente (mais recentes primeiro)
  });
};

export const deleteQuestionById = async (
  startupId: string,
  questionId: string,
  userId: string,
): Promise<void> => {
  const docRef = getQuestionsCollection(startupId).doc(questionId);
  const doc = await docRef.get();

  if (!doc.exists) return;

  const data = doc.data() as QuestionDocument;

  // Verificação de segurança: apenas o autor pode deletar
  if (data.authorUId !== userId) {
    throw new Error("Permission denied: You are not the author.");
  }

  await docRef.delete();
};
