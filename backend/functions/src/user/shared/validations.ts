/**
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

export const checkCPF = (value: string): boolean => {
  const cpf = value.replace(/\D/g, "");

  // Precisa ter 11 dígitos
  if (cpf.length !== 11) return false;

  // Evita CPFs com repetição de números
  if (/^(\d)\1{10}$/.test(cpf)) return false;

  // 1º dígito verificador
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += Number(cpf[i]) * (10 - i);
  }

  let firstDigit = (sum * 10) % 11;
  if (firstDigit === 10) firstDigit = 0;

  if (firstDigit !== Number(cpf[9])) return false;

  // Cálculo do 2º dígito verificador
  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += Number(cpf[i]) * (11 - i);
  }

  let secondDigit = (sum * 10) % 11;
  if (secondDigit === 10) secondDigit = 0;

  if (secondDigit !== Number(cpf[10])) return false;

  return true;
};

export const checkPhone = (value: string): boolean => {
  const phone = value.replace(/\D/g, "");

  // deve ter 11 dígitos (DDD + 9 números)
  if (phone.length !== 11) return false;

  // DDD não pode começar com 0
  if (/^0/.test(phone)) return false;

  // terceiro dígito (início do número) deve ser 9 (celular)
  if (phone[2] !== "9") return false;

  return true;
};
