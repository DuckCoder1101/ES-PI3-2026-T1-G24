import { db } from "./connector.js";

/**
 * @name TestDatabase
 * @description Testa o banco de dados Firebase, em caso de sucesso grava um registro em tests
 * @returns {Promise<void>}
 */
export async function TestDatabase(): Promise<void> {
  const doc = await db.collection("test").add({
    message: "Firebase funcionando",
    date: new Date(),
  });

  console.log("Teste criado:", doc.id);
}
