/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import admin from "firebase-admin";
import { HttpsError } from "firebase-functions/https";
import { FieldValue } from "firebase-admin/firestore";
import { database } from "../../shared/firebase";
import { OrderDocument, OrderType } from "../types/documents";
import { OrderListDTO, OrderRegisterDTO } from "../types/dtos";
import { InvestmentDocument, WalletDocument } from "../../user/types/documents";
import { StartupResumeDTO } from "../../startup/types/dtos";
import { formatCurrency } from "../../shared/formatters";

const getInvestmentsCollection = (uid: string) =>
  database.collection("investments").doc(uid).collection("startups");

const walletsCollection = database.collection("wallets");
const ordersCollection = database.collection("orders");
const transactionsCollection = database.collection("transactions");
const startupsCollection = database.collection("startups");

/*
 * Pesquisa todas as ordens de compra ou de venda, de acordo com o filtro
 */
export const findOrdersByOrderType = async (
  orderType: OrderType,
  userUId: string,
  offset: number,
  limit: number,
): Promise<OrderListDTO[]> => {
  const snapshot = await ordersCollection
    .where("type", "==", orderType)
    .orderBy("createdAt", "desc")
    .offset(offset)
    .limit(limit)
    .get();

  const orders = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as OrderDocument),
  }));

  // IDs únicos das startups
  const startupIds = [...new Set(orders.map((order) => order.startupId))];

  // Busca apenas startups necessárias
  const startupsSnapshot = startupIds.length
    ? await startupsCollection
        .where(admin.firestore.FieldPath.documentId(), "in", startupIds)
        .select("name")
        .get()
    : null;

  const startups: Record<string, StartupResumeDTO> = {};

  startupsSnapshot?.docs.forEach((doc) => {
    startups[doc.id] = {
      ...(doc.data() as StartupResumeDTO),
      id: doc.id,
    };
  });

  const fullOrders = orders.map((order) => ({
    ...order,
    isAuthor: order.authorUId === userUId,
    startup: startups[order.startupId],
  }));

  return fullOrders;
};

/*
 * Pesquisa todas as ordens criadas por um usuário
 */
export const findUserOrders = async (
  userUId: string,
): Promise<OrderListDTO[]> => {
  const snapshot = await ordersCollection
    .where("authorUId", "==", userUId)
    .orderBy("createdAt", "desc")
    .get();

  const orders = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as OrderDocument),
  }));

  const startupIds = [...new Set(orders.map((order) => order.startupId))];

  const startupsSnapshot = startupIds.length
    ? await startupsCollection
        .where(admin.firestore.FieldPath.documentId(), "in", startupIds)
        .select("name")
        .get()
    : null;

  const startups: Record<string, StartupResumeDTO> = {};

  startupsSnapshot?.docs.forEach((doc) => {
    startups[doc.id] = {
      ...(doc.data() as StartupResumeDTO),
      id: doc.id,
    };
  });

  return orders.map((order) => ({
    ...order,
    isAuthor: true,
    startup: startups[order.startupId],
  }));
};

/*
 * Salva uma nova ordem de compra ou de venda.
 * Para ordem de compra: bloqueia os fundos correspondentes na carteira.
 * Para ordem de venda: bloqueia os tokens correspondentes no investimento.
 */
