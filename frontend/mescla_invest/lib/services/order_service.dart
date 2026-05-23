/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest/models/order_model.dart';

class OrderService {
  // Busca todas as ordens de um tipo
  static Future<List<OrderModel>> getOrders({
    required OrderType orderType,
    required int offset,
    required int limit,
  }) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('getOrdersList')
        .call({'orderType': orderType.name, 'offset': offset, 'limit': limit});

    final data = Map<String, dynamic>.from(response.data);
    final List raw = data['orders'] ?? [];
    return raw
        .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o)))
        .toList();
  }

  // Busca todas as ordens criadas pelo usuário autenticado
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

  // Registra uma nova ordem de compra ou venda no balcão.
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

  // Cancela uma ordem do balcão e devolve os fundos ou tokens bloqueados
  static Future<void> deleteOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('deleteOrder').call({
      'orderId': orderId,
    });
  }

  // Executa a compra de tokens de uma ordem de venda existente no balcão
  static Future<void> buyOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('buyOrder').call({
      'orderId': orderId,
    });
  }

  // Executa a venda de tokens para uma ordem de compra existente no balcão
  static Future<void> sellOrder(String orderId) async {
    await FirebaseFunctions.instance.httpsCallable('sellOrder').call({
      'orderId': orderId,
    });
  }
}
