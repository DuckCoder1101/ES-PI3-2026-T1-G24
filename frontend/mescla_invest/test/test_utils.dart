/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// Configuração via --dart-define
const runTests = bool.fromEnvironment('RUN_FIREBASE_FUNCTIONS_TESTS');

const projectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: '<coloque-id-projeto-firebase-aqui>',
);

const functionsOrigin = String.fromEnvironment(
  'FIREBASE_FUNCTIONS_ORIGIN',
  defaultValue: 'http://127.0.0.1:5001',
);

const authOrigin = String.fromEnvironment(
  'FIREBASE_AUTH_ORIGIN',
  defaultValue: 'http://127.0.0.1:9099',
);

// Usuário de teste
const _testEmail = 'cristian@teste.com';
const _testPassword = '123456qwerty';

// Helpers de URI
Uri functionUri(String name) =>
    Uri.parse('$functionsOrigin/$projectId/us-central1/$name');

Uri authSignUpUri() => Uri.parse(
  '$authOrigin/identitytoolkit.googleapis.com/v1/'
  'accounts:signUp?key=fake-api-key',
);

Uri authSignInUri() => Uri.parse(
  '$authOrigin/identitytoolkit.googleapis.com/v1/'
  'accounts:signInWithPassword?key=fake-api-key',
);

// Helpers de autenticação
Future<String> getIdToken() async {
  final signUpRes = await http.post(
    authSignUpUri(),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': _testEmail,
      'password': _testPassword,
      'returnSecureToken': true,
    }),
  );

  final payload = decodeResponse(signUpRes);

  if (signUpRes.statusCode != 200 && isEmailAlreadyInUse(payload)) {
    return signIn();
  }

  if (signUpRes.statusCode != 200) {
    fail('Falha ao criar usuário no Auth emulator: $payload');
  }

  return payload['idToken'] as String;
}

Future<String> signIn() async {
  final res = await http.post(
    authSignInUri(),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': _testEmail,
      'password': _testPassword,
      'returnSecureToken': true,
    }),
  );

  final payload = decodeResponse(res);

  if (res.statusCode != 200) {
    fail('Falha ao autenticar no Auth emulator: $payload');
  }

  return payload['idToken'] as String;
}

bool isEmailAlreadyInUse(Map<String, dynamic> payload) {
  final error = payload['error'];
  if (error is! Map<String, dynamic>) return false;
  return error['message'] == 'EMAIL_EXISTS';
}

// Helper de chamada de função
Future<Map<String, dynamic>> callFunction(
  String functionName, {
  Map<String, dynamic> data = const {},
  String? idToken,
}) async {
  final headers = <String, String>{'Content-Type': 'application/json'};

  if (idToken != null) {
    headers['Authorization'] = 'Bearer $idToken';
  }

  final response = await http.post(
    functionUri(functionName),
    headers: headers,
    body: jsonEncode({'data': data}),
  );

  final payload = decodeResponse(response);

  if (response.statusCode != 200) {
    fail('Callable $functionName falhou: $payload');
  }

  if (payload['error'] != null) {
    fail('Callable $functionName retornou erro: ${payload['error']}');
  }

  return payload['result'] as Map<String, dynamic>;
}

Map<String, dynamic> decodeResponse(http.Response response) {
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) return decoded;
  fail('Resposta inesperada: ${response.body}');
}

// Testes

const skipMsg =
    'Inicie os emuladores e rode com --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true';
