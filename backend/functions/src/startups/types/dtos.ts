import { Timestamp } from "firebase-admin/firestore";
import { ExternalMember, Founder, StartupStage } from "./documents";

export type StartupsSearchFilter = StartupStage | "all";

export interface StartupListItemDTO {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  coverImageUrl?: string;
  tags: string[];
}

export interface StartupFullDTO {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  description: string;
  executiveSummary: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  founders: Founder[];
  externalMember: ExternalMember[];
  videos: string[];
  pitchDeckUrl?: string;
  coverImageUrl: string;
  tags: string[];
  createdAt?: Timestamp;
}

export interface GetStartupsRequestBodyDTO {
  filter: StartupsSearchFilter;
  offset: number;
  limit: number;
}

export interface GetStartupDetailsBodyDTO {
  startupId: string;
}
