import { Timestamp } from "firebase-admin/firestore";

export type OrderType = "buy" | "sell";
export type OrderStatus = "open" | "completed" | "cancelled";

export interface OrderDocument {
  authorUId: string;
  startupId: string;
  type: OrderType;
  pricePerTokenCents: number;
  tokenAmount: number;
  status: OrderStatus;
  createdAt: Timestamp;
}
