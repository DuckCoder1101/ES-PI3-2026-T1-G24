/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../shared/firebase";
import { UserDocument } from "../types/documents";
import { UserSignupDTO } from "../types/dtos";

const usersCollection = database.collection("users");

export const createUserAccount = async (uid: string, data: UserSignupDTO) => {
  await database.runTransaction(async (tx) => {
    const cpfRef = database.collection("cpf_index").doc(data.cpf);
    const userRef = database.collection("users").doc(uid);

    const cpfDoc = await tx.get(cpfRef);

    if (cpfDoc.exists) {
      throw new Error("CPF já cadastrado");
    }

    tx.set(cpfRef, { uid });
    tx.set(userRef, {
      uid,
      ...data,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

export const findUserById = async (
  uid: string,
): Promise<UserDocument | null> => {
  const doc = await usersCollection.doc(uid).get();

  if (!doc.exists) return null;

  return {
    uid: doc.id,
    ...doc.data(),
  } as UserDocument;
};

export const existsCpf = async (cpf: string): Promise<boolean> => {
  const cpfDoc = await database.collection("cpf_index").doc(cpf).get();
  return cpfDoc.exists;
};
