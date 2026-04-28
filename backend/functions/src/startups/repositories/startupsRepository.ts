/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { database } from "../../shared/firebase";
import { StartupDocument } from "../types/documents";
import {
  StartupFullDTO,
  StartupListItemDTO,
  StartupsSearchFilter,
} from "../types/dtos";

const startupsCollection = database.collection("startups");

export const findAllStatups = async (
  offset: number,
  limit: number,
  filter: StartupsSearchFilter,
): Promise<StartupListItemDTO[]> => {
  const query = (
    filter === "all"
      ? startupsCollection
      : startupsCollection.where("stage", "==", filter)
  )
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
): Promise<StartupFullDTO | null> => {
  const doc = await startupsCollection.doc(startupId).get();
  const startup = doc.data() as StartupDocument;

  if (!startup) {
    return null;
  }

  return {
    id: doc.id,
    ...startup,
  };
};
