/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getUserProfile } from "../../shared/auth";
import { findUserTransactions } from "../repositories/transactionsRepository";

/*
 * Retorna o histórico completo de transações do usuário autenticado.
 * Inclui transações de adição de fundos, compras diretas e negociações no balcão.
 */
export const getUserTransactions = onCall(async (req) => {
  const { uid } = getUserProfile(req);
  const transactions = await findUserTransactions(uid);

  return {
    transactions,
  };
});
