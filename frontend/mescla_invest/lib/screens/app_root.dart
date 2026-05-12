/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';

import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app/marketplace/market.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/screens/app/user/account.dart';
import 'package:mescla_invest/screens/app/user/wallet.dart';
import 'package:mescla_invest/screens/public/auth/verify_email.dart';
import 'package:mescla_invest/screens/public/welcome.dart';
import 'package:mescla_invest/widgets/layout/navbar.dart';

// Provider global com os dados do usuário autenticado
final authUserDataProvider = ValueNotifier<UserModel?>(null);

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final Map<NavDestination, Widget> _loadedScreens = {};

  StreamSubscription<User?>? _authSubscription;

  bool _loading = true;
  User? _firebaseUser;

  String? _pendingErrorMessage;

  NavDestination _currentDestination = NavDestination.catalog;

  @override
  void initState() {
    super.initState();

    _authSubscription = FirebaseAuth.instance.userChanges().listen(
      _handleAuthChanged,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    // Usuário deslogado
    if (user == null) {
      authUserDataProvider.value = null;

      _loadedScreens.clear();

      setState(() {
        _firebaseUser = null;
        _loading = false;
      });

      return;
    }

    // E-mail não verificado
    if (!user.emailVerified) {
      setState(() {
        _firebaseUser = user;
        _loading = false;
      });

      return;
    }

    // Carrega usuário do Firestore
    final loadedUser = await _loadUser();

    if (!mounted) return;

    if (loadedUser == null) {
      setState(() {
        _firebaseUser = null;
        _loading = false;
      });

      return;
    }

    authUserDataProvider.value = loadedUser;

    setState(() {
      _firebaseUser = user;
      _loading = false;
    });
  }

  Future<UserModel?> _loadUser() async {
    const maxRetries = 6;
    const delays = [500, 1000, 2000, 4000, 6000, 8000];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final user = await UserModel.getFullUserData();

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

  Widget _getScreen(NavDestination destination) {
    return _loadedScreens.putIfAbsent(destination, () {
      switch (destination) {
        case NavDestination.catalog:
          return const CatalogScreen();

        case NavDestination.market:
          return const MarketScreen();

        case NavDestination.wallet:
          return const WalletScreen();

        case NavDestination.account:
          return const UserAccountScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _flushPendingError();

    if (_loading) {
      return _buildLoading();
    }

    // Não autenticado
    if (_firebaseUser == null) {
      return const WelcomeScreen();
    }

    // Email não verificado
    if (!_firebaseUser!.emailVerified) {
      return const VerifyEmailScreen();
    }

    return _buildApp();
  }

  Widget _buildApp() {
    final currentIndex = NavDestination.values.indexOf(_currentDestination);

    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,

      body: IndexedStack(
        index: currentIndex,

        children: NavDestination.values.map((destination) {
          // Só cria a tela quando ela é aberta pela primeira vez
          if (_loadedScreens.containsKey(destination) ||
              destination == _currentDestination) {
            return _getScreen(destination);
          }

          // Placeholder vazio até abrir a tela
          return const SizedBox.shrink();
        }).toList(),
      ),

      bottomNavigationBar: NavBar(
        current: _currentDestination,

        onChanged: (destination) {
          if (_currentDestination == destination) return;

          setState(() {
            _currentDestination = destination;
          });
        },
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
