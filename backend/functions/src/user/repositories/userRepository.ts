import { database } from "../shared/firebase";
import { UserDocument } from "../types/documents";
import { UserSignupDTO } from "../types/dtos";

const usersCollection = database.collection("users");

export const createUserAccount = async (uid: string, data: UserSignupDTO) => {
  await usersCollection.doc(uid).set(data);
};

export const findUserById = async (
  uid: string,
): Promise<UserDocument | null> => {
  const doc = await usersCollection.doc(uid).get();

  if (!doc.exists) return null;

  return {
    uid: doc.id,
    ...doc.data(),
  } as UserDocument;
};
