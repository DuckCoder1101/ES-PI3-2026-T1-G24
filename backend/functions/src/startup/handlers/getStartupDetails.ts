/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { GetStartupDetailsBodyDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { getFullStartup } from "../repositories/startupsRepository";
import { getUserProfile } from "../../shared/auth";
import { database } from "../../shared/firebase";

/*
 * Busca todos os dados de uma startup com base no id.
 * Também retorna se o usuário autenticado já é investidor da startup,
 * para que o frontend possa controlar o acesso ao Q&A privado.
 */
export const getStartupDetails = onCall(async (req) => {
  const { uid } = getUserProfile(req);

  const { startupId } = req.data as GetStartupDetailsBodyDTO;
  const normalizedStartupId = normalizeString(startupId);

  if (!normalizedStartupId) {
    throw new HttpsError("invalid-argument", "Invalid or null startup id!");
  }

  const [startup, investmentDoc] = await Promise.all([
    getFullStartup(startupId),
    database
      .collection("investments")
      .doc(uid)
      .collection("startups")
      .doc(startupId)
      .get(),
  ]);

  return {
    ...startup,
    isInvestor: investmentDoc.exists,
  };
});
