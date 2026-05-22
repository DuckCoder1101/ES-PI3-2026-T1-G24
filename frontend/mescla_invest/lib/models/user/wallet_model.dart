/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

class WalletModel {
  final int fundsCents;
  final int lockedFundsCents;

  // Saldo em reais
  double get funds => fundsCents / 100;
  double get lockedFunds => lockedFundsCents / 100;
  double get totalFunds => (fundsCents + lockedFundsCents) / 100;

  WalletModel({required this.fundsCents, required this.lockedFundsCents});

  factory WalletModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return WalletModel(
      fundsCents: (map['fundsCents'] ?? 0) as int,
      lockedFundsCents: (map['lockedFundsCents'] ?? 0) as int,
    );
  }
}
