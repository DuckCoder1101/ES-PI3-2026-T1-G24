/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions";
import admin from "firebase-admin";

import { normalizeString } from "../../shared/utils";
import { checkCPF, checkPhone } from "../shared/validations";

import { UserSignupDTO } from "../types/dtos";
import { createUserAccount } from "../repositories/usersRepository";
import { getAuthenticatedUser } from "../../shared/auth";

/*
 * Verifica se a autenticação já foi criada no FirebaseAuth
 * Verifica os dados da requisição
 * Se tudo estiver válido, chama a função de cadastro no repositório e salva a sessão
 */
export const signup = onCall(async (request) => {
  const { uid, email } = getAuthenticatedUser(request);
  const data = request.data as UserSignupDTO;

  const name = normalizeString(data.name);
  const cpf = normalizeString(data.cpf).replace(/\D/g, "");
  const phone = normalizeString(data.phone).replace(/\D/g, "");

  // Mapa de erros
  const fieldErrors: Record<string, string> = {};

  if (!name) fieldErrors.name = "Nome não informado!";
  if (!checkCPF(cpf)) fieldErrors.cpf = "CPF inválido!";
  if (!checkPhone(phone)) fieldErrors.phone = "Celular inválido!";

  if (Object.keys(fieldErrors).length > 0) {
    await admin.auth().deleteUser(uid);

    throw new HttpsError(
      "invalid-argument",
      "Informações inválidas ou faltantes!",
      fieldErrors,
    );
  }

  await createUserAccount(uid, {
    name,
    cpf,
    phone,
    email,
  });

  logger.log("Usuário cadastrado: " + uid);

  return {
    success: true,
  };
});
