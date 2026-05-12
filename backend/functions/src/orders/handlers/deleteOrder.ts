/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { getUserProfile } from "../../shared/auth";
import { normalizeString } from "../../shared/utils";
import { deleteOrderById } from "../repositories/orderRepository";

export const deleteOrder = onCall(async (req) => {
  const { uid } = getUserProfile(req);

  const orderId = normalizeString(req.data.orderId);

  if (!orderId) {
    throw new HttpsError("invalid-argument", "ID de ordem inválido!");
  }

  await deleteOrderById(orderId, uid);

  return {
    success: true,
  };
});