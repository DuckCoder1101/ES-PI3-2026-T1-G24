/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */
import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/https";
import { updateUserData } from "../repositories/usersRepository";
import { UpdateProfileDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { checkPhone } from "../shared/validations";
import { getAuthenticatedUser } from "../../shared/auth";

/*
 * Atualiza as informações do perfil do usuário
 * Nome e telefone
 */
export const updateProfile = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);
  const data = req.data as UpdateProfileDTO;

  data.name = normalizeString(data.name).toLowerCase();
  data.phone = normalizeString(data.phone).replace(/\D/g, "");

  if (!checkPhone(data.phone)) {
    throw new HttpsError("invalid-argument", "Número de telefone inválido!");
  }

  logger.log("Atualizando informações do usuário: " + uid);

  await updateUserData(uid, data);
});
