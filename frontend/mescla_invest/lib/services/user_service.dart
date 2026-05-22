/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mescla_invest/models/user/investment_model.dart';
import 'package:mescla_invest/models/user/transaction_model.dart';
import 'package:mescla_invest/models/user/user_model.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';

class UserService {
  // Retorna o URL da foto de perfil
  static Future<String?> getAvatarUrl() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseStorage.instance
        .ref("/users/$uid/avatar")
        .getDownloadURL();
  }

  // Salva uma nova foto de perfil
  static Future<void> uploadAvatarPicture(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseStorage.instance.ref("/users/$uid/avatar").putFile(file);
  }

  // Dados do usuário
  static Future<UserModel> getFullUserData() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getMe')
          .call();

      return UserModel.fromMap(Map<String, dynamic>.from(result.data));
    } catch (e) {
      rethrow;
    }
  }

  // Cadastro
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

      await credential.user?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  // Alteração de dados
  static Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    name = name.trim();
    phone = phone.trim();

    await FirebaseFunctions.instance.httpsCallable("updateProfile").call({
      "name": name,
      "phone": phone,
    });
  }

  // Efetua o login
  static Future<void> signin(String email, String password) async {
    email = email.trim();
    password = password.trim();

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Efetua signout
  static Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Obtem o otpaughturl do servidor
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

  // Finaliza o enrolamento com o código de 6 dígitos do app autenticador.
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

  // Desativa o 2FA.
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

  // Conclui o login MFA com o código TOTP fornecido pelo usuário.
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

  // Verifica se TOTP está ativo
  static Future<bool> checkHas2Fa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final factors = await user.multiFactor.getEnrolledFactors();
    return factors.any((f) => f.factorId == 'totp');
  }

  // Retorna saldo disponível e saldo bloqueado do usuário
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

  // Adiciona saldo fictício à carteira do usuário
  static Future<void> addFunds(double funds) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('addFunds').call({
        'funds': funds,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Busca o histórico completo de transações do usuário
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

  // Busca todos os investimentos do usuário
  static Future<List<InvestmentModel>> getUserInvestments() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getUserInvestments')
          .call();

      final data = Map<String, dynamic>.from(response.data);
      final List raw = data['investments'] ?? [];

      return raw
          .map((i) => InvestmentModel.fromMap(Map<String, dynamic>.from(i)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Compra tokens de uma startup para um usuário
  static Future<void> buyTokens({
    required String startupId,
    required int tokenAmount,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('buyTokens').call({
        'startupId': startupId,
        'tokenAmount': tokenAmount,
      });
    } catch (e) {
      rethrow;
    }
  }
}
