/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";

import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { orderTypes } from "../shared/constants";

import { saveOrder } from "../repositories/orderRepository";

import { OrderType } from "../types/documents";
import { OrderRegisterRequestDTO } from "../types/dtos";

/*
 * Registra uma nova ordem de compra ou de venda no balcão.
 * Para ordem de compra: bloqueia o valor correspondente na carteira.
 * Para ordem de venda: bloqueia os tokens correspondentes no investimento.
 */
export const registerOrder = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const order = req.data as OrderRegisterRequestDTO;
  const orderType = normalizeString(order.type).toLowerCase() as OrderType;

  if (!order.startupId) {
    throw new HttpsError("invalid-argument", "ID de stratup inválido!");
  }

  if (!orderType || !orderTypes.includes(orderType)) {
    throw new HttpsError("invalid-argument", "Tipo de ordem inválido!");
  }

  if (typeof order.tokenAmount !== "number" || order.tokenAmount <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "A quantidade de tokens deve ser um número maior que 0.",
    );
  }

  if (
    typeof order.pricePerTokenCents !== "number" ||
    order.pricePerTokenCents <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "O valor de cada token deve ser um número maior que 0.",
    );
  }

  await saveOrder({
    ...order,
    authorUId: uid,
    type: orderType,
  });

  return {
    success: true,
  };
});
