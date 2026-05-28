/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { logger } from "firebase-functions/v2";
import { deleteOrderById } from "../repositories/orderRepository";

export const deleteOrder = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const orderId = normalizeString(req.data.orderId);

  if (!orderId) {
    throw new HttpsError("invalid-argument", "ID de ordem inválido!");
  }

  logger.log(`[deleteOrder] uid=${uid} orderId=${orderId}`);
  await deleteOrderById(orderId, uid);

  return {
    success: true,
  };
});
