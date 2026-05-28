/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { logger } from "firebase-functions/v2";
import { findUserTransactions } from "../repositories/transactionsRepository";

/*
 * Retorna o histórico completo de transações do usuário autenticado.
 * Inclui transações de adição de fundos, compras diretas e negociações no balcão.
 */
export const getUserTransactions = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);
  logger.log(`[getUserTransactions] uid=${uid}`);
  const transactions = await findUserTransactions(uid);

  return {
    transactions,
  };
});
