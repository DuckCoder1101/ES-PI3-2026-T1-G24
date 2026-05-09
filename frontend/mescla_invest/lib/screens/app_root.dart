/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/screens/public/auth/verify_email.dart';
import 'package:mescla_invest/screens/public/welcome.dart';

final authUserDataProvider = ValueNotifier<UserModel?>(null);

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Future<UserModel?>? _userFuture;
  User? _lastFirebaseUser;
  String? _pendingErrorMessage;

  // app_root.dart - Ajuste no _loadUser
  Future<UserModel?> _loadUser(User firebaseUser) async {
    const maxRetries = 6;
    const delays = [500, 1000, 2000, 4000, 6000, 8000];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final user = await UserModel.getFullUserData();
        authUserDataProvider.value = user;
        return user;
      } on FirebaseFunctionsException catch (err) {
        if (err.code == 'not-found' && attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: delays[attempt]));
          continue;
        }
        _pendingErrorMessage = 'Erro ao carregar dados da conta.';
        break;
      } catch (_) {
        _pendingErrorMessage = 'Erro de conexão.';
        break;
      }
    }

    await UserModel.signout();
    return null;
  }

  void _flushPendingError() {
    if (_pendingErrorMessage == null) return;
    final message = _pendingErrorMessage!;
    _pendingErrorMessage = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _flushPendingError();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        final firebaseUser = authSnapshot.data;

        // Não autenticado
        if (firebaseUser == null) {
          _lastFirebaseUser = null;
          _userFuture = null;
          authUserDataProvider.value = null;
          return const WelcomeScreen();
        }

        // Bloqueia o acesso ao app até a verificação ser concluída.
        if (!firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }

        // ── E-mail verificado: carrega dados do Firestore ────────────────
        if (_userFuture == null || firebaseUser.uid != _lastFirebaseUser?.uid) {
          _lastFirebaseUser = firebaseUser;
          _userFuture = _loadUser(firebaseUser);
        }

        return FutureBuilder<UserModel?>(
          future: _userFuture,
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            final user = userSnapshot.data;
            if (user == null) return const WelcomeScreen();

            return const CatalogScreen();
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
