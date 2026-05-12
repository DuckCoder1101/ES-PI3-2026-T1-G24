/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { GetStartupDetailsBodyDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { getFullStartup } from "../repositories/startupsRepository";
import { getUserProfile } from "../../shared/auth";

/*
 * Busca todos os dados de uma startup com base no id
 */
export const getStartupDetails = onCall(async (req) => {
  getUserProfile(req);

  const { startupId } = req.data as GetStartupDetailsBodyDTO;
  const normalizedStartupId = normalizeString(startupId);

  getUserProfile(req);

  if (!normalizedStartupId) {
    throw new HttpsError("invalid-argument", "Invalid or null startup id!");
  }

  return await getFullStartup(startupId);
});
