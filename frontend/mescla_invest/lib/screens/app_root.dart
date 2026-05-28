/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/user_model.dart';
import 'package:mescla_invest/screens/app/marketplace/market_screen.dart';
import 'package:mescla_invest/screens/app/startup/catalog_screen.dart';
import 'package:mescla_invest/screens/app/account/account_screen.dart';
import 'package:mescla_invest/screens/app/wallet/wallet_screen.dart';
import 'package:mescla_invest/screens/public/auth/verify_email.dart';
import 'package:mescla_invest/screens/public/welcome.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/widgets/layout/navbar.dart';
import 'package:mescla_invest/screens/app/home/home_screen.dart';

final authUserDataProvider = ValueNotifier<UserModel?>(null);

enum _AuthState { loading, unauthenticated, unverified, authenticated }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  StreamSubscription<User?>? _authSubscription;

  _AuthState _authState = _AuthState.loading;
  NavDestination _currentDestination = NavDestination.home;

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

    setState(() => _authState = _AuthState.loading);

    if (user == null) {
      authUserDataProvider.value = null;
      return setState(() {
        _authState = _AuthState.unauthenticated;
      });
    }

    if (!user.emailVerified) {
      return setState(() {
        _authState = _AuthState.unverified;
      });
    }

    final loadedUser = await _loadUser();

    if (!mounted) return;

    if (loadedUser == null) {
      return setState(() {
        _authState = _AuthState.unauthenticated;
      });
    }

    authUserDataProvider.value = loadedUser;

    setState(() {
      _authState = _AuthState.authenticated;
    });
  }

  Future<UserModel?> _loadUser() async {
    try {
      return await UserService.getFullUserData();
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    }

    await UserService.signout();
    return null;
  }

  Widget _buildScreen(NavDestination destination) => switch (destination) {
    NavDestination.home => const HomeScreen(),
    NavDestination.catalog => const CatalogScreen(),
    NavDestination.market => const MarketScreen(),
    NavDestination.wallet => const WalletScreen(),
    NavDestination.account => const UserAccountScreen(),
  };

  @override
  Widget build(BuildContext context) => switch (_authState) {
    _AuthState.loading => _buildLoading(),
    _AuthState.unauthenticated => const WelcomeScreen(),
    _AuthState.unverified => const VerifyEmailScreen(),
    _AuthState.authenticated => _buildApp(),
  };

  Widget _buildApp() {
    final currentIndex = NavDestination.values.indexOf(_currentDestination);

    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: IndexedStack(
        index: currentIndex,
        children: NavDestination.values.map(_buildScreen).toList(),
      ),
      bottomNavigationBar: NavBar(
        current: _currentDestination,
        onChanged: (destination) {
          if (_currentDestination != destination) {
            setState(() => _currentDestination = destination);
          }
        },
      ),
    );
  }

  Widget _buildLoading() => const Scaffold(
    backgroundColor: AppColors.fundoEscuro,
    body: Center(
      child: CircularProgressIndicator(color: AppColors.verdeMescla),
    ),
  );
}
