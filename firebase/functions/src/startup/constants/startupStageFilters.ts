import { StartupStage } from "../types/documents";

export type StartupStageFilter = StartupStage | "all";
export const StartupsSearchFilters: StartupStageFilter[] = [
  "all",
  "nova",
  "em_operacao",
  "em_expansao",
];
