/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

/*
 * Representa o investimento (posição) de um usuário em uma startup.
 * tokenAmount: tokens disponíveis para uso/venda.
 * lockedTokenAmount: tokens bloqueados em ordens de venda ativas.
 */
class InvestmentModel {
  final String startupId;
  final int tokenAmount;
  final int lockedTokenAmount;

  // Total de tokens do usuário nessa startup (disponíveis + bloqueados)
  int get totalTokens => tokenAmount + lockedTokenAmount;

  InvestmentModel({
    required this.startupId,
    required this.tokenAmount,
    required this.lockedTokenAmount,
  });

  factory InvestmentModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return InvestmentModel(
      startupId: map['startupId'] ?? '',
      tokenAmount: (map['tokenAmount'] ?? 0) as int,
      lockedTokenAmount: (map['lockedTokenAmount'] ?? 0) as int,
    );
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

/*
 * Representa a carteira do usuário com saldo disponível e bloqueado.
 * fundsCents: saldo disponível em centavos.
 * lockedFundsCents: saldo reservado para ordens de compra ativas.
 */
class WalletModel {
  final int fundsCents;
  final int lockedFundsCents;

  // Saldo disponível em reais
  double get funds => fundsCents / 100;

  // Saldo bloqueado em reais
  double get lockedFunds => lockedFundsCents / 100;

  // Saldo total (disponível + bloqueado) em reais
  double get totalFunds => (fundsCents + lockedFundsCents) / 100;

  WalletModel({required this.fundsCents, required this.lockedFundsCents});

  factory WalletModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return WalletModel(
      fundsCents: (map['fundsCents'] ?? 0) as int,
      lockedFundsCents: (map['lockedFundsCents'] ?? 0) as int,
    );
  }

  /*
   * Adiciona saldo fictício à carteira do usuário (simulação de depósito).
   * O valor mínimo é R$ 10,00. Registra uma transação do tipo "funds".
   */
  static Future<void> addFunds(double funds) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('addFunds').call({
        'funds': funds,
      });
    } catch (e) {
      rethrow;
    }
  }
}
