/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../shared/firebase";
import { UserFullDTO, UserSignupDTO } from "../types/dtos";
import { getTwoFaRef } from "./twoFaRepository";

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
      has2Fa: false,
      createdAt: FieldValue.serverTimestamp(),
      ...data,
    });
  });
};

// No ficheiro userRepository.ts
export const findUserById = async (
  uid: string,
): Promise<UserFullDTO | null> => {
  const userDoc = await usersCollection.doc(uid).get();

  // Busca o documento de segurança
  const twoFaDoc = await getTwoFaRef(uid).get();

  if (!userDoc.exists) return null;

  const userData = userDoc.data();
  const twoFaData = twoFaDoc.data();

  return {
    uid,
    ...userData,
    has2Fa: twoFaData?.enabled ?? false,
  } as UserFullDTO;
};

export const existsByCpf = async (cpf: string): Promise<boolean> => {
  const cpfDoc = await database.collection("cpf_index").doc(cpf).get();
  return cpfDoc.exists;
};
