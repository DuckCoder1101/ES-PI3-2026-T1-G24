/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";

import { database } from "../../shared/firebase";

import {
  InvestmentListDTO,
  UpdateProfileDTO,
  UserFullDTO,
  UserSignupDTO,
} from "../types/dtos";

import {
  InvestmentDocument,
  UserDocument,
  WalletDocument,
} from "../types/documents";

import { StartupResumeDTO } from "../../startup/types/dtos";
import { chunkArray } from "../../shared/dataArray";

const cpfsCollection = database.collection("cpf_index");
const usersCollection = database.collection("users");
const walletsCollection = database.collection("wallets");
const transactionsCollection = database.collection("transactions");
const investmentsCollection = database.collection("investments");
const startupsCollection = database.collection("startups");

/*
 * Busca startups resumidas
 */
const getStartupResumeMap = async (
  ids: string[],
): Promise<Record<string, StartupResumeDTO>> => {
  const uniqueIds = [...new Set(ids)];

  if (uniqueIds.length === 0) {
    return {};
  }

  const chunks = chunkArray(uniqueIds, 10);

  const snapshots = await Promise.all(
    chunks.map((chunk) =>
      startupsCollection
        .where(admin.firestore.FieldPath.documentId(), "in", chunk)
        .select("name")
        .get(),
    ),
  );

  const startups: Record<string, StartupResumeDTO> = {};

  snapshots.forEach((snapshot) => {
    snapshot.docs.forEach((doc) => {
      startups[doc.id] = {
        ...(doc.data() as StartupResumeDTO),
        id: doc.id,
      };
    });
  });

  return startups;
};

/*
 * Cadastra um novo usuário
 */
export const createUserAccount = async (
  uid: string,
  data: UserSignupDTO,
): Promise<void> => {
  await database.runTransaction(async (tx) => {
    const cpfRef = cpfsCollection.doc(data.cpf);
    const walletRef = walletsCollection.doc(uid);
    const userRef = usersCollection.doc(uid);

    const cpfDoc = await tx.get(cpfRef);

    if (cpfDoc.exists) {
      throw new HttpsError("already-exists", "CPF já cadastrado!");
    }

    tx.set(cpfRef, { uid });

    tx.set(walletRef, {
      fundsCents: 0,
      lockedFundsCents: 0,
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.set(userRef, {
      ...data,
      has2Fa: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Atualiza dados do usuário
 */
export const updateUserData = async (
  uid: string,
  data: UpdateProfileDTO,
): Promise<void> => {
  try {
    await usersCollection.doc(uid).update({
      name: data.name,
      phone: data.phone,
    });
  } catch {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }
};

/*
 * Busca usuário
 */
export const getById = async (uid: string): Promise<UserFullDTO> => {
  const snapshot = await usersCollection.doc(uid).get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  const userData = snapshot.data() as UserDocument;

  return {
    uid,
    ...userData,
  };
};

/*
 * Busca carteira
 */
export const getWallet = async (uid: string): Promise<WalletDocument> => {
  const snapshot = await walletsCollection.doc(uid).get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Carteira não encontrada!");
  }

  return snapshot.data() as WalletDocument;
};

/*
 * Adiciona fundos
 */
export const addFundsToWallet = async (
  uid: string,
  fundsCents: number,
): Promise<void> => {
  if (fundsCents <= 0) {
    throw new HttpsError("invalid-argument", "Valor inválido!");
  }

  await database.runTransaction(async (tx) => {
    const walletRef = walletsCollection.doc(uid);
    const walletDoc = await tx.get(walletRef);

    if (!walletDoc.exists) {
      throw new HttpsError("not-found", "Carteira não encontrada!");
    }

    tx.update(walletRef, {
      fundsCents: FieldValue.increment(fundsCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const transactionRef = transactionsCollection.doc();

    tx.set(transactionRef, {
      type: "funds",
      authorUId: uid,
      amountCents: fundsCents,
      userUIds: [uid],
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Retorna investimentos do usuário
 */
export const getInvestments = async (
  uid: string,
): Promise<InvestmentListDTO[]> => {
  const snapshot = await investmentsCollection
    .doc(uid)
    .collection("startups")
    .get();

  const startupIds = [...new Set(snapshot.docs.map((doc) => doc.id))];
  const startups = await getStartupResumeMap(startupIds);

  return snapshot.docs.flatMap((doc) => {
    const data = doc.data() as InvestmentDocument;
    const startup = startups[doc.id];

    if (!startup) {
      return [];
    }

    return [
      {
        ...data,
        startup,
        tokenAmount:
          typeof data.tokenAmount === "number" ? data.tokenAmount : 0,

        lockedTokenAmount:
          typeof data.lockedTokenAmount === "number"
            ? data.lockedTokenAmount
            : 0,
      } satisfies InvestmentListDTO,
    ];
  });
};
