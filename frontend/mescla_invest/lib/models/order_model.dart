/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/formatters/timestamp_to_date.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';

enum OrderType {
  buy,
  sell;

  String get label {
    return switch (this) {
      OrderType.buy => "Comprar",
      OrderType.sell => "Vender",
    };
  }
}

class OrderModel {
  final String id;
  final String authorUId;
  final StartupResumeDTO startup;
  final OrderType type;

  /// Preço por token em centavos.
  final int pricePerTokenCents;

  /// Preço por token em reais (calculado).
  double get pricePerToken => pricePerTokenCents / 100;

  final int tokenAmount;

  /// Indica se o usuário autenticado é o autor desta ordem.
  final bool isAuthor;

  final DateTime? createdAt;

  // Atalhos de conveniência
  String get startupId => startup.id;
  String get startupName => startup.name;

  /// Indica se o usuário autenticado possui tokens desta startup.
  bool get isInvestor => startup.isInvestor;

  /// Valor total da ordem em reais.
  double get totalValue => pricePerToken * tokenAmount;

  OrderModel({
    required this.id,
    required this.authorUId,
    required this.startup,
    required this.type,
    required this.pricePerTokenCents,
    required this.tokenAmount,
    required this.isAuthor,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return OrderModel(
      id: map['id'] ?? '',
      authorUId: map['authorUId'] ?? '',
      startup: StartupResumeDTO.fromMap(
        Map<String, dynamic>.from(map['startup']),
      ),
      type: map['type'] == 'sell' ? OrderType.sell : OrderType.buy,
      pricePerTokenCents: (map['pricePerTokenCents'] as num?)?.toInt() ?? 0,
      tokenAmount: (map['tokenAmount'] as num?)?.toInt() ?? 0,
      isAuthor: map['isAuthor'] == true,
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
