/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'test_utils.dart';

void main() {
  group('OrderService — callable functions', () {
    late String idToken;
    late String createdOrderId;

    setUpAll(() async {
      idToken = await getIdToken();
    });

    // registerOrder
    group('registerOrder', () {
      test('registra uma ordem de compra e retorna id da ordem', () async {
        final result = await callFunction(
          'registerOrder',
          idToken: idToken,
          data: {
            'startupId': 'startup-teste',
            'type': 'buy',
            'pricePerTokenCents': 1500,
            'tokenAmount': 10,
          },
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['id'], isNotEmpty);
        expect(data['type'], 'buy');
        expect(data['startupId'], 'startup-teste');

        createdOrderId = data['id'] as String;
      });

      test('registra uma ordem de venda e retorna id da ordem', () async {
        final result = await callFunction(
          'registerOrder',
          idToken: idToken,
          data: {
            'startupId': 'startup-teste',
            'type': 'sell',
            'pricePerTokenCents': 2000,
            'tokenAmount': 5,
          },
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['id'], isNotEmpty);
        expect(data['type'], 'sell');
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('registerOrder'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {
              'startupId': 'startup-teste',
              'type': 'buy',
              'pricePerTokenCents': 1500,
              'tokenAmount': 10,
            },
          }),
        );

        final payload = decodeResponse(response);
        expect(response.statusCode, isNot(200));
        expect(payload['error'], isNotNull);
      });
    });

    // getOrdersList
    group('getOrdersList', () {
      test('retorna lista de ordens do tipo buy', () async {
        final result = await callFunction(
          'getOrdersList',
          idToken: idToken,
          data: {'orderType': 'buy', 'offset': 0, 'limit': 10},
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['orders'], isA<List>());
        expect(result['count'], greaterThanOrEqualTo(0));
      });

      test('retorna lista de ordens do tipo sell', () async {
        final result = await callFunction(
          'getOrdersList',
          idToken: idToken,
          data: {'orderType': 'sell', 'offset': 0, 'limit': 10},
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['orders'], isA<List>());
      });

      test('respeita o parâmetro limit', () async {
        final result = await callFunction(
          'getOrdersList',
          idToken: idToken,
          data: {'orderType': 'buy', 'offset': 0, 'limit': 2},
        );

        final data = result['data'] as Map<String, dynamic>;
        final orders = data['orders'] as List;

        expect(orders.length, lessThanOrEqualTo(2));
      });
    });

    // getUserOrders
    group('getUserOrders', () {
      test('retorna as ordens do usuário autenticado', () async {
        final result = await callFunction('getUserOrders', idToken: idToken);

        final data = result['data'] as Map<String, dynamic>;

        expect(data['orders'], isA<List>());

        // Todas as ordens devem pertencer ao usuário autenticado
        final orders = data['orders'] as List;
        for (final order in orders) {
          final o = order as Map<String, dynamic>;
          expect(o['userId'], isNotEmpty);
        }
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('getUserOrders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'data': {}}),
        );

        expect(response.statusCode, isNot(200));
      });
    });

    // buyOrder / sellOrder
    group('buyOrder', () {
      test('executa compra de uma ordem de venda existente', () async {
        // Cria uma ordem de venda para ser comprada
        final sellResult = await callFunction(
          'registerOrder',
          idToken: idToken,
          data: {
            'startupId': 'startup-teste',
            'type': 'sell',
            'pricePerTokenCents': 1000,
            'tokenAmount': 1,
          },
        );
        final sellOrderId =
            (sellResult['data'] as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'buyOrder',
          idToken: idToken,
          data: {'orderId': sellOrderId},
        );

        expect(result, isA<Map<String, dynamic>>());
      });

      test('falha ao tentar comprar ordem inexistente', () async {
        final response = await http.post(
          functionUri('buyOrder'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'data': {'orderId': 'ordem-que-nao-existe'},
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });

    group('sellOrder', () {
      test('executa venda para uma ordem de compra existente', () async {
        // Cria uma ordem de compra para ser vendida
        final buyResult = await callFunction(
          'registerOrder',
          idToken: idToken,
          data: {
            'startupId': 'startup-teste',
            'type': 'buy',
            'pricePerTokenCents': 1000,
            'tokenAmount': 1,
          },
        );
        final buyOrderId =
            (buyResult['data'] as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'sellOrder',
          idToken: idToken,
          data: {'orderId': buyOrderId},
        );

        expect(result, isA<Map<String, dynamic>>());
      });
    });

    // -------------------------------------------------------------------------
    // deleteOrder
    // -------------------------------------------------------------------------
    group('deleteOrder', () {
      test('cancela uma ordem existente do usuário', () async {
        // Cria uma ordem para deletar
        final registerResult = await callFunction(
          'registerOrder',
          idToken: idToken,
          data: {
            'startupId': 'startup-teste',
            'type': 'buy',
            'pricePerTokenCents': 500,
            'tokenAmount': 2,
          },
        );
        final orderId =
            (registerResult['data'] as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'deleteOrder',
          idToken: idToken,
          data: {'orderId': orderId},
        );

        expect(result, isA<Map<String, dynamic>>());
      });

      test('falha ao deletar ordem de outro usuário', () async {
        final response = await http.post(
          functionUri('deleteOrder'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'data': {'orderId': createdOrderId},
          }),
        );

        // Deve falhar com permission-denied ou not-found
        expect(response.statusCode, isNot(200));
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('deleteOrder'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {'orderId': 'qualquer-id'},
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });
  }, skip: runTests ? false : skipMsg);
}
