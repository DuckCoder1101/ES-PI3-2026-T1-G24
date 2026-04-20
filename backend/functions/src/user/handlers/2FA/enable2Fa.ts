// Autor: Cristian Fava
// RA: 25000636

import { onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import speakeasy from "speakeasy";

import { getUserProfile } from "../../shared/auth";
import { set2FASecret } from "../../repositories/twoFaRepository";

export const enable2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  logger.log("Gerando e salvando código 2FA para o usuário: " + uid);

  const secret = speakeasy.generateSecret({
    length: 20,
  });

  const otpauth = `otpauth://totp/Mescla-Invest?secret=${secret.base32}&issuer=Mescla_Invest`;

  // Salva o secret
  await set2FASecret(uid, secret.base32);

  return {
    success: true,
    otpauth,
    manualKey: secret.base32,
  };
});
