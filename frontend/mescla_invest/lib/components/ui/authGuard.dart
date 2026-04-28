import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/auth/signin.dart';
import 'package:mescla_invest/screens/auth/verify_2fa.dart';

// Este é o "passe" que indica que o 2FA foi validado manualmente nesta sessão
final auth2FaPassedProvider = ValueNotifier<bool>(false);

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  Future<bool> _shouldAllowAccess(User firebaseUser) async {
    // Se ele já passou pela verificação nesta sessão, libera direto
    if (auth2FaPassedProvider.value) return true;

    try {
      final userDoc = await UserModel.getFullUserData();
      // Se não tem 2FA ativado, libera. Se tem, bloqueia (retorna false)
      return !userDoc.has2Fa;
    } catch (e) {
      debugPrint("Erro no AuthGuard: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o ValueNotifier para reconstruir quando o usuário validar o código
    return ValueListenableBuilder<bool>(
      valueListenable: auth2FaPassedProvider,
      builder: (context, hasPassed, _) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final firebaseUser = authSnapshot.data;
            if (firebaseUser == null) {
              auth2FaPassedProvider.value = false; // Reseta se deslogar
              return const SigninScreen();
            }

            return FutureBuilder<bool>(
              future: _shouldAllowAccess(firebaseUser),
              builder: (context, mfaSnapshot) {
                if (mfaSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Libera se o banco disser que não tem 2FA OU se ele acabou de validar
                if (mfaSnapshot.data == true || hasPassed) {
                  return child;
                } else {
                  return const Verify2FAScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
