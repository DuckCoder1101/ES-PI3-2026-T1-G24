/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { UpdateProfileDTO, UserFullDTO, UserSignupDTO } from "../types/dtos";
import { HttpsError } from "firebase-functions/https";
import { UserDocument } from "../types/documents";

const cpfsCollection = database.collection("cpf_index");
const usersCollection = database.collection("users");
const walletsCollection = database.collection("wallets");
const transactionsCollection = database.collection("transactions");

/*
 * Cadastra um novo usuário na coleção users do Firestore.
 * Cria também a carteira inicial com saldo zero.
 * Lança um erro caso já exista um usuário com o mesmo CPF.
 */
export const createUserAccount = async (uid: string, data: UserSignupDTO) => {
  await database.runTransaction(async (tx) => {
    const cpfRef = cpfsCollection.doc(data.cpf);
    const walletRef = walletsCollection.doc(uid);
    const userRef = usersCollection.doc(uid);

    const cpfDoc = await tx.get(cpfRef);

    if (cpfDoc.exists) {
      throw new HttpsError("already-exists", "CPF já cadastrado!");
    }

    tx.set(cpfRef, { uid });

    // Carteira iniciada com saldo zero (em centavos)
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
 * Retorna a carteira do usuário
 */
export const getWallet = async (uid: string): Promise<WalletDocument> => {
  const snapshot = await walletsCollection.doc(uid).get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Carteira não encontrada!");
  }

  return snapshot.data() as WalletDocument;
};

/*
 * Adiciona fundos fictícios à carteira do usuário.
 * Registra uma transação do tipo "funds" na coleção de transações.
 */
export const addFundsToWallet = async (
  uid: string,
  fundsCents: number,
): Promise<void> => {
  await database.runTransaction(async (tx) => {
    const walletRef = walletsCollection.doc(uid);
    const walletDoc = await tx.get(walletRef);

    if (!walletDoc.exists) {
      throw new HttpsError("not-found", "Carteira não encontrada!");
    }

    // Incrementa o saldo disponível da carteira
    tx.update(walletRef, {
      fundsCents: FieldValue.increment(fundsCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Registra a transação de depósito de fundos
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
