/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';

import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/screens/app/marketplace/market.dart';
import 'package:mescla_invest/screens/app/user/account.dart';
import 'package:mescla_invest/screens/app/user/wallet.dart';
import 'package:mescla_invest/screens/public/auth/verify_email.dart';
import 'package:mescla_invest/screens/public/welcome.dart';
import 'package:mescla_invest/widgets/layout/navbar.dart';

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

  // Estado da navbar fora dos builders — nunca recriado por streams
  NavDestination _currentDestination = NavDestination.catalog;

  // Telas instanciadas uma única vez — IndexedStack preserva o estado delas
  final List<Widget> _screens = const [
    CatalogScreen(),
    MarketScreen(),
    WalletScreen(),
    UserAccountScreen(),
  ];

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

        // -mail não verificado
        if (!firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }

        // Carrega dados do Firestore apenas quando o UID muda
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

            if (userSnapshot.data == null) return const WelcomeScreen();

            // _buildApp usa estado do próprio State — não recria nada
            return _buildApp();
          },
        );
      },
    );
  }

  Widget _buildApp() {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: IndexedStack(
        index: NavDestination.values.indexOf(_currentDestination),
        children: _screens,
      ),
      bottomNavigationBar: NavBar(
        current: _currentDestination,
        onChanged: (dest) => setState(() => _currentDestination = dest),
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.verdeMescla),
      ),
    );
  }
}
