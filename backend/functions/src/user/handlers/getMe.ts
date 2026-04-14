import { HttpsError, onCall } from "firebase-functions/https";
import { findUserById } from "../repositories/userRepository";
import { getUserProfile } from "../shared/auth";

/**
 * @name getMe
 * Verifica se o usuário está autenticado, e retorna os dados.
 */
export const getMe = onCall(async (request) => {
  const { uid } = getUserProfile(request);
  const user = await findUserById(uid);

  if (!user) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  return {
    user,
  };
});
