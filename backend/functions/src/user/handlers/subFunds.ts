import { HttpsError, onCall } from "firebase-functions/https";
import { subUserFunds } from "../repositories/userRepository";
import { getUserProfile } from "../../shared/auth";

export const addFunds = onCall(async (req) => {
  const { uid } = getUserProfile(req);
  const funds = req.data["funds"] as number;

  if (!funds || typeof funds != "number" || funds < 0) {
    throw new HttpsError("invalid-argument", "Valor inválido!");
  }

  await subUserFunds(uid, funds);

  return {
    success: true,
  };
});
