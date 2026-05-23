/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { GetStartupDetailsBodyDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { getFullStartup } from "../repositories/startupsRepository";
import { getAuthenticatedUser } from "../../shared/auth";

/*
 * Retorna todos os dados de uma startup
 */
export const getStartupDetails = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const { startupId } = req.data as GetStartupDetailsBodyDTO;
  const normalizedStartupId = normalizeString(startupId);

  if (!normalizedStartupId) {
    throw new HttpsError("invalid-argument", "ID de startup inválido ou nulo!");
  }

  return await getFullStartup(normalizedStartupId, uid);
});
