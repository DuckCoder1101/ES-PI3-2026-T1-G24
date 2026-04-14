import { Timestamp } from "firebase-admin/firestore";

export interface UserDocument {
  uid: string;
  name: string;
  email: string;
  cpf: string;
  phone: string;
  createdAt: Timestamp;
}
