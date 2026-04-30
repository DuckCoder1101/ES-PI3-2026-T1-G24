/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

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

      if (result.data == null) {
        throw Exception("Usuário não encontrado no banco de dados.");
      }

      final dataMap = Map<String, dynamic>.from(result.data);
      final user = UserModel.fromMap(dataMap);

      return user;
    } catch (e) {
      debugPrint("Erro no UserModel: $e");
      rethrow;
    }
  }

  static Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
