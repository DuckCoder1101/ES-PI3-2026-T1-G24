// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/firebase_options.dart';
import 'package:mescla_invest/screens/auth/confirm_2FA.dart';
import 'package:mescla_invest/screens/auth/enable_2FA.dart';
import 'package:mescla_invest/screens/auth/login.dart';
import 'package:mescla_invest/screens/auth/register.dart';
import 'package:mescla_invest/screens/auth/verify_2FA.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const LoginScreen(),
      routes: {
        "/auth/signup": (ctx) => const SignupScreen(),
        "/auth/verify-2fa": (ctx) => const Verify2FAScreen(),
        "/auth/enable-2fa": (ctx) => const Enable2FAScreen(),
        "/auth/confirm-2fa": (ctx) => const Confirm2FAScreen(),
      },
    );
  }
}
