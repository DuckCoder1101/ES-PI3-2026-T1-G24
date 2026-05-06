import { setGlobalOptions } from "firebase-functions";

setGlobalOptions({ maxInstances: 10 });

export * from "./user/index";
export * from "./startup/index";
