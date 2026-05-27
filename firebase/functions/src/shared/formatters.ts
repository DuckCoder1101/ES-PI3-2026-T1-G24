export const formatCurrency = (cents: number): string =>
  (cents / 100).toLocaleString("pt-br", { style: "currency", currency: "BRL" });
