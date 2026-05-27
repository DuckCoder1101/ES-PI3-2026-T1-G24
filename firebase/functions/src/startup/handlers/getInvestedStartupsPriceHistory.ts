/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { getStartupTokenPriceHistory } from "../repositories/startupsRepository";
import { getInvestments } from "../../user/repositories/usersRepository";
import { StartupPriceSeriesDTO } from "../types/dtos";
import { DateInterval, DateIntervals } from "../constants/dateInverval";

/*
 * Retorna o histórico de preços de todas as startups nas quais o usuário possui tokens
 * usado no gráfico da Home.
 */
export const getInvestedStartupsPriceHistory = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const rawInterval = normalizeString(
    (req.data as { dateInterval: string }).dateInterval,
  ) as DateInterval;

  if (!rawInterval || !DateIntervals.includes(rawInterval)) {
    throw new HttpsError(
      "invalid-argument",
      "Intervalo de datas inválido ou nulo!",
    );
  }

  const investments = await getInvestments(uid);

  if (investments.length === 0) {
    return {
      startups: [],
    };
  }

  // Busca o histórico de cada startup em paralelo
  const series = await Promise.all(
    investments.map(async (inv) => {
      const priceHistory = await getStartupTokenPriceHistory(
        inv.startup.id,
        rawInterval,
      );

      return {
        startupId: inv.startup.id,
        startupName: inv.startup.name,
        priceHistory,
      } satisfies StartupPriceSeriesDTO;
    }),
  );

  // Remove startups sem histórico no período para não poluir o gráfico
  const filtered = series.filter((s) => s.priceHistory.length > 0);

  return { startups: filtered };
});
