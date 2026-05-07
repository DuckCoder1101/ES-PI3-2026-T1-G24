/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Dados retornados ao iniciar o TOTP.
class TotpEnrollmentData {
  final String otpauthUrl;
  final TotpSecret secret;

  const TotpEnrollmentData({required this.otpauthUrl, required this.secret});
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final String? avatarUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      avatarUrl: map['avatarUrl'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  // Verifica se TOTP está ativo
  static Future<bool> checkHas2Fa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final factors = await user.multiFactor.getEnrolledFactors();
    return factors.any((f) => f.factorId == 'totp');
  }

  // Dados do usuário
  static Future<UserModel> getFullUserData() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getMe')
          .call();

      final dataMap = Map<String, dynamic>.from(result.data);
      return UserModel.fromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  // Autenticação
  static Future<void> register({
    required String email,
    required String password,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    email = email.toLowerCase().trim();
    password = password.trim();
    name = name.trim();
    cpf = cpf.trim();
    phone = phone.trim();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.getIdToken();

      await FirebaseFunctions.instance.httpsCallable('signup').call({
        'name': name,
        'cpf': cpf,
        'phone': phone,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Efetua o login
  static Future<void> signin(String email, String password) async {
    email = email.trim();
    password = password.trim();

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  /// otpauth:// para o QR code e o secrete para finalizar o registro do TOTP.
  static Future<TotpEnrollmentData> beginTotpActivation(
    String accountName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    final session = await user.multiFactor.getSession();
    final secret = await TotpMultiFactorGenerator.generateSecret(session);

    final otpauthUrl = await secret.generateQrCodeUrl(
      accountName: accountName,
      issuer: 'MesclaInvest',
    );

    return TotpEnrollmentData(otpauthUrl: otpauthUrl, secret: secret);
  }

  /// Finaliza o enrolamento com o código de 6 dígitos do app autenticador.
  static Future<void> finalizeTotpActivation(
    TotpSecret secret,
    String totpCode, {
    String displayName = 'Authenticator',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
      secret,
      totpCode,
    );

    await user.multiFactor.enroll(assertion, displayName: displayName);
  }

  /// Desativa o 2FA.
  static Future<void> disableTotp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    final factors = await user.multiFactor.getEnrolledFactors();
    final totp = factors.firstWhere(
      (f) => f.factorId == 'totp',
      orElse: () => throw Exception('TOTP não está enrolado.'),
    );

    await user.multiFactor.unenroll(multiFactorInfo: totp);
  }

  /// Conclui o login MFA com o código TOTP fornecido pelo usuário.
  static Future<void> resolveTotp(
    FirebaseAuthMultiFactorException exception,
    String totpCode,
  ) async {
    final resolver = exception.resolver;

    final hint = resolver.hints.firstWhere(
      (h) => h.factorId == 'totp',
      orElse: () => throw Exception('Nenhum fator TOTP encontrado.'),
    );

    // getAssertionForSignIn é assíncrono no SDK Flutter
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      hint.uid,
      totpCode,
    );

    await resolver.resolveSignIn(assertion);
  }
}
