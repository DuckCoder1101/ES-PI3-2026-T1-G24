/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { database } from "../../shared/firebase";
import { FieldValue } from "firebase-admin/firestore";
import { WalletDocument } from "../../user/types/documents";
import { StartupDocument } from "../types/documents";

const walletsCollection = database.collection("wallets");
const transactionsCollection = database.collection("transactions");

const getInvestmentsCollection = (uid: string) =>
  database.collection("investments").doc(uid).collection("startups");

/*
 * Permite a compra direta de tokens de uma startup a partir da página da startup.
 */
export const buyTokens = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const startupId = normalizeString(req.data.startupId);
  const tokenAmount = req.data.tokenAmount as number;

  if (!startupId) {
    throw new HttpsError("invalid-argument", "ID da startup inválido!");
  }

  if (typeof tokenAmount !== "number" || tokenAmount <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "A quantidade de tokens deve ser um número maior que 0.",
    );
  }

  await database.runTransaction(async (tx) => {
    const startupRef = database.collection("startups").doc(startupId);
    const startupDoc = await startupRef.get();

    if (!startupDoc.exists) {
      throw new HttpsError("not-found", "Startup não encontrada!");
    }

    const walletRef = walletsCollection.doc(uid);
    const walletDoc = await tx.get(walletRef);

    if (!walletDoc.exists) {
      throw new HttpsError("not-found", "Carteira não encontrada!");
    }

    const investmentRef = getInvestmentsCollection(uid).doc(startupId);
    const investmentDoc = await tx.get(investmentRef);

    const startup = startupDoc.data() as StartupDocument;
    const totalCents = startup.currentTokenPriceCents * tokenAmount;

    // Verifica se o usuário possui saldo suficiente
    const wallet = walletDoc.data() as WalletDocument;
    if (wallet.fundsCents < totalCents) {
      const fundsStr = (wallet.fundsCents / 100).toLocaleString("pt-br", {
        style: "currency",
        currency: "BRL",
      });
      throw new HttpsError(
        "out-of-range",
        `Saldo insuficiente para realizar a compra! Seu saldo é ${fundsStr}`,
      );
    }

    // Verifica disponibilidade de tokens dentro da transação
    if (startup.totalTokensAvailable < tokenAmount) {
      throw new HttpsError(
        "out-of-range",
        `Tokens insuficientes disponíveis! Disponível: ${startup.totalTokensAvailable} tokens.`,
      );
    }

    // Debita os fundos da carteira
    tx.update(walletRef, {
      fundsCents: FieldValue.increment(-totalCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Atualiza a disponibilidade de tokens e capital captado da startup
    tx.update(startupRef, {
      totalTokensAvailable: FieldValue.increment(-tokenAmount),
      capitalRaisedCents: FieldValue.increment(totalCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Cria ou atualiza o investimento do usuário nessa startup
    if (investmentDoc.exists) {
      tx.update(investmentRef, {
        tokenAmount: FieldValue.increment(tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(investmentRef, {
        startupId,
        tokenAmount,
        lockedTokenAmount: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Registra a transação de investimento direto
    const transactionRef = transactionsCollection.doc();
    tx.set(transactionRef, {
      type: "investment",
      investorUId: uid,
      startupId,
      tokensPurchased: tokenAmount,
      tokenPriceCents: startup.currentTokenPriceCents,
      amountCents: totalCents,
      userUIds: [uid],
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  return {
    success: true,
  };
});
