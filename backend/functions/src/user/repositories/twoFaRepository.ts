/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import { database } from "../../shared/firebase";
import { TwoFaDocument } from "../types/documents";

const usersCollection = database.collection("users");

export const getTwoFaRef = (uid: string) =>
  usersCollection.doc(uid).collection("security").doc("twoFa");

/*
 * Salva o código 2FA ainda desativado na conta do usuário
 * Lança um erro caso o usuário não seja encontrado
 */
export const setUser2FaSecret = async (uid: string, secret: string) => {
  const ref = getTwoFaRef(uid);

  if (!ref) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  await ref.set({
    uid,
    enabled: false,
    secret,
    updatedAt: FieldValue.serverTimestamp(),
  });
};

/*
 * Habilita 2FA já existente para o usuário
 * Lança um erro caso não seja encontrado o código
 */
export const enableUser2Fa = async (uid: string) => {
  const ref = getTwoFaRef(uid);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await database.runTransaction(async (tx) => {
    tx.set(ref, { enabled: true }, { merge: true });
    tx.set(usersCollection.doc(uid), { has2Fa: true }, { merge: true });
  });
};

/*
 * Desativa e remove o 2FA para o usuário
 * Lança um erro caso não seja encontrado o código
 */
export const removeUser2Fa = async (uid: string) => {
  const ref = getTwoFaRef(uid);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await database.runTransaction(async (tx) => {
    tx.delete(ref);
    tx.set(usersCollection.doc(uid), { has2Fa: false }, { merge: true });
  });
};

/*
 * Busca 2FA
 */
export const getUser2Fa = async (uid: string) => {
  const snapshot = await getTwoFaRef(uid).get();

  if (!snapshot.exists) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  return snapshot.data() as TwoFaDocument;
};
