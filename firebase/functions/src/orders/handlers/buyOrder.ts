/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { logger } from "firebase-functions/v2";
import { executeBuyFromOrder } from "../repositories/orderRepository";

/*
 * Executa a compra de tokens a partir de uma ordem de venda existente no balcão.
 * O comprador paga com saldo da carteira e recebe os tokens imediatamente.
 */
export const buyOrder = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const orderId = normalizeString(req.data.orderId);

  if (!orderId) {
    throw new HttpsError("invalid-argument", "ID de ordem inválido!");
  }

  logger.log(`[buyOrder] uid=${uid} orderId=${orderId}`);
  await executeBuyFromOrder(orderId, uid);

  return {
    success: true,
  };
});
