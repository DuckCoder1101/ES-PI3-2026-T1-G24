/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { database } from "../../shared/firebase";
import { StartupDocument } from "../types/documents";
import { StartupListItemDTO, StartupStageFilter } from "../types/dtos";

const startupsCollection = database.collection("startups");

export const searchStartups = async (
  offset: number,
  limit: number,
  filter: StartupStageFilter,
  name: string | null,
): Promise<StartupListItemDTO[]> => {
  const query = (
    filter === "all"
      ? startupsCollection
      : startupsCollection.where("stage", "==", filter)
  )
    .where("name", ">=", name)
    .where("name", "<=", name + "\uf8ff")
    .offset(offset)
    .limit(limit);

  const snapshot = await query.get();

  return snapshot.docs.map((doc) => {
    return {
      id: doc.id,
      ...(doc.data() as StartupDocument),
    };
  });
};

export const getFullStartup = async (
  startupId: string,
): Promise<StartupDocument | null> => {
  const doc = await startupsCollection.doc(startupId).get();
  const startup = doc.data() as StartupDocument;

  if (!startup) {
    return null;
  }

  return startup;
};
