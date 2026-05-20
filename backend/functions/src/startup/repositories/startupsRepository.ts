/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError } from "firebase-functions/https";
import { database } from "../../shared/firebase";
import {
  DateInterval,
  DateLimits,
  PriceHistoryDocument as PriceHistoryPointDocument,
  StartupDocument,
} from "../types/documents";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

import {
  StartupDetailsDTO,
  StartupListItemDTO,
  StartupResumeDTO,
  StartupStageFilter,
} from "../types/dtos";

const startupsCollection = database.collection("startups");
const getPriceHistoryCollection = (startupId: string) =>
  startupsCollection.doc(startupId).collection("priceHistory");

const getLimitsFromDateInterval = (interval: DateInterval): DateLimits => {
  const end = new Date();
  const start = new Date();

  switch (interval) {
    case "1M":
      start.setMonth(start.getMonth() - 1);
      break;
    case "6M":
      start.setMonth(start.getMonth() - 6);
      break;
    case "1Y":
      start.setFullYear(start.getFullYear() - 1);
      break;
    case "5Y":
      start.setFullYear(start.getFullYear() - 5);
      break;
  }

  return { start, end };
};

/*
 * Busca as startups no banco de dados seguindo um offset, um limite e um filtro
 */
export const findStartups = async (
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

export const findStartupsResumes = async (): Promise<StartupResumeDTO[]> => {
  const snapshot = await startupsCollection.select("name").get();

  return snapshot.docs.map((doc) => ({
    ...(doc.data() as StartupResumeDTO),
    id: doc.id,
  })) satisfies StartupResumeDTO[];
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

/*
 * Atualiza o preço atual do token de uma startup dentro de uma transaction
 * e registra o snapshot no histórico de preços.
 */
export const updateTokenPrice = (
  startupId: string,
  newPriceCents: number,
  taxaOcupacao: number,
  triggeredByTransactionId: string,
) => {
  database.runTransaction(async (tx) => {
    const startupRef = startupsCollection.doc(startupId);
    const priceHistoryRef = getPriceHistoryCollection(startupId).doc();

    tx.update(startupRef, {
      currentTokenPriceCents: newPriceCents,
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.set(priceHistoryRef, {
      priceCents: newPriceCents,
      taxaOcupacao,
      triggeredBy: triggeredByTransactionId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Retorna os pontos de atualização da valorização da startup
 */
export const getStartupTokenPriceHistory = async (
  startupId: string,
  dateInterval: DateInterval,
) => {
  const { start, end } = getLimitsFromDateInterval(dateInterval);

  const snapshot = await getPriceHistoryCollection(startupId)
    .where("createdAt", ">=", Timestamp.fromDate(start))
    .where("createdAt", "<=", Timestamp.fromDate(end))
    .get();

  const priceHistory = snapshot.docs.map(
    (doc) => doc.data() as PriceHistoryPointDocument,
  );

  return priceHistory;
};
