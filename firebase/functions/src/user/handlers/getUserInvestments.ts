/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { getInvestments } from "../repositories/usersRepository";

/*
 * Retorna todos os investimentos (posições em startups) do usuário autenticado.
 * Cada item contém o ID da startup, tokens disponíveis e tokens bloqueados em ordens de venda.
 */
export const getUserInvestments = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const investments = await getInvestments(uid);

  return { investments };
});
