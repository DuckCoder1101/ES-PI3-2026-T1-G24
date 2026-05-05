import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app/catalog.dart';
import 'package:mescla_invest/screens/public/auth/2fa/verify_2fa.dart';
import 'package:mescla_invest/screens/public/welcome.dart';

final auth2FaPassedProvider = ValueNotifier<bool>(false);

final authUserDataProvider = ValueNotifier<UserModel?>(null);

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  Future<UserModel?> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    try {
      final user = await UserModel.getFullUserData();

      authUserDataProvider.value = user;

      // libera automaticamente
      // usuários sem 2FA
      if (!user.has2Fa) {
        auth2FaPassedProvider.value = true;
      }

      return user;
    } catch (e) {
      debugPrint(e.toString());

      await FirebaseAuth.instance.signOut();

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, authSnapshot) {
        // loading auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // não autenticado
        if (authSnapshot.data == null) {
          return const WelcomeScreen();
        }

        // autenticado
        return FutureBuilder<UserModel?>(
          future: _loadUser(),

          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = userSnapshot.data;

            if (user == null) {
              return const WelcomeScreen();
            }

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
}
