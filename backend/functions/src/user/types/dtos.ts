/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

export interface UserSignupDTO {
  name: string;
  email: string;
  cpf: string;
  phone: string;
}

export interface UserProfile {
  uid: string;
  email: string;
}

export type AppResponseDTO =
  | {
      success: true;
      data: unknown;
    }
  | {
      success: false;
    };
