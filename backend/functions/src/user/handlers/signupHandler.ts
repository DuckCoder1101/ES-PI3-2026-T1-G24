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
import { createUserAccount, existsByCpf } from "../repositories/userRepository";
import { getUserProfile } from "../../shared/auth";

/**
 * @name signup
 * Verifica se a autenticação já foi criada no FirebaseAuth
 * Verifica os dados da requisição
 * Se tudo estiver válido, chama a função de cadastro no repositório e salva a sessão
 */
export const signup = onCall(async (request) => {
  const { uid, email } = getUserProfile(request);
  const data = request.data as UserSignupDTO;

  const name = normalizeString(data.name);
  const cpf = normalizeString(data.cpf);
  const phone = normalizeString(data.phone);

  // Mapa de erros
  const fieldErrors: Record<string, string> = {};

  if (!name) fieldErrors.name = "Nome não informado!";
  if (!checkCPF(cpf)) fieldErrors.cpf = "CPF inválido!";
  if (!checkPhone(phone)) fieldErrors.phone = "Celular inválido!";

  if (await existsByCpf(cpf)) fieldErrors.cpf = "CPF já utilizado!";

  if (Object.keys(fieldErrors).length > 0) {
    console.log(
      "Erros ao criar usuário: " + Object.values(fieldErrors).join(", "),
    );
    admin.auth().deleteUser(uid);

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
