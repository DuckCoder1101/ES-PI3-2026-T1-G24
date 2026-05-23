/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { DateInterval } from "../types/documents";
import { StartupStageFilter } from "../types/dtos";

export const StartupsSearchFilters: StartupStageFilter[] = [
  "all",
  "nova",
  "em_operacao",
  "em_expansao",
];

export const DateIntervals: DateInterval[] = ["1M", "6M", "1Y", "5Y"];
