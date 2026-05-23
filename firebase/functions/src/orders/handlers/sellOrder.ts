/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { executeSellToOrder } from "../repositories/orderRepository";

/*
 * Executa a venda de tokens para uma ordem de compra existente no balcão.
 * O vendedor entrega os tokens e recebe os fundos bloqueados pelo comprador.
 */
export const sellOrder = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const orderId = normalizeString(req.data.orderId);

  if (!orderId) {
    throw new HttpsError("invalid-argument", "ID de ordem inválido!");
  }

  await executeSellToOrder(orderId, uid);

  return {
    success: true,
  };
});
