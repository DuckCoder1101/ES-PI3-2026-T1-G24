// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/components/ui/authGuard.dart';
import 'package:mescla_invest/constants/firebase.dart';
import 'package:mescla_invest/firebase_options.dart';
import 'package:mescla_invest/screens/auth/confirm_2fa.dart';
import 'package:mescla_invest/screens/auth/enable_2fa.dart';
import 'package:mescla_invest/screens/auth/signin.dart';
import 'package:mescla_invest/screens/auth/signup.dart';
import 'package:mescla_invest/screens/auth/verify_2fa.dart';
import 'package:mescla_invest/screens/dashboard/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7FDD3A)),
      ),
      home: AuthGuard(child: const HomeScreen()),
      routes: {
        "/home": (ctx) => const AuthGuard(child: HomeScreen()),
        "/auth/signin": (ctx) => const SigninScreen(),
        "/auth/signup": (ctx) => const SignupScreen(),
        "/auth/verify-2fa": (ctx) => const Verify2FAScreen(),
        "/auth/enable-2fa": (ctx) => const AuthGuard(child: Enable2FAScreen()),
        "/auth/confirm-2fa": (ctx) =>
            const AuthGuard(child: Confirm2FAScreen()),
      },
    );
  }
}
