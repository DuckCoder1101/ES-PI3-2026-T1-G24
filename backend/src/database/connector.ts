import admin from "firebase-admin";

let serviceAccount: admin.ServiceAccount;

try {
  // Tenta carregar o arquivo de credenciais
  const module = await import("../config/fire-store-keys.json", {
    with: { type: "json" },
  });

  serviceAccount = module.default as admin.ServiceAccount;
} catch {
  // Exibe um erro caso o arquivo não exista
  throw new Error(
    "Arquivo de credenciais do Firebase não encontrado. Verifique se 'fire-store-keys.json' existe na pasta src/config.",
  );
}

// Conecta com o banco de dados
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const db = admin.firestore();
