/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/screens/public/auth/verify_2fa.dart';
import 'package:mescla_invest/screens/public/welcome.dart';

// Providers globais de sessão — importados por outras telas para reagir ao estado
final auth2FaPassedProvider = ValueNotifier<bool>(false);
final authUserDataProvider = ValueNotifier<UserModel?>(null);

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // Cache do Future de carregamento para não re-executar a cada rebuild
  Future<UserModel?>? _userFuture;

  // Controla troca de conta: recria _userFuture apenas quando o UID muda
  User? _lastFirebaseUser;

  // Mensagem pendente a ser exibida via SnackBar após o próximo frame
  // (usada quando o deslogin é forçado por erro, ex: sessão expirada)
  String? _pendingErrorMessage;
  //
  Future<UserModel?> _loadUser(User firebaseUser) async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 1500);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final user = await UserModel.getFullUserData();

        authUserDataProvider.value = user;

        // Usuários sem 2FA passam direto para o catálogo
        if (!user.has2Fa) {
          auth2FaPassedProvider.value = true;
        }

        return user;
      } on FirebaseFunctionsException catch (err) {
        if (err.code == 'not-found' && attempt < maxRetries) {
          await Future.delayed(retryDelay);
          continue;
        }

        _pendingErrorMessage = switch (err.code) {
          'unauthenticated' => 'Sessão expirada. Faça login novamente.',
          'not-found' => 'Conta não encontrada. Tente novamente.',
          _ => 'Erro ao carregar dados. Tente novamente.',
        };

        await UserModel.signout();
        return null;
      } catch (_) {
        _pendingErrorMessage = 'Erro inesperado. Tente novamente mais tarde.';
        await UserModel.signout();
        return null;
      }
    }

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
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        final firebaseUser = authSnapshot.data;

        // --- Não autenticado ---
        if (firebaseUser == null) {
          _lastFirebaseUser = null;
          _userFuture = null;
          authUserDataProvider.value = null;
          auth2FaPassedProvider.value = false;
          return const WelcomeScreen();
        }

        // Só recria o Future quando o usuário muda (login com outra conta)
        if (_userFuture == null || firebaseUser.uid != _lastFirebaseUser?.uid) {
          _lastFirebaseUser = firebaseUser;
          _userFuture = _loadUser(firebaseUser);
          auth2FaPassedProvider.value = false;
        }

        return FutureBuilder<UserModel?>(
          future: _userFuture,
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            final user = userSnapshot.data;

            if (user == null) {
              return const WelcomeScreen();
            }

            // --- Dados carregados: decide qual tela exibir ---
            return ValueListenableBuilder<bool>(
              valueListenable: auth2FaPassedProvider,
              builder: (context, passed2FA, _) {
                if (user.has2Fa && !passed2FA) {
                  return const Verify2FAScreen();
                }
                return const CatalogScreen();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
