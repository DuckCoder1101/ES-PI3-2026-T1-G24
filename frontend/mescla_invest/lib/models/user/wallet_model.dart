/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/formatters/timestamp_to_date.dart';

class WalletModel {
  final int fundsCents;
  final int lockedFundsCents;

  /// Data da última movimentação da carteira.
  final DateTime? updatedAt;

  /// Saldo disponível em reais.
  double get funds => fundsCents / 100;

  /// Saldo bloqueado em reais (reservado em ordens abertas).
  double get lockedFunds => lockedFundsCents / 100;

  /// Saldo total em reais (disponível + bloqueado).
  double get totalFunds => (fundsCents + lockedFundsCents) / 100;

  WalletModel({
    required this.fundsCents,
    required this.lockedFundsCents,
    this.updatedAt,
  });

  factory WalletModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return WalletModel(
      fundsCents: (map['fundsCents'] as num?)?.toInt() ?? 0,
      lockedFundsCents: (map['lockedFundsCents'] as num?)?.toInt() ?? 0,
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }
}
