import { Timestamp } from "firebase-admin/firestore";

export type StartupStage = "nova" | "em_operacao" | "em_expansao";
export type QuestionVisibility = "privada" | "publica";

export interface Founder {
  name: string;
  role: string;
  equityPercent: number;
  bio?: string;
}

export interface ExternalMember {
  name: string;
  role: string;
  organization?: string;
}

export interface StartupDocument {
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
  updatedAt?: Timestamp;
}

export interface QuestionDocument {
  id: string;
  authorUId: string;
  content: string;
  visibility: QuestionVisibility;
  answers: QuestionAnwserDocument[];
  createdAt: Timestamp;
}

export interface QuestionAnwserDocument {
  authorUId: string;
  content: string;
  createdAt: Timestamp;
}
