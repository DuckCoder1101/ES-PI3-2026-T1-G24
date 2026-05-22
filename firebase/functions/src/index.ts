/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import { setGlobalOptions } from "firebase-functions";

setGlobalOptions({ maxInstances: 10 });

export * from "./user/index";
export * from "./startup/index";
export * from "./orders/index";
export * from "./transaction/index";
