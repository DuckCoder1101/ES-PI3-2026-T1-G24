/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { UserFullDTO, UserSignupDTO } from "../types/dtos";

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
      ...data,
      has2Fa: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

export const getById = async (uid: string): Promise<UserFullDTO | null> => {
  const snapshot = await usersCollection.doc(uid).get();
  if (!snapshot.exists) return null;

  const userData = snapshot.data();

  return {
    uid,
    ...userData,
  } as UserFullDTO;
};

export const existsByCpf = async (cpf: string): Promise<boolean> => {
  const cpfDoc = await database.collection("cpf_index").doc(cpf).get();
  return cpfDoc.exists;
};
