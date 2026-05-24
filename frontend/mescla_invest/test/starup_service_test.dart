/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'test_utils.dart';

void main() {
  group('StartupService — callable functions', () {
    late String idToken;

    setUpAll(() async {
      idToken = await getIdToken();
      // Garante que o catálogo de demonstração existe antes dos testes
      await callFunction('getStartupResumes', idToken: idToken);
    });

    // getStartupsList
    group('getStartupsList', () {
      test('retorna lista de startups sem filtro', () async {
        final result = await callFunction(
          'getStartupsList',
          idToken: idToken,
          data: {
            'offset': 0,
            'limit': 10,
            'filter': {'stage': 'all', 'name': ''},
          },
        );

        final data = result['data'] as Map<String, dynamic>;
        final startups = data['startups'] as List;

        expect(startups, isA<List>());
        expect(startups.length, greaterThanOrEqualTo(0));
      });

      test('filtra startups pelo nome', () async {
        final result = await callFunction(
          'getStartupsList',
          idToken: idToken,
          data: {
            'offset': 0,
            'limit': 10,
            'filter': {'stage': 'all', 'name': 'bio'},
          },
        );

        final data = result['data'] as Map<String, dynamic>;
        final startups = data['startups'] as List;

        for (final startup in startups) {
          final s = startup as Map<String, dynamic>;
          final name = (s['name'] as String).toLowerCase();
          expect(name.contains('bio'), isTrue);
        }
      });

      test('respeita o parâmetro limit', () async {
        final result = await callFunction(
          'getStartupsList',
          idToken: idToken,
          data: {
            'offset': 0,
            'limit': 2,
            'filter': {'stage': 'all', 'name': ''},
          },
        );

        final data = result['data'] as Map<String, dynamic>;
        final startups = data['startups'] as List;

        expect(startups.length, lessThanOrEqualTo(2));
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('getStartupsList'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {
              'offset': 0,
              'limit': 10,
              'filter': {'stage': 'all', 'name': ''},
            },
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });

    // getStartupResumes
    group('getStartupResumes', () {
      test('retorna lista de resumos com id e name', () async {
        final result = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );

        final data = result['data'] as Map<String, dynamic>;
        final startups = data['startups'] as List;

        expect(startups, isA<List>());

        for (final startup in startups) {
          final s = startup as Map<String, dynamic>;
          expect(s['id'], isNotEmpty);
          expect(s['name'], isNotEmpty);
        }
      });
    });

    // -------------------------------------------------------------------------
    // getStartupDetails
    // -------------------------------------------------------------------------
    group('getStartupDetails', () {
      test('retorna detalhes completos de uma startup existente', () async {
        // Busca uma startup qualquer para usar no teste
        final listResult = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );
        final startups =
            (listResult['data'] as Map<String, dynamic>)['startups'] as List;

        expect(
          startups,
          isNotEmpty,
          reason: 'Precisa de ao menos uma startup no emulador',
        );

        final startupId =
            (startups.first as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'getStartupDetails',
          idToken: idToken,
          data: {'startupId': startupId},
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['id'], startupId);
        expect(data['name'], isNotEmpty);
        expect(data['stage'], isNotEmpty);
      });

      test('retorna not-found para startup inexistente', () async {
        final response = await http.post(
          functionUri('getStartupDetails'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'data': {'startupId': 'startup-que-nao-existe'},
          }),
        );

        expect(response.statusCode, isNot(200));
        final payload = decodeResponse(response);
        expect(payload['error'], isNotNull);
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('getStartupDetails'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {'startupId': 'qualquer-id'},
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });

    // -------------------------------------------------------------------------
    // getQuestions / registerQuestion / deleteQuestion
    // -------------------------------------------------------------------------
    group('getQuestions', () {
      test('retorna lista de perguntas públicas de uma startup', () async {
        final listResult = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );
        final startups =
            (listResult['data'] as Map<String, dynamic>)['startups'] as List;
        final startupId =
            (startups.first as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'getQuestions',
          idToken: idToken,
          data: {'startupId': startupId, 'visibility': 'public'},
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['questions'], isA<List>());
      });
    });

    group('registerQuestion', () {
      test('cria uma pergunta pública e retorna id', () async {
        final listResult = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );
        final startups =
            (listResult['data'] as Map<String, dynamic>)['startups'] as List;
        final startupId =
            (startups.first as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'registerQuestion',
          idToken: idToken,
          data: {
            'startupId': startupId,
            'content': 'Qual é o próximo marco do projeto?',
            'visibility': 'public',
          },
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['id'], isNotEmpty);
        expect(data['startupId'], startupId);
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('registerQuestion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {
              'startupId': 'qualquer-id',
              'content': 'Pergunta sem auth',
              'visibility': 'public',
            },
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });

    group('deleteQuestion', () {
      test('cria e deleta uma pergunta com sucesso', () async {
        final listResult = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );
        final startups =
            (listResult['data'] as Map<String, dynamic>)['startups'] as List;
        final startupId =
            (startups.first as Map<String, dynamic>)['id'] as String;

        // Cria pergunta para deletar
        final createResult = await callFunction(
          'registerQuestion',
          idToken: idToken,
          data: {
            'startupId': startupId,
            'content': 'Pergunta temporária para deleção',
            'visibility': 'public',
          },
        );
        final questionId =
            (createResult['data'] as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'deleteQuestion',
          idToken: idToken,
          data: {'startupId': startupId, 'questionId': questionId},
        );

        expect(result, isA<Map<String, dynamic>>());
      });
    });

    // -------------------------------------------------------------------------
    // getTokenPriceHistory
    // -------------------------------------------------------------------------
    group('getTokenPriceHistory', () {
      test('retorna histórico de preços de uma startup', () async {
        final listResult = await callFunction(
          'getStartupResumes',
          idToken: idToken,
        );
        final startups =
            (listResult['data'] as Map<String, dynamic>)['startups'] as List;
        final startupId =
            (startups.first as Map<String, dynamic>)['id'] as String;

        final result = await callFunction(
          'getTokenPriceHistory',
          idToken: idToken,
          data: {'startupId': startupId, 'dateInterval': '1M'},
        );

        final data = result['data'] as Map<String, dynamic>;

        expect(data['priceHistory'], isA<List>());
      });

      test('falha sem autenticação', () async {
        final response = await http.post(
          functionUri('getTokenPriceHistory'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {'startupId': 'qualquer-id', 'dateInterval': '1M'},
          }),
        );

        expect(response.statusCode, isNot(200));
      });
    });
  }, skip: runTests ? false : skipMsg);
}
