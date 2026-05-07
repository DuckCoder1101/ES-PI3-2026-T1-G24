/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { logger } from "firebase-functions/v2";
import { onCall } from "firebase-functions/https";
import { getUserProfile } from "../../../shared/auth";
import { removeUser2Fa } from "../../repositories/twoFaRepository";

/*
 * Desativa a 2Fa para o usuário
 */
export const disable2FA = onCall(async (request) => {
  const { uid } = getUserProfile(request);

  logger.log("Desativando 2FA para o usuário: " + uid);
  await removeUser2Fa(uid);

  return {
    success: true,
  };
});
