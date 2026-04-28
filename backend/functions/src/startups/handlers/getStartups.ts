/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { normalizeString } from "../../shared/utils";
import { GetStartupsRequestBodyDTO, StartupsSearchFilter } from "../types/dtos";
import { StartupsSearchFilters } from "../shared/constants";
import { findAllStatups } from "../repositories/startupsRepository";

export const getStartups = onCall(async (req) => {
  const { filter, offset, limit } = req.data as GetStartupsRequestBodyDTO;
  const normalizedFilter = normalizeString(filter) as StartupsSearchFilter;

  if (!normalizedFilter || !StartupsSearchFilters.includes(normalizedFilter)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid or null filter! The filter must be 'all' | 'nova' | 'em_operacao' | 'em_expansao' ",
    );
  }

  if (!offset || typeof offset != "number" || offset < 0) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid or null search offset! The offset must be a number greater or equal then 0.",
    );
  }

  if (!limit || typeof limit != "number" || limit <= 0 || limit > 10) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid or null search limit! The limit must be a number between 0 and 10.",
    );

    const startups = await findAllStatups(offset, limit, filter);

    return {
      startups,
    };
  }
});
