/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:firebase_auth/firebase_auth.dart';

// Dados retornados ao iniciar o TOTP.
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

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: (map['name'] as String?)?.toUpperCase() ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
