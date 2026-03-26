import express from "express";
import cors from "cors";

// Instancia da aplicação
const app = express();

// Habilita o Cross-Origin
app.use(
  cors({
    credentials: true,
    origin: "*",
  }),
);

// Sinaliza que a API usa JSON
app.use(express.json());

// Rota de ping
app.use("/ping", (req, res) => {
  res.status(200).json({
    message: "Pong!",
  });
});

export default app;
