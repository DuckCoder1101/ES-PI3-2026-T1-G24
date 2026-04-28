import { HttpsError, onCall } from "firebase-functions/https";
import { GetStartupDetailsBodyDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { getFullStartup } from "../repositories/startupsRepository";

export const getStartupDetails = onCall(async (req) => {
  const { startupId } = req.data as GetStartupDetailsBodyDTO;
  const normalizedStartupId = normalizeString(startupId);

  if (!normalizedStartupId) {
    throw new HttpsError("invalid-argument", "Invalid or null startup id!");
  }

  const startup = await getFullStartup(startupId);
  return startup;
});
