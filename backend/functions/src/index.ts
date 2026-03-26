import { setGlobalOptions } from "firebase-functions";
import { onRequest } from "firebase-functions/https";
import admin from "firebase-admin";

import app from "./app";

if (!admin.apps.length) {
  admin.initializeApp();
}

setGlobalOptions({
  region: "southamerica-east1",
  maxInstances: 10,
});

export const db = admin.firestore();
export const api = onRequest(app);
