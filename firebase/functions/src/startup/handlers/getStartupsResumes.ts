/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { getUserProfile } from "../../shared/auth";
import { findStartupsResumes } from "../repositories/startupsRepository";

/*
 * Retorna uma lista resumida de todas as startups (id e nome).
 * Usada para popular dropdowns e seletores no app.
 */
export const getStartupResumes = onCall(async (req) => {
  getUserProfile(req);

  const startups = await findStartupsResumes();

  return {
    startups,
  };
});
