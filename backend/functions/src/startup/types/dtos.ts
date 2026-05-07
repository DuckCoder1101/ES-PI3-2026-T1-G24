import { Timestamp } from "firebase-admin/firestore";
import {
  QuestionAnwserDocument,
  QuestionVisibility,
  StartupDocument,
  StartupStage,
} from "./documents";

export type StartupStageFilter = StartupStage | "all";

export interface StartupDetailsDTO extends StartupDocument {
  id: string;
}

export interface StartupListItemDTO {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  thumbnailPath?: string;
  tags: string[];
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
