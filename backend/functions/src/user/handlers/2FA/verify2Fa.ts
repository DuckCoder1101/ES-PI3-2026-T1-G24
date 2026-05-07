/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import speakeasy from "speakeasy";

import { getUserProfile } from "../../../shared/auth";
import { getUser2Fa } from "../../repositories/twoFaRepository";

/*
 * Verifica o código digitado pelo usuário com o hash salvo no banco
 */

export const verify2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const { token } = request.data;

  logger.log("Verificando 2FA do usuário: " + uid);

  const twoFa = await getUser2Fa(uid);
  if (!twoFa.enabled) {
    return {
      success: true,
      data: null,
    };
  }

  const verified = speakeasy.totp.verify({
    secret: twoFa.secret,
    encoding: "base32",
    token,
    window: 1,
  });

  if (!verified) {
    throw new HttpsError("invalid-argument", "Código 2Fa inválido");
  }

  return {
    success: true,
  };
});
