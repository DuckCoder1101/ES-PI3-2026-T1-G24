/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { buyStartupTokens } from "../repositories/startupsRepository";

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

  await buyStartupTokens(uid, startupId, tokenAmount);

  return {
    success: true,
  };
});
