/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { findStartupNews } from "../repositories/newsRepository";

/*
 * Retorna as notícias/atualizações de uma startup.
 */
export const getStartupNews = onCall(async (req) => {
  getAuthenticatedUser(req);

  const { startupId } = req.data;

  if (!startupId) {
    throw new HttpsError("invalid-argument", "startupId ausente.");
  }

  const news = await findStartupNews(startupId);

  return {
    news,
  };
});
