/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { QuestionVisibility } from "../constants/questionVisibility";

export type StartupStage = "nova" | "em_operacao" | "em_expansao";

export interface DateLimits {
  start: Date;
  end: Date;
}

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
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  description: string;
  executiveSummary: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  totalTokensAvailable: number;
  currentTokenPriceCents: number;
  // Preço de lançamento — imutável, usado como base do cálculo de valorização
  initialTokenPriceCents: number;
  founders: Founder[];
  externalMember: ExternalMember[];

  pitchDeckPath?: string;
  thumbnailPath?: string;
  videoPath?: string;

  tags: string[];

  createdAt?: Timestamp;
  updatedAt?: Timestamp;
}

export interface QuestionDocument {
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

export interface PriceHistoryDocument {
  priceCents: number;
  occupancyRate: number;
  triggerId: string;
  createdAt: FieldValue;
}
