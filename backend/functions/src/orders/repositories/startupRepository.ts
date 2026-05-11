import { database } from "../../shared/firebase";

const startupsCollection = database.collection("startups");

export const startupExists = async (startupId: string): Promise<boolean> => {
  const doc = await startupsCollection.doc(startupId).get();
  return doc.exists;
};
