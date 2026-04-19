import speakeasy from "speakeasy";
import { HttpsError, onCall } from "firebase-functions/https";
import admin from "firebase-admin";

import { getUserProfile } from "../../shared/auth";
import { enable2FA, get2FA } from "../../repositories/twoFaRepository";

export const confirm2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const { token } = request.data;

  const twoFa = await get2FA(uid);

  if (!twoFa) {
    throw new HttpsError(
      "not-found",
      "Código 2FA não encontrado para o usuário!",
    );
  }

  const isVerified = speakeasy.totp.verify({
    secret: twoFa.secret,
    encoding: "base32",
    token,
    window: 1,
  });

  if (!isVerified) {
    throw new HttpsError("invalid-argument", "Código inválido");
  }

  // ativa 2FA
  await enable2FA(uid);
  await admin.auth().setCustomUserClaims(uid, {
    twoFactorEnabled: true,
  });

  return {
    success: true,
  };
});
