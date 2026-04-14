import { StartupStage } from "./documents";

export interface AuthUser {
  uid: string;
  email: string;
}

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
