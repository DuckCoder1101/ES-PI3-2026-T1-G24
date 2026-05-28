/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { GetTokenPriceHistoryRequestDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { getStartupTokenPriceHistory } from "../repositories/startupsRepository";
import { DateInterval, DateIntervals } from "../constants/dateInverval";

/*
 * Retorna o histórico de preço de tokens da startup
 * Usado nos gráficos
 */
export const getTokenPriceHistory = onCall(async (req) => {
  getAuthenticatedUser(req);

  const data = req.data as GetTokenPriceHistoryRequestDTO;

  const startupId = normalizeString(data.startupId);
  const interval = normalizeString(
    data.dateInterval,
  ).toLowerCase() as DateInterval;

  if (!startupId) {
    throw new HttpsError("invalid-argument", "ID de startup inválido ou nulo!");
  }

  if (!interval || !DateIntervals.includes(interval)) {
    throw new HttpsError(
      "invalid-argument",
      "Intervalo de datas inválido ou nulo!",
    );
  }

  logger.log(`[getTokenPriceHistory] startupId=${startupId} interval=${interval}`);
  const priceHistory = await getStartupTokenPriceHistory(startupId, interval);

  return {
    priceHistory,
  };
});
