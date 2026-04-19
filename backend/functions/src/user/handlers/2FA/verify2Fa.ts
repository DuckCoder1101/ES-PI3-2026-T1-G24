import { HttpsError, onCall } from "firebase-functions/https";
import speakeasy from "speakeasy";

import { getUserProfile } from "../../shared/auth";
import { get2FA } from "../../repositories/twoFaRepository";

export const verify2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const { token } = request.data;

  const twoFa = await get2FA(uid);

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
    throw new HttpsError("invalid-argument", "Código inválido");
  }

  return {
    success: true,
  };
});
