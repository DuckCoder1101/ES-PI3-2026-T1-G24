import { FieldValue } from "firebase-admin/firestore";
import { database } from "../shared/firebase";
import { HttpsError } from "firebase-functions/https";
import { twoFaDocument } from "../types/documents";

const usersCollection = database.collection("users");

const getTwoFaRef = (uid: string) =>
  usersCollection.doc(uid).collection("security").doc("twoFa");

/*
 * Salva o código 2FA
 */
export const set2FASecret = async (uid: string, secret: string) => {
  const ref = getTwoFaRef(uid);

  await ref.set({
    uid,
    enabled: false,
    secret,
    updatedAt: FieldValue.serverTimestamp(),
  });
};

/*
 * Habilita 2FA
 */
export const enable2FA = async (uid: string) => {
  const ref = getTwoFaRef(uid);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await ref.set({ enabled: true }, { merge: true });
};

/*
 * Remove 2FA
 */
export const remove2FA = async (uid: string) => {
  const ref = getTwoFaRef(uid);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await ref.delete();
};

/*
 * Busca 2FA
 */
export const get2FA = async (uid: string) => {
  const doc = await getTwoFaRef(uid).get();

  if (!doc.exists) return null;

  return doc.data() as twoFaDocument;
};
