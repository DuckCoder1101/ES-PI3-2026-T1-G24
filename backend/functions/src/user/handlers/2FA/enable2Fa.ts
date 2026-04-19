import { onCall } from "firebase-functions/https";
import speakeasy from "speakeasy";
import QRCode from "qrcode";

import { getUserProfile } from "../../shared/auth";
import { settwoFaSecret } from "../../repositories/twoFaRepository";

export const enable2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);

  const secret = speakeasy.generateSecret({
    length: 20,
    name: "Mescla_Invest",
  });

  // Gera QRCode
  const qrCode = await QRCode.toDataURL(secret.otpauth_url!);

  // Salva o secret
  await settwoFaSecret(uid, secret.base32);

  return {
    success: true,
    qrCode,
    manualCode: secret.base32,
  };
});
