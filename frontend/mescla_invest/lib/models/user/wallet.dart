/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

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
   * Busca os dados da carteira do usuário autenticado via Cloud Function.
   * Retorna saldo disponível e saldo bloqueado em ordens de compra ativas.
   */
  static Future<WalletModel> getWallet() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getWalletHandler')
          .call();

      return WalletModel.fromMap(Map<String, dynamic>.from(response.data));
    } catch (e) {
      rethrow;
    }
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
