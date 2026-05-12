/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";
import { StartupResumeDTO } from "../../startup/types/dtos";
import { OrderType } from "./documents";

export interface OrderListDTO {
  id: string;
  isAuthor: boolean;
  authorUId: string;
  startup: StartupResumeDTO;
  type: OrderType;
  pricePerTokenCents: number;
  tokenAmount: number;
  createdAt: Timestamp;
}

export interface OrderRegisterDTO {
  authorUId: string;
  startupId: string;
  type: OrderType;
  pricePerTokenCents: number;
  tokenAmount: number;
}

export type OrderRegisterRequestDTO = Omit<OrderRegisterDTO, "authorUId">;

export interface GetOrdersRequestDTO {
  orderType: OrderType;
  offset: number;
  limit: number;
}
