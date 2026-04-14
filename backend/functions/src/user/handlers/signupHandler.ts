import { HttpsError, onCall } from "firebase-functions/https";

import { normalizeString } from "../shared/utils";
import { checkCPF, checkPhone } from "../shared/validations";

import { AppResponseDTO, UserSignupDTO } from "../types/dtos";
import { createUserAccount } from "../repositories/userRepository";
import { getUserProfile } from "../shared/auth";

/**
 * @name signup
 * Verifica se a autenticação já foi criada no FirebaseAuth
 * Verifica os dados da requisição
 * Se tudo estiver válido, chama a função de cadastro no repositório e salva a sessão
 */
export const signup = onCall(async (request): Promise<AppResponseDTO> => {
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

  if (Object.keys(fieldErrors).length > 0) {
    throw new HttpsError(
      "invalid-argument",
      "Informações inválidas ou faltantes!",
      { fieldErrors },
    );
  }

  await createUserAccount(uid, {
    name,
    cpf,
    phone,
    email,
  });

  return {
    success: true,
    data: {
      uid,
      name,
      cpf,
      phone,
      email,
    },
  };
});
