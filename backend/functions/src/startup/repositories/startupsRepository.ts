/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError } from "firebase-functions/https";
import { database } from "../../shared/firebase";
import { StartupDocument } from "../types/documents";

import {
  StartupDetailsDTO,
  StartupListItemDTO,
  StartupStageFilter,
} from "../types/dtos";

const startupsCollection = database.collection("startups");

/*
 * Busca as startups no banco de dados seguindo um offset, um limite e um filtro
 */
export const searchStartups = async (
  offset: number,
  limit: number,
  filter: StartupStageFilter,
  name: string | null,
): Promise<StartupListItemDTO[]> => {
  let query =
    filter === "all"
      ? startupsCollection
      : startupsCollection.where("stage", "==", filter);

  // Aplica filtro de nome apenas se existir
  if (name && name.trim().length > 0) {
    query = query
      .where("name", ">=", name)
      .where("name", "<=", name + "\uf8ff");
  }

  const snapshot = await query.offset(offset).limit(limit).get();

  return snapshot.docs.map((doc) => {
    const startup = doc.data() as StartupDocument;

    return {
      id: doc.id,
      name: startup.name,
      stage: startup.stage,
      shortDescription: startup.shortDescription,
      capitalRaisedCents: startup.capitalRaisedCents,
      totalTokensIssued: startup.totalTokensIssued,
      currentTokenPriceCents: startup.currentTokenPriceCents,
      tags: startup.tags ?? [],
      thumbnailPath: startup.thumbnailPath,
    } satisfies StartupListItemDTO;
  });
};

/*
 * Busca no banco todos os dados de uma startup
 */
export const getFullStartup = async (
  startupId: string,
): Promise<StartupDetailsDTO> => {
  const doc = await startupsCollection.doc(startupId).get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada!");
  }

  const startup = doc.data() as StartupDocument;

  return {
    id: doc.id,
    ...startup,
  } satisfies StartupDetailsDTO;
};

/*
 * Verifica se uma startup existe
 */
export const checkStartupExists = async (startupId: string) => {
  const doc = await startupsCollection.doc(startupId).get();
  return doc.exists;
};
