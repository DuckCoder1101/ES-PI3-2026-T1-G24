// Autor: Cristian Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/models/authSession.dart';
import 'package:mescla_invest/screens/auth/signin.dart';
import 'package:mescla_invest/screens/auth/verify_2FA.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // não logado
    if (user == null) {
      return const SigninScreen();
    }

    // logado mas sem 2FA completo
    if (!AuthSession.isFullyAuthenticated) {
      return const Verify2FAScreen();
    }

    return child;
  }
}
