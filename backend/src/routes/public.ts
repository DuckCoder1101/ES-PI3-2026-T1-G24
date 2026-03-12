import { Router } from "express";

import { SigninController } from "@controllers/auth/signin-service.js";
import { SignupController } from "@controllers/auth/signup-controller.js";
import { PingController } from "@controllers/ping.js";

export const publicRoutes = Router();

// Rota de ping
publicRoutes.get("/ping", PingController);

// Rotas de autenticação
publicRoutes.post("/auth/signin", SigninController);
publicRoutes.post("/auth/signup", SignupController);
