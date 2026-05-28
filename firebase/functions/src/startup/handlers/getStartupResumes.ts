/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { logger } from "firebase-functions/v2";
import { findStartupsResumes } from "../repositories/startupsRepository";

/*
 * Retorna lista resumida de todas as startups (id, nome, isInvestor).
 * Usada para popular dropdowns e seletores no app.
 */
export const getStartupResumes = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  logger.log(`[getStartupResumes] uid=${uid}`);
  const startups = await findStartupsResumes(uid);

  return { startups };
});
