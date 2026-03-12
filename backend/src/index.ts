import http from "http";
import cors from "cors";
import express from "express";

// Rotas
import { publicRoutes } from "@routes/public.js";
import { privateRoutes } from "@routes/private.js";
// import { TestDatabase } from "@db/test.js";

// Cria a instancia do servidor
const app = express();
const server = http.createServer(app);

// Inicializa o cross origin resource sharing (CORS)
app.use(
  cors({
    credentials: true,
    origin: "localhost:8080",
  }),
);

// Faz a aplicação usar o json como formato de dados
app.use(express.json());

// Rotas públicas (signin, signup e ping)
app.use("/", publicRoutes);

// Rotas privadas (demais rotas)
app.use("/", privateRoutes);

// Teste do banco de dados
// void TestDatabase();

// Inicializa o servidor
server.listen(3000, () => {
  console.log("Server online on PORT 3000.");
});
