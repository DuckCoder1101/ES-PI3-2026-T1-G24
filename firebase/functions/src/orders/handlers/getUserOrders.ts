/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import { findUserOrders } from "../repositories/orderRepository";
import { getAuthenticatedUser } from "../../shared/auth";

/**
 * Retorna todas as ordens criadas pelo usuário
 */
export const getUserOrders = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);
  logger.log(`[getUserOrders] uid=${uid}`);
  const orders = await findUserOrders(uid);

  return {
    orders,
  };
});
