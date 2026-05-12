/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest/models/startup/startup.dart';

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

  // Preço por token em centavos (backend armazena em centavos)
  final int pricePerTokenCents;

  // Preço por token em reais (calculado)
  double get pricePerToken => pricePerTokenCents / 100;

  final int tokenAmount;
  final bool isAuthor;
  final DateTime? createdAt;

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

  // Valor total da ordem em reais
  double get totalValue => pricePerToken * tokenAmount;

  factory OrderModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return OrderModel(
      id: map['id'] ?? '',
      authorUId: map['authorUId'] ?? '',
      startup: StartupResumeDTO.fromMap(
        Map<String, dynamic>.from(map["startup"]),
      ),
      type: map['type'] == 'sell' ? OrderType.sell : OrderType.buy,
      pricePerTokenCents: (map['pricePerTokenCents'] ?? 0) as int,
      tokenAmount: (map['tokenAmount'] ?? 0) as int,
      isAuthor: map['isAuthor'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
                : (map['createdAt'] as Map)['seconds'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['createdAt']['seconds'] as int) * 1000,
                  )
                : null)
          : null,
    );
  }

  /*
   * Busca todas as ordens de um tipo (compra ou venda) com paginação
   */
  static Future<List<OrderModel>> getOrders({
    required OrderType orderType,
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getOrders')
          .call({
            'orderType': orderType.name,
            'offset': offset,
            'limit': limit,
          });

      final data = Map<String, dynamic>.from(response.data);
      final List raw = data['orders'] ?? [];

      return raw
          .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Busca todas as ordens criadas pelo usuário autenticado
   */
  static Future<List<OrderModel>> getUserOrders() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getUserOrders')
          .call();

      final data = Map<String, dynamic>.from(response.data);
      final List raw = data['orders'] ?? [];

      return raw
          .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Registra uma nova ordem de compra ou venda no balcão.
   * Para compra: bloqueia fundos da carteira.
   * Para venda: bloqueia tokens do investimento.
   */
  static Future<void> registerOrder({
    required String startupId,
    required OrderType type,
    required int pricePerTokenCents,
    required int tokenAmount,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('registerOrder').call({
        'startupId': startupId,
        'type': type.name,
        'pricePerTokenCents': pricePerTokenCents,
        'tokenAmount': tokenAmount,
      });
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Cancela uma ordem do balcão e devolve os fundos ou tokens bloqueados
   */
  static Future<void> deleteOrder(String orderId) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('deleteOrder').call({
        'orderId': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Executa a compra de tokens de uma ordem de venda existente no balcão.
   * Debita os fundos da carteira do comprador e credita os tokens.
   */
  static Future<void> buyOrder(String orderId) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('buyOrder').call({
        'orderId': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }

  /*
   * Executa a venda de tokens para uma ordem de compra existente no balcão.
   * Debita os tokens do vendedor e credita os fundos bloqueados pelo comprador.
   */
  static Future<void> sellOrder(String orderId) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('sellOrder').call({
        'orderId': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }
}
