import { onCall } from "firebase-functions/https";
import admin from "firebase-admin";

import { getUserProfile } from "../../shared/auth";
import { remove2FA } from "../../repositories/twoFaRepository";

export const disable2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);

  await remove2FA(uid);
  await admin.auth().setCustomUserClaims(uid, {
    twoFactorEnabled: false,
  });

  return {
    success: true,
  };
});
