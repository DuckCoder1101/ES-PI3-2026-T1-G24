/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

enum TransactionType { investment, funds, trade }

/*
 * Modelo base de transação.
 * Todas as transações possuem id, tipo, valor em centavos, data e lista de UIDs envolvidos.
 */
abstract class TransactionModel {
  final String? id;
  final TransactionType type;
  final int amountCents;
  final DateTime? createdAt;
  final List<String> userUIds;

  // Valor em reais (calculado a partir de centavos)
  double get amount => amountCents / 100;

  TransactionModel({
    this.id,
    required this.type,
    required this.amountCents,
    required this.userUIds,
    this.createdAt,
  });

  // Converte o campo createdAt (Timestamp do Firestore) para DateTime
  static DateTime? parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is Map && raw['seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (raw['seconds'] as int) * 1000,
      );
    }
    return null;
  }

  /*
   * Faz o parse do mapa genérico e retorna o subtipo correto de TransactionModel
   */
  static TransactionModel fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    final typeStr = map['type'] as String? ?? '';

    switch (typeStr) {
      case 'investment':
        return InvestmentTransactionModel.fromMap(map);
      case 'trade':
        return TradeTransactionModel.fromMap(map);
      case 'funds':
      default:
        return FundsTransactionModel.fromMap(map);
    }
  }

  /*
   * Busca o histórico completo de transações do usuário autenticado.
   * Inclui depósitos de fundos, compras diretas e negociações no balcão.
   */
  static Future<List<TransactionModel>> getUserTransactions() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getUserTransactions')
          .call();

      final data = Map<String, dynamic>.from(response.data);
      final List raw = data['transactions'] ?? [];

      return raw
          .map((t) => TransactionModel.fromMap(Map<String, dynamic>.from(t)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

/*
 * Transação de compra direta de tokens na página de uma startup.
 */
class InvestmentTransactionModel extends TransactionModel {
  final String investorUId;
  final String startupId;
  final int tokensPurchased;
  final int tokenPriceCents;

  double get tokenPrice => tokenPriceCents / 100;

  InvestmentTransactionModel({
    super.id,
    required super.amountCents,
    required super.userUIds,
    super.createdAt,
    required this.investorUId,
    required this.startupId,
    required this.tokensPurchased,
    required this.tokenPriceCents,
  }) : super(type: TransactionType.investment);

  factory InvestmentTransactionModel.fromMap(Map<String, dynamic> map) {
    return InvestmentTransactionModel(
      id: map['id'],
      amountCents: (map['amountCents'] ?? 0) as int,
      userUIds: List<String>.from(map['userUIds'] ?? []),
      createdAt: TransactionModel.parseTimestamp(map['createdAt']),
      investorUId: map['investorUId'] ?? '',
      startupId: map['startupId'] ?? '',
      tokensPurchased: (map['tokensPurchased'] ?? 0) as int,
      tokenPriceCents: (map['tokenPriceCents'] ?? 0) as int,
    );
  }
}

/*
 * Transação de compra ou venda de tokens entre usuários via balcão.
 */
class TradeTransactionModel extends TransactionModel {
  final String purchaserUId;
  final String sellerUId;
  final String startupId;
  final int tokensPurchased;
  final int tokenPriceCents;

  double get tokenPrice => tokenPriceCents / 100;

  TradeTransactionModel({
    super.id,
    required super.amountCents,
    required super.userUIds,
    super.createdAt,
    required this.purchaserUId,
    required this.sellerUId,
    required this.startupId,
    required this.tokensPurchased,
    required this.tokenPriceCents,
  }) : super(type: TransactionType.trade);

  factory TradeTransactionModel.fromMap(Map<String, dynamic> map) {
    return TradeTransactionModel(
      id: map['id'],
      amountCents: (map['amountCents'] ?? 0) as int,
      userUIds: List<String>.from(map['userUIds'] ?? []),
      createdAt: TransactionModel.parseTimestamp(map['createdAt']),
      purchaserUId: map['purchaserUId'] ?? '',
      sellerUId: map['sellerUId'] ?? '',
      startupId: map['startupId'] ?? '',
      tokensPurchased: (map['tokensPurchased'] ?? 0) as int,
      tokenPriceCents: (map['tokenPriceCents'] ?? 0) as int,
    );
  }
}

/*
 * Transação de adição de saldo fictício à carteira (simulação de depósito).
 */
class FundsTransactionModel extends TransactionModel {
  final String authorUId;

  FundsTransactionModel({
    super.id,
    required super.amountCents,
    required super.userUIds,
    super.createdAt,
    required this.authorUId,
  }) : super(type: TransactionType.funds);

  factory FundsTransactionModel.fromMap(Map<String, dynamic> map) {
    return FundsTransactionModel(
      id: map['id'],
      amountCents: (map['amountCents'] ?? 0) as int,
      userUIds: List<String>.from(map['userUIds'] ?? []),
      createdAt: TransactionModel.parseTimestamp(map['createdAt']),
      authorUId: map['authorUId'] ?? '',
    );
  }
}
