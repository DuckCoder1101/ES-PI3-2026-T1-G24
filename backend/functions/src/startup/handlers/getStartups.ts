/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { normalizeString } from "../../shared/utils";
import { GetStartupsRequestBodyDTO, StartupStageFilter } from "../types/dtos";
import { StartupsSearchFilters } from "../shared/constants";
import { searchStartups } from "../repositories/startupsRepository";

/*
 * Busca todas as startups de um determinado intervalo e quantidade no banco
 * Este método usa infity scroll. É necessário informar um offset, um filtro e um limite!
 */
export const getStartups = onCall(async (req) => {
  const { filter, offset, limit } = req.data as GetStartupsRequestBodyDTO;

  const stage = normalizeString(filter.stage) as StartupStageFilter;
  const name = normalizeString(filter.name);

  if (!stage || !StartupsSearchFilters.includes(stage)) {
    throw new HttpsError("invalid-argument", "Filtro de busca inválido!");
  }

  if (typeof offset != "number" || offset < 0) {
    throw new HttpsError(
      "invalid-argument",
      "Offset inválido! O offset deve ser um número >= 0.",
    );
  }

  if (typeof limit != "number" || limit <= 0 || limit > 10) {
    throw new HttpsError(
      "invalid-argument",
      "Limite inválido! O limite deve ser um número entre 1 e 10.",
    );
  }

  const startups = await searchStartups(offset, limit, stage, name);

  return {
    startups,
  };
});
