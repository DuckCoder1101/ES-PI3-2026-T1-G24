/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:mescla_invest/models/startup/startup_model.dart';

class InvestmentModel {
  final int tokenAmount;
  final int lockedTokenAmount;
  final StartupResumeDTO startup;

  // Total de tokens do usuário nessa startup (disponíveis + bloqueados)
  int get totalTokens => tokenAmount + lockedTokenAmount;

  InvestmentModel({
    required this.startup,
    required this.tokenAmount,
    required this.lockedTokenAmount,
  });

  factory InvestmentModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return InvestmentModel(
      startup: StartupResumeDTO.fromMap(
        Map<String, dynamic>.from(map['startup']),
      ),
      tokenAmount: (map['tokenAmount'] ?? 0) as int,
      lockedTokenAmount: (map['lockedTokenAmount'] ?? 0) as int,
    );
  }
}
