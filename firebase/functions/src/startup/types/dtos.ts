/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { Timestamp } from "firebase-admin/firestore";
import {
  PriceHistoryDocument,
  QuestionAnwserDocument,
  StartupDocument,
  StartupStage,
} from "./documents";
import { StartupStageFilter } from "../constants/startupStageFilters";
import { QuestionVisibility } from "../constants/questionVisibility";
import { DateInterval } from "../constants/dateInverval";

export interface StartupDetailsDTO extends StartupDocument {
  id: string;
  isInvestor: boolean;
}

export interface StartupListItemDTO {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  capitalRaisedCents: number;
  totalTokensAvailable: number;
  currentTokenPriceCents: number;
  thumbnailPath?: string;
  tags: string[];
  isInvestor: boolean;
}

export interface StartupResumeDTO {
  id: string;
  name: string;
  isInvestor: boolean;
  currentTokenPriceCents: number;
  initialTokenPriceCents: number;
  stage?: StartupStage;
}

export interface StartupTokenInfoDTO {
  id: string;
  totalTokensIssued: number;
  totalTokensAvailable: number;
  currentTokenPriceCents: number;
  initialTokenPriceCents: number;
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

export interface GetTokenPriceHistoryRequestDTO {
  startupId: string;
  dateInterval: DateInterval;
}

export interface StartupPriceSeriesDTO {
  startupId: string;
  startupName: string;
  priceHistory: PriceHistoryDocument[];
}

export interface NewsListDTO {
  id: string;
  startupId: string;
  title: string;
  content: string;
  createdAt: Timestamp;
}
