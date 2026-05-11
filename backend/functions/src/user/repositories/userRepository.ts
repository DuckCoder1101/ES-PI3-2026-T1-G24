/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { UpdateProfileDTO, UserFullDTO, UserSignupDTO } from "../types/dtos";
import { HttpsError } from "firebase-functions/https";
import { UserDocument } from "../types/documents";

const usersCollection = database.collection("users");

/*
 * Cadastra um novo usuário na coleção users do firestore
 * Lança um erro caso já exista um usuário com o mesmo CPF
 */
export const createUserAccount = async (uid: string, data: UserSignupDTO) => {
  await database.runTransaction(async (tx) => {
    const cpfRef = database.collection("cpf_index").doc(data.cpf);
    const userRef = database.collection("users").doc(uid);

    const cpfDoc = await tx.get(cpfRef);

    if (cpfDoc.exists) {
      throw new HttpsError("already-exists", "CPF já cadastrado!");
    }

    tx.set(cpfRef, { uid });
    tx.set(userRef, {
      ...data,
      has2Fa: false,
      funds: 1000,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Atualiza o nome e o telefone do usuário
 */
export const updateUserData = async (uid: string, data: UpdateProfileDTO) => {
  const ref = usersCollection.doc(uid);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  await ref.set(
    {
      name: data.name,
      phone: data.phone,
    },
    {
      merge: true,
    },
  );
};

/*
 * Retorna todos os dados do usuário com base no ID
 */
export const getById = async (uid: string): Promise<UserFullDTO> => {
  const snapshot = await usersCollection.doc(uid).get();
  const userData = snapshot.data() as UserDocument;

  return {
    uid,
    ...userData,
  } satisfies UserFullDTO;
};

/*
 * Adiciona um deternminado valor à carteira do usuário
 */
export const setUserFunds = async (uid: string, funds: number) => {
  const ref = usersCollection.doc(uid);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

  await ref.set({ funds: funds }, { merge: true });
};
