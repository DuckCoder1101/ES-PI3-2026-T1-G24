/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { GetStartupDetailsBodyDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { logger } from "firebase-functions/v2";
import { getById } from "../repositories/startupsRepository";
import { getAuthenticatedUser } from "../../shared/auth";

/*
 * Retorna todos os dados de uma startup
 */
export const getStartupById = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const { startupId } = req.data as GetStartupDetailsBodyDTO;
  const normalizedStartupId = normalizeString(startupId);

  if (!normalizedStartupId) {
    throw new HttpsError("invalid-argument", "ID de startup inválido ou nulo!");
  }

  logger.log(`[getStartupById] uid=${uid} startupId=${normalizedStartupId}`);
  return await getById(normalizedStartupId, uid);
});
