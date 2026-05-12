/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { findUserOrders } from "../repositories/orderRepository";
import { getUserProfile } from "../../shared/auth";

export const getUserOrders = onCall(async (req) => {
  const { uid } = getUserProfile(req);
  const orders = await findUserOrders(uid);

  return {
    orders,
  };
});