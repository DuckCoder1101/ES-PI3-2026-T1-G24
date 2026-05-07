import { HttpsError, onCall } from "firebase-functions/https";
import { addUserFunds } from "../repositories/userRepository";
import { getUserProfile } from "../../shared/auth";

export const addFunds = onCall(async (req) => {
  const { uid } = getUserProfile(req);
  const funds = req.data["funds"] as number;

  if (!funds || typeof funds != "number" || funds < 10) {
    throw new HttpsError(
      "invalid-argument",
      "Valor inválido! Os valor mínimo é R$ 10,00.",
    );
  }

  await addUserFunds(uid, funds);

  return {
    success: true,
  };
});
