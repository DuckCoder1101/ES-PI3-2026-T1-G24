/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { normalizeString } from "../../shared/utils";
import { GetStartupsRequestBodyDTO } from "../types/dtos";
import { logger } from "firebase-functions/v2";
import { findStartups } from "../repositories/startupsRepository";
import { getAuthenticatedUser } from "../../shared/auth";
import {
  StartupsSearchFilters,
  StartupStageFilter,
} from "../constants/startupStageFilters";

/*
 * Busca startups com paginação (infinity scroll).
 */
export const getStartupsList = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const { filter, offset, limit } = req.data as GetStartupsRequestBodyDTO;

  const stage = normalizeString(
    filter.stage,
  ).toLowerCase() as StartupStageFilter;
  const name = normalizeString(filter.name).toLowerCase();

  if (!stage || !StartupsSearchFilters.includes(stage)) {
    throw new HttpsError("invalid-argument", "Filtro de busca inválido!");
  }

  if (typeof offset !== "number" || offset < 0) {
    throw new HttpsError(
      "invalid-argument",
      "Offset inválido! O offset deve ser um número >= 0.",
    );
  }

  if (typeof limit !== "number" || limit <= 0 || limit > 10) {
    throw new HttpsError(
      "invalid-argument",
      "Limite inválido! O limite deve ser um número entre 1 e 10.",
    );
  }

  logger.log(`[getStartupsList] uid=${uid} stage=${stage} name="${name}" offset=${offset} limit=${limit}`);
  const startups = await findStartups(uid, offset, limit, stage, name);

  return { startups };
});
