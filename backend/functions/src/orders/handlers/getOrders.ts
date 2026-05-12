/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { GetOrdersRequestDTO } from "../types/dtos";
import { normalizeString } from "../../shared/utils";
import { OrderType } from "../types/documents";
import { orderTypes } from "../shared/constants";
import { findAllOrders } from "../repositories/orderRepository";
import { getUserProfile } from "../../shared/auth";

export const getOrders = onCall(async (req) => {
  const { uid } = getUserProfile(req);

  let { orderType, offset, limit } = req.data as GetOrdersRequestDTO;
  orderType = normalizeString(orderType).toLowerCase() as OrderType;

  if (!orderType || !orderTypes.includes(orderType)) {
    throw new HttpsError(
      "invalid-argument",
      "Filtro de tipo de ordem inválido!",
    );
  }

  if (typeof offset != "number" || offset < 0) {
    throw new HttpsError(
      "invalid-argument",
      "Offset inválido! O offset deve ser um número >= 0.",
    );
  }

  if (typeof limit != "number" || limit <= 0 || limit > 10) {
    throw new HttpsError(
      "invalid-argument",
      "Limite inválido! O limite deve ser um número entre 1 e 10.",
    );
  }

  const orders = await findAllOrders(orderType, uid, offset, limit);

  return {
    orders,
  };
});