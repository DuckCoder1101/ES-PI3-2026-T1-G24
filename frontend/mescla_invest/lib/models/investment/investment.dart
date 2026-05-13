/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest/models/startup/startup.dart';

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

  /*
   * Busca todos os investimentos (posições em startups) do usuário autenticado.
   */
  static Future<List<InvestmentModel>> getUserInvestments() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getUserInvestments')
          .call();

      final data = Map<String, dynamic>.from(response.data);
      final List raw = data['investments'] ?? [];

      return raw
          .map((i) => InvestmentModel.fromMap(Map<String, dynamic>.from(i)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Compra tokens diretamente na página de uma startup.
   * Debita o saldo da carteira e registra uma transação do tipo "investment".
   */
  static Future<void> buyTokens({
    required String startupId,
    required int tokenAmount,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('buyTokens').call({
        'startupId': startupId,
        'tokenAmount': tokenAmount,
      });
    } catch (e) {
      rethrow;
    }
  }
}
