/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onCall } from "firebase-functions/https";
import { logger } from "firebase-functions/v2";
import { findUserOrders } from "../repositories/orderRepository";
import { getAuthenticatedUser } from "../../shared/auth";
import {
  StartupStageFilter,
  StartupsSearchFilters,
} from "../../startup/constants/startupStageFilters";

/**
 * Retorna todas as ordens criadas pelo usuário, com filtro opcional de estágio de startup
 */
export const getUserOrders = onCall(async (req) => {
  const { uid } = getAuthenticatedUser(req);

  const { stage } = (req.data ?? {}) as { stage?: string };
  const stageFilter: StartupStageFilter =
    stage && StartupsSearchFilters.includes(stage as StartupStageFilter)
      ? (stage as StartupStageFilter)
      : "all";

  logger.log(`[getUserOrders] uid=${uid} stage=${stageFilter}`);
  const orders = await findUserOrders(uid, stageFilter);

  return {
    orders,
  };
});
