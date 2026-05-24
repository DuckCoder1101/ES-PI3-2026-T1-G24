/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError } from "firebase-functions/https";
import { database } from "../../shared/firebase";
import {
  DateInterval,
  DateLimits,
  PriceHistoryDocument,
  StartupDocument,
} from "../types/documents";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import {
  StartupDetailsDTO,
  StartupListItemDTO,
  StartupResumeDTO,
  StartupStageFilter,
  StartupTokenInfoDTO,
} from "../types/dtos";

const startupsCollection = database.collection("startups");

const getPriceHistoryCollection = (startupId: string) =>
  startupsCollection.doc(startupId).collection("priceHistory");

const getInvestmentsStartupsCollection = (uid: string) =>
  database.collection("investments").doc(uid).collection("startups");

/*
 * Retorna os IDs das startups que o usuário é investidor
 */
const getInvestedStartupIds = async (uid: string): Promise<Set<string>> => {
  const snapshot = await database
    .collection("investments")
    .doc(uid)
    .collection("startups")
    .select() // busca só os IDs dos docs, sem campos
    .get();

  return new Set(snapshot.docs.map((doc) => doc.id));
};

/*
 * Transforma os lites do enum em objetos Date
 */
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
 * Busca as startups no banco seguindo offset, limite e filtro.
 */
export const findStartups = async (
  uid: string,
  offset: number,
  limit: number,
  filter: StartupStageFilter,
  name: string | null,
): Promise<StartupListItemDTO[]> => {
  let query =
    filter === "all"
      ? startupsCollection
      : startupsCollection.where("stage", "==", filter);

  if (name && name.trim().length > 0) {
    query = query
      .where("name", ">=", name)
      .where("name", "<=", name + "\uf8ff");
  }

  const [snapshot, investments] = await Promise.all([
    query.offset(offset).limit(limit).get(),
    getInvestedStartupIds(uid),
  ]);

  return snapshot.docs.map((doc) => {
    const startup = doc.data() as StartupDocument;

    return {
      id: doc.id,
      name: startup.name,
      stage: startup.stage,
      shortDescription: startup.shortDescription,
      capitalRaisedCents: startup.capitalRaisedCents,
      totalTokensAvailable: startup.totalTokensAvailable,
      currentTokenPriceCents: startup.currentTokenPriceCents,
      tags: startup.tags ?? [],
      thumbnailPath: startup.thumbnailPath,
      isInvestor: investments.has(doc.id),
    } satisfies StartupListItemDTO;
  });
};

/*
 * Retorna lista resumida de todas as startups (id, nome, isInvestor).
 * Usada para popular dropdowns e seletores no app.
 */
export const findStartupsResumes = async (
  uid: string,
): Promise<StartupResumeDTO[]> => {
  const snapshot = await startupsCollection.select("name").get();
  const investedIds = await getInvestedStartupIds(uid);

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    name: (doc.data() as Pick<StartupDocument, "name">).name,
    isInvestor: investedIds.has(doc.id),
  })) satisfies StartupResumeDTO[];
};

/*
 * Busca todos os dados de uma startup
 */
export const getFullStartup = async (
  startupId: string,
  uid: string,
): Promise<StartupDetailsDTO> => {
  const [doc, investmentDoc] = await Promise.all([
    startupsCollection.doc(startupId).get(),
    getInvestmentsStartupsCollection(uid).doc(startupId).get(),
  ]);

  if (!doc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada!");
  }

  const startup = doc.data() as StartupDocument;

  return {
    ...startup,
    id: doc.id,
    isInvestor: investmentDoc.exists,
  };
};

/*
 * Verifica se uma startup existe.
 */
export const checkStartupExists = async (
  startupId: string,
): Promise<boolean> => {
  const doc = await startupsCollection.doc(startupId).get();
  return doc.exists;
};

/*
 * Atualiza o preço atual do token e registra no histórico de preços.
 */
export const updateTokenPrice = (
  startupId: string,
  newPriceCents: number,
  occupancyRate: number,
  triggeredByTransactionId: string,
): void => {
  database.runTransaction(async (tx) => {
    const startupRef = startupsCollection.doc(startupId);
    const priceHistoryRef = getPriceHistoryCollection(startupId).doc();

    tx.update(startupRef, {
      currentTokenPriceCents: newPriceCents,
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.set(priceHistoryRef, {
      priceCents: newPriceCents,
      occupancyRate,
      triggerId: triggeredByTransactionId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Retorna os pontos de valorização do token de uma startup em um intervalo de datas.
 */
export const getStartupTokenPriceHistory = async (
  startupId: string,
  dateInterval: DateInterval,
): Promise<PriceHistoryDocument[]> => {
  const { start, end } = getLimitsFromDateInterval(dateInterval);

  const snapshot = await getPriceHistoryCollection(startupId)
    .where("createdAt", ">=", Timestamp.fromDate(start))
    .where("createdAt", "<=", Timestamp.fromDate(end))
    .get();

  return snapshot.docs.map((doc) => doc.data() as PriceHistoryDocument);
};

export const getStartupTokenInfo = async (
  startupId: string,
): Promise<StartupTokenInfoDTO> => {
  const snapshot = await startupsCollection.doc(startupId).get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Startup não encontrada!");
  }

  const startup = snapshot.data() as StartupDocument;

  return {
    id: startup.id,
    totalTokensAvailable: startup.totalTokensAvailable,
    totalTokensIssued: startup.totalTokensIssued,
    currentTokenPriceCents: startup.currentTokenPriceCents,
  } satisfies StartupTokenInfoDTO;
};
