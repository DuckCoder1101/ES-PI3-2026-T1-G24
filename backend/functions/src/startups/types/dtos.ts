import { Timestamp } from "firebase-admin/firestore";
import {
  ExternalMember,
  Founder,
  QuestionAnwserDocument,
  QuestionVisibility,
  StartupStage,
} from "./documents";

export type StartupStageFilter = StartupStage | "all";

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
  offset: number;
  limit: number;
  filter: {
    name: string;
    stage: StartupStageFilter;
  };
}

export interface GetStartupDetailsBodyDTO {
  startupId: string;
}

export interface QuestionRegisterDTO {
  authorUId: string;
  content: string;
  visibility: QuestionVisibility;
}

export interface QuestionListDTO {
  id: string;
  authorUId: string;
  content: string;
  isAuthor: boolean;
  visibility: QuestionVisibility;
  answers: QuestionAnwserDocument[];
  createdAt: Timestamp;
}
