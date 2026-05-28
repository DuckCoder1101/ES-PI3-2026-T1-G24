/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

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
import { StartupDocument } from "../../startup/types/documents";

const cpfsCollection = database.collection("cpf_index");
const usersCollection = database.collection("users");
const walletsCollection = database.collection("wallets");
const transactionsCollection = database.collection("transactions");

const getInvestmentsStartupsCollection = (uid: string) =>
  database.collection("investments").doc(uid).collection("startups");

/*
 * Cadastra um novo usuário, criando sua carteira e indexando o CPF.
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
 * Atualiza nome e telefone do perfil do usuário.
 */
export const updateUserData = async (
  uid: string,
  data: UpdateProfileDTO,
): Promise<void> => {
  const userRef = await usersCollection.doc(uid).get();

  if (!userRef.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  await userRef.ref.update({
    name: data.name,
    phone: data.phone,
  });
};

/*
 * Busca os dados completos do usuário pelo UID.
 */
export const getById = async (uid: string): Promise<UserFullDTO> => {
  const snapshot = await usersCollection.doc(uid).get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  return {
    uid,
    ...(snapshot.data() as UserDocument),
  };
};

/*
 * Retorna a carteira do usuário.
 */
export const getWallet = async (uid: string): Promise<WalletDocument> => {
  const snapshot = await walletsCollection.doc(uid).get();

  if (!snapshot.exists) {
    await snapshot.ref.set({
      fundsCents: 0,
      lockedFundsCents: 0,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return await getWallet(uid);
  }

  return snapshot.data() as WalletDocument;
};

/*
 * Adiciona fundos fictícios à carteira e registra a transação.
 */
export const addFundsToWallet = async (uid: string, fundsCents: number) => {
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
 * Retorna todos os investimentos do usuário.
 */
export const getInvestments = async (
  uid: string,
): Promise<InvestmentListDTO[]> => {
  const snapshot = await getInvestmentsStartupsCollection(uid).get();
  if (snapshot.empty) return [];

  const refs = snapshot.docs.map((doc) =>
    database.collection("startups").doc(doc.data().startupId),
  );
  const startupDocs = await database.getAll(...refs);

  return snapshot.docs.map((doc, i) => {
    const data = doc.data() as InvestmentDocument;
    const startupDoc = startupDocs[i];
    const startup = startupDoc.data() as StartupDocument;

    return {
      ...data,
      startup: startupDoc.exists
        ? {
            id: startupDoc.id,
            name: startup.name,
            isInvestor: true,
            currentTokenPriceCents: startup.currentTokenPriceCents,
            initialTokenPriceCents: startup.initialTokenPriceCents,
            stage: startup.stage,
          }
        : {
            id: data.startupId,
            name: "Startup removida!",
            isInvestor: false,
            currentTokenPriceCents: 0,
            initialTokenPriceCents: 0,
          },
    } satisfies InvestmentListDTO;
  });
};

/*
 * Retorna se o usuário é investidor daquela startup
 */
export const isInvestor = async (
  uid: string,
  startupId: string,
): Promise<boolean> => {
  const snapshot = await getInvestmentsStartupsCollection(uid)
    .doc(startupId)
    .get();
  return snapshot.exists;
};
