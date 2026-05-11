import { onCall } from "firebase-functions/https";
import { getUserProfile } from "../../shared/auth";
import { findUserTransactions } from "../repositories/transactionRepository";

export const getUserTransactions = onCall(async (req) => {
  const { uid } = getUserProfile(req);
  const transactions = await findUserTransactions(uid);

  return {
    transactions,
  };
});
