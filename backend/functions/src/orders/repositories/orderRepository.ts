import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { OrderDocument, OrderStatus, OrderType } from "../types/documents";
import { OrderListDTO, OrderRegisterDTO } from "../types/dtos";
import { HttpsError } from "firebase-functions/https";

const ordersCollection = database.collection("orders");

/*
 * Pesquisa todas as ordens de compra ou de venda, de acordo com o filtro
 */
export const findAllOrders = async (
  orderType: OrderType,
  userUId: string,
  offset: number,
  limit: number,
): Promise<OrderDocument[]> => {
  const snapshot = await ordersCollection
    .where("type", "==", orderType)
    .offset(offset)
    .limit(limit)
    .get();

  const orders = snapshot.docs.map((doc) => {
    const order = doc.data() as OrderDocument;

    return {
      id: doc.id,
      isAuthor: order.authorUId == userUId,
      ...order,
    };
  }) satisfies OrderListDTO[];

  return orders;
};

/*
 * Pesquisa todas as ordens criadas por um usuário
 */
export const findUserOrders = async (
  userUId: string,
): Promise<OrderListDTO[]> => {
  const snapshot = await ordersCollection
    .where("authorUId", "==", userUId)
    .get();

  const orders = snapshot.docs.map((doc) => {
    const order = doc.data() as OrderDocument;

    return {
      id: doc.id,
      isAuthor: true,
      ...order,
    };
  }) satisfies OrderListDTO[];

  return orders;
};

/*
 * Salva uma nova ordem
 */
export const saveOrder = async (order: OrderRegisterDTO): Promise<void> => {
  await ordersCollection.add({
    ...order,
    status: "open",
    createdAt: FieldValue.serverTimestamp(),
  });
};

/*
 * Altera o status de uma ordem
 */
export const setOrderStatus = async (
  orderId: string,
  status: OrderStatus,
): Promise<void> => {
  const ref = ordersCollection.doc(orderId);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Ordem não encontrada!");
  }

  await ref.set({ status }, { merge: true });
};

/*
 * Deleta uma ordem
 */
export const deleteOrder = async (orderId: string): Promise<void> => {
  const ref = ordersCollection.doc(orderId);
  const doc = await ref.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "Ordem não encontrada!");
  }

  await ref.delete();
};
