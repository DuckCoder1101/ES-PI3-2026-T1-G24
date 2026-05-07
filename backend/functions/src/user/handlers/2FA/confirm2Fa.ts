/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import speakeasy from "speakeasy";

import { getUserProfile } from "../../../shared/auth";
import { enableUser2Fa, getUser2Fa } from "../../repositories/twoFaRepository";

/*
 * Habilita o código 2Fa já existente do usuário
 */
export const confirm2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const { token } = request.data;

  logger.log("Habilitando 2FA para o usuário: " + uid);

  const twoFaDoc = await getUser2Fa(uid);

  const isVerified = speakeasy.totp.verify({
    secret: twoFaDoc.secret,
    encoding: "base32",
    token,
    window: 2,
  });

  if (!isVerified) {
    throw new HttpsError("invalid-argument", "Código inválido");
  }

  // ativa 2FA
  await enableUser2Fa(uid);

  return {
    success: true,
  };
});
