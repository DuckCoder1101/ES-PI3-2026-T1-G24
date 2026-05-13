/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

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

/*
 * Resumo de startup retornado junto com cada ordem no balcão.
 * O backend enriquece a ordem com nome e ID da startup para exibição.
 */
class StartupResume {
  final String id;
  final String name;

  StartupResume({required this.id, required this.name});

  factory StartupResume.fromMap(Map<String, dynamic> map) {
    return StartupResume(id: map['id'] ?? '', name: map['name'] ?? '');
  }
}

class OrderModel {
  final String id;
  final String authorUId;
  final StartupResume startup;
  final OrderType type;

  // Preço por token em centavos (backend armazena em centavos)
  final int pricePerTokenCents;

  // Preço por token em reais (calculado)
  double get pricePerToken => pricePerTokenCents / 100;

  final int tokenAmount;
  final bool isAuthor;
  final DateTime? createdAt;

  // Atalhos de conveniência
  String get startupId => startup.id;
  String get startupName => startup.name;

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

    // Suporte ao formato antigo (startupId string) e novo (startup: {id, name})
    final StartupResume startup;
    if (map['startup'] != null) {
      startup = StartupResume.fromMap(
        Map<String, dynamic>.from(map['startup']),
      );
    } else {
      startup = StartupResume(
        id: map['startupId'] ?? '',
        name: map['startupId'] ?? '',
      );
    }

    return OrderModel(
      id: map['id'] ?? '',
      authorUId: map['authorUId'] ?? '',
      startup: startup,
      type: map['type'] == 'sell' ? OrderType.sell : OrderType.buy,
      pricePerTokenCents: (map['pricePerTokenCents'] ?? 0) as int,
      tokenAmount: (map['tokenAmount'] ?? 0) as int,
      isAuthor: map['isAuthor'] ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic raw) {
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
   * Busca todas as ordens de um tipo (compra ou venda) com paginação
   */
  static Future<List<OrderModel>> getOrders({
    required OrderType orderType,
    required int offset,
    required int limit,
  }) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('getOrders')
        .call({'orderType': orderType.name, 'offset': offset, 'limit': limit});

    final data = Map<String, dynamic>.from(response.data);
    final List raw = data['orders'] ?? [];
    return raw
        .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o)))
        .toList();
  }

  /*
   * Busca todas as ordens criadas pelo usuário autenticado
   */
  static Future<List<OrderModel>> getUserOrders() async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('getUserOrders')
        .call();

    final data = Map<String, dynamic>.from(response.data);
    final List raw = data['orders'] ?? [];
    return raw
        .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o)))
        .toList();
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
    await FirebaseFunctions.instance.httpsCallable('registerOrder').call({
      'startupId': startupId,
      'type': type.name,
      'pricePerTokenCents': pricePerTokenCents,
      'tokenAmount': tokenAmount,
    });
  }

  /*
   * Cancela uma ordem do balcão e devolve os fundos ou tokens bloqueados
   */
  static Future<void> deleteOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('deleteOrder').call({
      'orderId': orderId,
    });
  }

  /*
   * Executa a compra de tokens de uma ordem de venda existente no balcão
   */
  static Future<void> buyOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('buyOrder').call({
      'orderId': orderId,
    });
  }

  /*
   * Executa a venda de tokens para uma ordem de compra existente no balcão
   */
  static Future<void> sellOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('sellOrder').call({
      'orderId': orderId,
    });
  }
}
