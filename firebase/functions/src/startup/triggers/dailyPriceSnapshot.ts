/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";

import {
  InvestmentTransaction,
  TradeTransaction,
} from "../../transaction/types/documents";

import {
  getAllStartupsTokenInfo,
  getStartupTransactionsSince,
  updateTokenHistory,
} from "../repositories/startupsRepository";

/*
 * Executa todo dia às 23:59
 */
export const dailyPriceSnapshot = onSchedule(
  {
    schedule: "59 23 * * *",
    timeZone: "America/Sao_Paulo",
  },
  async () => {
    logger.log("Iniciando snapshot diário de preços.");

    const startups = await getAllStartupsTokenInfo();

    // Início do dia corrente (meia-noite) — janela para buscar transações do dia
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const results = await Promise.allSettled(
      startups.map(async (startup) => {
        const transactions = await getStartupTransactionsSince(
          startup.id,
          startOfDay,
        );

        let priceCents: number;

        if (transactions.length === 0) {
          /*
           * Sem transações no dia: repete o preço atual para que o gráfico não tenha lacunas
           */
          priceCents = startup.currentTokenPriceCents;

          logger.log(
            `[${startup.id}] Sem transações — carregando preço atual: ${priceCents}¢`,
          );
        } else {
          /*
           * Calcula o VWAP do dia considerando investment e trade.
           * Ambos os tipos têm tokenPriceCents e tokensPurchased.
           */
          let totalVolume = 0;
          let totalValue = 0;

          for (const tx of transactions) {
            if (tx.type === "investment") {
              const inv = tx as InvestmentTransaction;
              totalVolume += inv.tokensPurchased;
              totalValue += inv.tokenPriceCents * inv.tokensPurchased;
            } else if (tx.type === "trade") {
              const trade = tx as TradeTransaction;
              totalVolume += trade.tokensPurchased;
              totalValue += trade.tokenPriceCents * trade.tokensPurchased;
            }
          }

          priceCents =
            totalVolume > 0
              ? Math.round(totalValue / totalVolume)
              : startup.currentTokenPriceCents;

          logger.log(
            `[${startup.id}] VWAP do dia: ${priceCents}¢ ` +
              `(${transactions.length} transações, volume: ${totalVolume} tokens)`,
          );
        }

        const occupancyRate =
          startup.totalTokensIssued > 0
            ? (startup.totalTokensIssued - startup.totalTokensAvailable) /
              startup.totalTokensIssued
            : 0;

        updateTokenHistory(startup.id, priceCents, occupancyRate);
      }),
    );

    // Loga falhas individuais sem derrubar o job inteiro
    results.forEach((result, i) => {
      if (result.status === "rejected") {
        logger.error(
          `Falha no snapshot da startup [${startups[i]?.id}]:`,
          result.reason,
        );
      }
    });

    const succeeded = results.filter((r) => r.status === "fulfilled").length;
    logger.log(
      `Snapshot diário concluído: ${succeeded}/${startups.length} startups processadas.`,
    );
  },
);
