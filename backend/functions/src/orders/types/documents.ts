/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";

export type OrderType = "buy" | "sell";

export interface OrderDocument {
  authorUId: string;
  startupId: string;
  type: OrderType;
  pricePerTokenCents: number;
  tokenAmount: number;
  createdAt: Timestamp;
}