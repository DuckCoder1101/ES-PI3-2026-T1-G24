/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_invest/widgets/logic/app_root.dart';

class UserModel {
  final String uid;
  final String avatarUrl;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final DateTime createdAt;
  final bool has2Fa;

  UserModel({
    required this.uid,
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.createdAt,
    required this.has2Fa,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Extrai o mapa do createdAt
    final createdAtMap = map['createdAt'] as Map<String, dynamic>;

    // Converte para DateTime puro
    final seconds = createdAtMap['_seconds'] as int;
    final nanos = createdAtMap['_nanoseconds'] as int;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      (seconds * 1000) + (nanos ~/ 1000000),
      isUtc: true,
    ).toLocal();

    return UserModel(
      uid: map['uid'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: dateTime,
      has2Fa: map['has2Fa'] ?? false,
    );
  }

  static Future<UserModel> getFullUserData() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getMe')
          .call();

      final dataMap = Map<String, dynamic>.from(result.data);
      final user = UserModel.fromMap(dataMap);

      return user;
    } catch (e) {
      rethrow;
    }
  }

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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFunctions.instance.httpsCallable('signup').call({
        'name': name,
        'cpf': cpf,
        'phone': phone,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signin(String email, String password) async {
    email = email.trim();
    password = password.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (err) {
      rethrow;
    }
  }

  static Future<void> signout() async {
    try {
      auth2FaPassedProvider.value = false;
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, String?>> get2FACode() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('enable2FA')
          .call();

      return {
        "otpauth": result.data['otpauth'],
        "manualKey": result.data['manualKey'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
