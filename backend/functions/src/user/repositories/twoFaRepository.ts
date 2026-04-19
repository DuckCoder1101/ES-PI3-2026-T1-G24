import { FieldValue } from "firebase-admin/firestore";
import { database } from "../shared/firebase";
import { HttpsError } from "firebase-functions/https";
import { twoFaDocument } from "../types/documents";

const usersCollection = database.collection("users");

/*
 * Salva o código 2FA para o usuário x
 */
export const settwoFaSecret = async (uid: string, secret: string) => {
  const twoFaDoc = usersCollection.doc(uid).collection("secutiry").doc("twoFa");

  await twoFaDoc.set({
    uid,
    enabled: false,
    secret: secret,
    updatedAt: FieldValue.serverTimestamp(),
  });
};

/*
 * Habilita a 2FA para o usuário com o código já gerado
 */
export const enable2FA = async (uid: string) => {
  const twoFaDoc = usersCollection.doc(uid).collection("secutiry").doc("twoFa");

  if (!twoFaDoc) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await twoFaDoc.update({
    enabled: true,
  });
};

/*
 * Desabilita o 2FA
 */
export const remove2FA = async (uid: string) => {
  const twoFaDoc = usersCollection.doc(uid).collection("secutiry").doc("twoFa");

  if (!twoFaDoc) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para essa conta!",
    );
  }

  await twoFaDoc.delete();
};

/*
 Retorna o secret do 2FA ou null se não existir
 */
export const get2FA = async (uid: string) => {
  const twoFaDoc = await usersCollection
    .doc(uid)
    .collection("secutiry")
    .doc("twoFa")
    .get();

  const twoFa = twoFaDoc.data() as twoFaDocument;

  return twoFa ?? null;
};
