import type { Request, Response } from "express";

/**
 * @name PingController
 * @description Rota de ping. Apenas retorna pong!
 * @returns {void}
 */
export function PingController(_req: Request, res: Response) {
  res.status(200).json({
    message: "Pong! API funcionando.",
  });
}
