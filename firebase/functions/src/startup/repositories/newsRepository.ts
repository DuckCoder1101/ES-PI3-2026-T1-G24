/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { database } from "../../shared/firebase";
import { NewsDocument } from "../types/documents";
import { NewsListDTO } from "../types/dtos";

const getNewsCollection = (startupId: string) =>
  database.collection("startups").doc(startupId).collection("news");

/*
 * Retorna as notícias de uma startup em ordem cronológica decrescente.
 */
export const findStartupNews = async (
  startupId: string,
): Promise<NewsListDTO[]> => {
  const snapshot = await getNewsCollection(startupId)
    .orderBy("createdAt", "desc")
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data() as NewsDocument;
    return {
      id: doc.id,
      ...data,
    };
  });
};
