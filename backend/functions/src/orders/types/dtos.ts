import { OrderDocument, OrderType } from "./documents";

export interface OrderListDTO extends OrderDocument {
  id: string;
  isAuthor: boolean;
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
