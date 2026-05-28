/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError } from "firebase-functions/https";
import { database } from "../../shared/firebase";
import { TransactionDocument } from "../../transaction/types/documents";
import {
  DateLimits,
  PriceHistoryDocument,
  StartupDocument,
} from "../types/documents";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import {
  StartupDetailsDTO,
  StartupListItemDTO,
  StartupResumeDTO,
  StartupTokenInfoDTO,
} from "../types/dtos";
import { WalletDocument } from "../../user/types/documents";
import { formatCurrency } from "../../shared/formatters";
import { DateInterval } from "../constants/dateInverval";
import { StartupStageFilter } from "../constants/startupStageFilters";

const startupsCollection = database.collection("startups");
const walletsCollection = database.collection("wallets");
const transactionsCollection = database.collection("transactions");

const getPriceHistoryCollection = (startupId: string) =>
  startupsCollection.doc(startupId).collection("priceHistory");

const getInvestmentsCollection = (uid: string) =>
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
    case "1m":
      start.setMonth(start.getMonth() - 1);
      break;
    case "6m":
      start.setMonth(start.getMonth() - 6);
      break;
    case "1y":
      start.setFullYear(start.getFullYear() - 1);
      break;
    case "5y":
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
      : startupsCollection.where("stage", "==", filter.toLowerCase());

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
  const snapshot = await startupsCollection
    .select("name", "currentTokenPriceCents", "initialTokenPriceCents", "stage")
    .get();
  const investedIds = await getInvestedStartupIds(uid);

  return snapshot.docs.map((doc) => {
    const startup = doc.data() as StartupDocument;
    return {
      id: doc.id,
      name: startup.name,
      currentTokenPriceCents: startup.currentTokenPriceCents,
      initialTokenPriceCents: startup.initialTokenPriceCents,
      isInvestor: investedIds.has(doc.id),
      stage: startup.stage,
    };
  }) satisfies StartupResumeDTO[];
};

/*
 * Busca todos os dados de uma startup
 */
export const getById = async (
  startupId: string,
  uid: string,
): Promise<StartupDetailsDTO> => {
  const [startupDoc, investmentDoc] = await Promise.all([
    startupsCollection.doc(startupId).get(),
    getInvestmentsCollection(uid).doc(startupId).get(),
  ]);

  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada!");
  }

  const startup = startupDoc.data() as StartupDocument;

  return {
    ...startup,
    id: startupDoc.id,
    isInvestor: investmentDoc.exists,
  };
};

/*
 * Atualiza o preço atual do token e registra no histórico de preços.
 */
export const updateTokenHistory = async (
  startupId: string,
  newPriceCents: number,
  occupancyRate: number,
) => {
  await database.runTransaction(async (tx) => {
    const startupRef = startupsCollection.doc(startupId);
    const priceHistoryRef = getPriceHistoryCollection(startupId).doc();

    tx.update(startupRef, {
      currentTokenPriceCents: newPriceCents,
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.set(priceHistoryRef, {
      priceCents: newPriceCents,
      occupancyRate,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Atualiza apenas o currentTokenPriceCents da startup
 */
export const updateCurrentPrice = (
  startupId: string,
  newPriceCents: number,
): void => {
  startupsCollection.doc(startupId).update({
    currentTokenPriceCents: newPriceCents,
    updatedAt: FieldValue.serverTimestamp(),
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

/*
 * Retorna os dados de token de uma startup
 */
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
    initialTokenPriceCents: startup.initialTokenPriceCents,
  } satisfies StartupTokenInfoDTO;
};

/*
 * Retorna id + token info de TODAS as startups, sem filtro nem paginação.
 */
export const getAllStartupsTokenInfo = async () => {
  const snapshot = await startupsCollection
    .select(
      "id",
      "currentTokenPriceCents",
      "initialTokenPriceCents",
      "totalTokensIssued",
      "totalTokensAvailable",
    )
    .get();

  return snapshot.docs.map((doc) => {
    const s = doc.data() as StartupDocument;
    return {
      id: doc.id,
      currentTokenPriceCents: s.currentTokenPriceCents,
      initialTokenPriceCents: s.initialTokenPriceCents,
      totalTokensIssued: s.totalTokensIssued,
      totalTokensAvailable: s.totalTokensAvailable,
    } satisfies StartupTokenInfoDTO;
  });
};

/*
 * Retorna todas as transações de uma startup ocorridas a partir de `since`.
 * Usado pelo scheduler para calcular o VWAP do dia.
 */
export const getStartupTransactionsSince = async (
  startupId: string,
  since: Date,
): Promise<TransactionDocument[]> => {
  const snapshot = await database
    .collection("transactions")
    .where("startupId", "==", startupId)
    .where("createdAt", ">=", Timestamp.fromDate(since))
    .get();

  return snapshot.docs
    .map((doc) => doc.data() as TransactionDocument)
    .filter((tx) => tx.type === "investment" || tx.type === "trade");
};

/*
 * Compra os tokens de uma startup de forma direta
 */
export const buyStartupTokens = async (
  uid: string,
  startupId: string,
  tokenAmount: number,
) => {
  await database.runTransaction(async (tx) => {
    const startupRef = database.collection("startups").doc(startupId);
    const startupDoc = await tx.get(startupRef);

    if (!startupDoc.exists) {
      throw new HttpsError("not-found", "Startup não encontrada!");
    }

    const walletRef = walletsCollection.doc(uid);
    const walletDoc = await tx.get(walletRef);

    if (!walletDoc.exists) {
      throw new HttpsError("not-found", "Carteira não encontrada!");
    }

    const investmentRef = getInvestmentsCollection(uid).doc(startupId);
    const investmentDoc = await tx.get(investmentRef);

    const startup = startupDoc.data() as StartupDocument;
    const totalCents = startup.currentTokenPriceCents * tokenAmount;

    // Verifica se o usuário possui saldo suficiente
    const wallet = walletDoc.data() as WalletDocument;
    if (wallet.fundsCents < totalCents) {
      throw new HttpsError(
        "out-of-range",
        `Saldo insuficiente para realizar a compra! Seu saldo é ${formatCurrency(wallet.fundsCents)}`,
      );
    }

    // Verifica disponibilidade de tokens dentro da transação
    if (startup.totalTokensAvailable < tokenAmount) {
      throw new HttpsError(
        "out-of-range",
        `Tokens insuficientes disponíveis! Disponível: ${startup.totalTokensAvailable} tokens.`,
      );
    }

    // Debita os fundos da carteira
    tx.update(walletRef, {
      fundsCents: FieldValue.increment(-totalCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Atualiza a disponibilidade de tokens e capital captado da startup
    tx.update(startupRef, {
      totalTokensAvailable: FieldValue.increment(-tokenAmount),
      capitalRaisedCents: FieldValue.increment(totalCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Cria ou atualiza o investimento do usuário nessa startup
    if (investmentDoc.exists) {
      tx.update(investmentRef, {
        tokenAmount: FieldValue.increment(tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(investmentRef, {
        startupId,
        tokenAmount,
        lockedTokenAmount: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Registra a transação de investimento direto
    const transactionRef = transactionsCollection.doc();
    tx.set(transactionRef, {
      type: "investment",
      investorUId: uid,
      startupId,
      tokensPurchased: tokenAmount,
      tokenPriceCents: startup.currentTokenPriceCents,
      amountCents: totalCents,
      userUIds: [uid],
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};
