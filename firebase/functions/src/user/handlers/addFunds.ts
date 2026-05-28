/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import { addFundsToWallet } from "../repositories/usersRepository";
import { getAuthenticatedUser } from "../../shared/auth";

/*
 * Adiciona saldo fictício à carteira do usuário (simulação de depósito).
 * O valor mínimo é R$ 10,00. Registra uma transação do tipo "funds".
 */
export const addFunds = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);
  const funds = req.data["funds"] as number;

  if (!funds || typeof funds !== "number" || funds < 10) {
    throw new HttpsError(
      "invalid-argument",
      "Valor inválido! O valor mínimo é R$ 10,00.",
    );
  }

  // Converte reais para centavos para armazenamento
  const fundsCents = Math.round(funds * 100);

  logger.log(`[addFunds] uid=${uid} valor=R$${funds}`);
  await addFundsToWallet(uid, fundsCents);

  return {
    success: true,
  };
});
