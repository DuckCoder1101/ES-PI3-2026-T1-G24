/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/formatters/timestamp_to_date.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';

class InvestmentModel {
  final StartupResumeDTO startup;
  final int tokenAmount;
  final int lockedTokenAmount;

  final DateTime? updatedAt;

  /// Total de tokens do usuário nessa startup (disponíveis + bloqueados).
  int get totalTokens => tokenAmount + lockedTokenAmount;

  InvestmentModel({
    required this.startup,
    required this.tokenAmount,
    required this.lockedTokenAmount,
    this.updatedAt,
  });

  factory InvestmentModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return InvestmentModel(
      startup: StartupResumeDTO.fromMap(
        Map<String, dynamic>.from(map['startup']),
      ),
      tokenAmount: (map['tokenAmount'] as num?)?.toInt() ?? 0,
      lockedTokenAmount: (map['lockedTokenAmount'] as num?)?.toInt() ?? 0,
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }
}
