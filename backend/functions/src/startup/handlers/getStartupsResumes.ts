import { onCall } from "firebase-functions/https";
import { getUserProfile } from "../../shared/auth";
import { findStartupsResumes } from "../repositories/startupsRepository";

export const getStartupResumes = onCall(async (req) => {
  getUserProfile(req);

  const startups = await findStartupsResumes();

  return {
    startups,
  };
});