export const saveOrder = async (order: OrderRegisterDTO): Promise<void> => {
  await database.runTransaction(async (tx) => {
    const orderRef = ordersCollection.doc();
    const startupRef = await startupsCollection.doc(order.startupId).get();

    if (!startupRef.exists) {
      throw new HttpsError("not-found", "Startup não econtrada!");
    }

    if (order.type === "buy") {
      const walletRef = walletsCollection.doc(order.authorUId);
      const walletDoc = await tx.get(walletRef);

      if (!walletDoc.exists) {
        throw new HttpsError("not-found", "Carteira não encontrada!");
      }

      const wallet = walletDoc.data() as WalletDocument;
      const lockedFunds = order.pricePerTokenCents * order.tokenAmount;

      // Verifica se o usuário possui fundos suficientes para garantir a ordem de compra
      if (wallet.fundsCents < lockedFunds) {
        throw new HttpsError(
          "out-of-range",
          `Você não possui fundos suficientes para a ordem de compra! Seu saldo é ${formatCurrency(wallet.fundsCents)}`,
        );
      }

      // Bloqueia os fundos da carteira enquanto a ordem estiver ativa
      tx.update(walletRef, {
        fundsCents: FieldValue.increment(-lockedFunds),
        lockedFundsCents: FieldValue.increment(lockedFunds),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      const investmentRef = getInvestmentsCollection(order.authorUId).doc(
        order.startupId,
      );
      const investmentDoc = await tx.get(investmentRef);

      if (!investmentDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Você não possui tokens dessa startup!",
        );
      }

      const investment = investmentDoc.data() as InvestmentDocument;

      // Verifica se o usuário possui tokens suficientes para garantir a ordem de venda
      if (investment.tokenAmount < order.tokenAmount) {
        throw new HttpsError(
          "out-of-range",
          `Você não possui tokens suficientes para a ordem de venda! Você possui: ${investment.tokenAmount} tokens.`,
        );
      }

      // Bloqueia os tokens enquanto a ordem de venda estiver ativa
      tx.update(investmentRef, {
        tokenAmount: FieldValue.increment(-order.tokenAmount),
        lockedTokenAmount: FieldValue.increment(order.tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    tx.set(orderRef, {
      ...order,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Cancela e remove uma ordem existente do usuário.
 * Devolve os fundos bloqueados (compra) ou os tokens bloqueados (venda).
 */
export const deleteOrderById = async (
  orderId: string,
  userUId: string,
): Promise<void> => {
  await database.runTransaction(async (tx) => {
    const orderRef = ordersCollection.doc(orderId);
    const doc = await tx.get(orderRef);

    if (!doc.exists) {
      throw new HttpsError("not-found", "Ordem não encontrada!");
    }

    const order = doc.data() as OrderDocument;

    if (order.authorUId !== userUId) {
      throw new HttpsError(
        "permission-denied",
        "Você não tem permissão para apagar a ordem de outro usuário!",
      );
    }

    if (order.type === "buy") {
      const walletRef = walletsCollection.doc(order.authorUId);
      const walletDoc = await tx.get(walletRef);

      if (!walletDoc.exists) {
        throw new HttpsError("not-found", "Carteira não encontrada!");
      }

      const lockedFunds = order.pricePerTokenCents * order.tokenAmount;

      // Devolve os fundos bloqueados ao cancelar a ordem de compra
      tx.update(walletRef, {
        fundsCents: FieldValue.increment(lockedFunds),
        lockedFundsCents: FieldValue.increment(-lockedFunds),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      const investmentRef = getInvestmentsCollection(order.authorUId).doc(
        order.startupId,
      );
      const investmentDoc = await tx.get(investmentRef);

      if (!investmentDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Investimento não encontrado para estorno dos tokens!",
        );
      }

      // Devolve os tokens bloqueados ao cancelar a ordem de venda
      tx.update(investmentRef, {
        tokenAmount: FieldValue.increment(order.tokenAmount),
        lockedTokenAmount: FieldValue.increment(-order.tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    tx.delete(orderRef);
  });
};

/*
 * Executa a compra direta de tokens a partir de uma ordem de venda existente no balcão.
 * O comprador paga com fundos da carteira; o vendedor recebe os fundos e libera os tokens bloqueados.
 */
export const executeBuyFromOrder = async (
  orderId: string,
  buyerUId: string,
): Promise<void> => {
  const orderRef = ordersCollection.doc(orderId);
  const orderDoc = await orderRef.get();

  if (!orderDoc.exists) {
    throw new HttpsError("not-found", "Ordem não encontrada!");
  }

  const order = orderDoc.data() as OrderDocument;

  if (order.type !== "sell") {
    throw new HttpsError(
      "invalid-argument",
      "Essa ordem não é uma ordem de venda!",
    );
  }

  if (order.authorUId === buyerUId) {
    throw new HttpsError(
      "invalid-argument",
      "Você não pode comprar sua própria ordem de venda!",
    );
  }

  const totalCents = order.pricePerTokenCents * order.tokenAmount;
  const buyerWalletRef = walletsCollection.doc(buyerUId);
  const sellerWalletRef = walletsCollection.doc(order.authorUId);
  const buyerInvestmentRef = getInvestmentsCollection(buyerUId).doc(
    order.startupId,
  );
  const sellerInvestmentRef = getInvestmentsCollection(order.authorUId).doc(
    order.startupId,
  );

  await database.runTransaction(async (tx) => {
    const buyerWalletDoc = await tx.get(buyerWalletRef);
    const sellerWalletDoc = await tx.get(sellerWalletRef);
    const buyerInvestmentDoc = await tx.get(buyerInvestmentRef);
    const sellerInvestmentDoc = await tx.get(sellerInvestmentRef);

    if (!buyerWalletDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Carteira do comprador não encontrada!",
      );
    }

    const buyerWallet = buyerWalletDoc.data() as WalletDocument;

    // Verifica se o comprador possui saldo suficiente
    if (buyerWallet.fundsCents < totalCents) {
      throw new HttpsError(
        "out-of-range",
        `Saldo insuficiente para realizar a compra! Seu saldo é ${formatCurrency(buyerWallet.fundsCents)}`,
      );
    }

    // Debita os fundos do comprador
    tx.update(buyerWalletRef, {
      fundsCents: FieldValue.increment(-totalCents),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Credita os fundos ao vendedor
    if (sellerWalletDoc.exists) {
      tx.update(sellerWalletRef, {
        fundsCents: FieldValue.increment(totalCents),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(sellerWalletRef, {
        fundsCents: totalCents,
        lockedFundsCents: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Credita os tokens ao comprador
    if (buyerInvestmentDoc.exists) {
      tx.update(buyerInvestmentRef, {
        tokenAmount: FieldValue.increment(order.tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(buyerInvestmentRef, {
        startupId: order.startupId,
        tokenAmount: order.tokenAmount,
        lockedTokenAmount: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Libera os tokens bloqueados do vendedor (ordem executada)
    if (sellerInvestmentDoc.exists) {
      tx.update(sellerInvestmentRef, {
        lockedTokenAmount: FieldValue.increment(-order.tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Remove a ordem do balcão
    tx.delete(orderRef);

    // Registra a transação de trade
    const transactionRef = transactionsCollection.doc();
    tx.set(transactionRef, {
      type: "trade",
      purchaserUId: buyerUId,
      sellerUId: order.authorUId,
      startupId: order.startupId,
      tokensPurchased: order.tokenAmount,
      tokenPriceCents: order.pricePerTokenCents,
      amountCents: totalCents,
      userUIds: [buyerUId, order.authorUId],
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};

/*
 * Executa a venda de tokens para uma ordem de compra existente no balcão.
 * O vendedor entrega os tokens; os fundos bloqueados do comprador são liberados ao vendedor.
 */
export const executeSellToOrder = async (
  orderId: string,
  sellerUId: string,
): Promise<void> => {
  const orderRef = ordersCollection.doc(orderId);
  const orderDoc = await orderRef.get();

  if (!orderDoc.exists) {
    throw new HttpsError("not-found", "Ordem não encontrada!");
  }

  const order = orderDoc.data() as OrderDocument;

  if (order.type !== "buy") {
    throw new HttpsError(
      "invalid-argument",
      "Essa ordem não é uma ordem de compra!",
    );
  }

  if (order.authorUId === sellerUId) {
    throw new HttpsError(
      "invalid-argument",
      "Você não pode vender para sua própria ordem de compra!",
    );
  }

  const totalCents = order.pricePerTokenCents * order.tokenAmount;
  const buyerWalletRef = walletsCollection.doc(order.authorUId);
  const sellerWalletRef = walletsCollection.doc(sellerUId);
  const buyerInvestmentRef = getInvestmentsCollection(order.authorUId).doc(
    order.startupId,
  );
  const sellerInvestmentRef = getInvestmentsCollection(sellerUId).doc(
    order.startupId,
  );

  await database.runTransaction(async (tx) => {
    const sellerInvestmentDoc = await tx.get(sellerInvestmentRef);
    const buyerWalletDoc = await tx.get(buyerWalletRef);
    const sellerWalletDoc = await tx.get(sellerWalletRef);
    const buyerInvestmentDoc = await tx.get(buyerInvestmentRef);

    if (!sellerInvestmentDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Você não possui tokens dessa startup!",
      );
    }

    const sellerInvestment = sellerInvestmentDoc.data() as InvestmentDocument;

    // Verifica se o vendedor possui tokens suficientes
    if (sellerInvestment.tokenAmount < order.tokenAmount) {
      throw new HttpsError(
        "out-of-range",
        `Tokens insuficientes! Você possui: ${sellerInvestment.tokenAmount} tokens.`,
      );
    }

    // Debita os tokens do vendedor
    tx.update(sellerInvestmentRef, {
      tokenAmount: FieldValue.increment(-order.tokenAmount),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Credita os tokens ao comprador
    if (buyerInvestmentDoc.exists) {
      tx.update(buyerInvestmentRef, {
        tokenAmount: FieldValue.increment(order.tokenAmount),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(buyerInvestmentRef, {
        startupId: order.startupId,
        tokenAmount: order.tokenAmount,
        lockedTokenAmount: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Libera os fundos bloqueados do comprador (ordem executada)
    if (buyerWalletDoc.exists) {
      tx.update(buyerWalletRef, {
        lockedFundsCents: FieldValue.increment(-totalCents),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Credita os fundos ao vendedor
    if (sellerWalletDoc.exists) {
      tx.update(sellerWalletRef, {
        fundsCents: FieldValue.increment(totalCents),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(sellerWalletRef, {
        fundsCents: totalCents,
        lockedFundsCents: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Remove a ordem do balcão
    tx.delete(orderRef);

    // Registra a transação de trade
    const transactionRef = transactionsCollection.doc();
    tx.set(transactionRef, {
      type: "trade",
      purchaserUId: order.authorUId,
      sellerUId: sellerUId,
      startupId: order.startupId,
      tokensPurchased: order.tokenAmount,
      tokenPriceCents: order.pricePerTokenCents,
      amountCents: totalCents,
      userUIds: [order.authorUId, sellerUId],
      createdAt: FieldValue.serverTimestamp(),
    });
  });
};
