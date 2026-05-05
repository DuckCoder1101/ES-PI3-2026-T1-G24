// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/screens/public/auth/forgot_password.dart';
import 'package:mescla_invest/screens/public/welcome.dart';
import 'package:mescla_invest/utils/firebase.dart';
import 'package:mescla_invest/screens/app_root.dart';
import 'package:mescla_invest/firebase_options.dart';
import 'package:mescla_invest/screens/app/user/2fa/confirm_2fa.dart';
import 'package:mescla_invest/screens/app/user/2fa/enable_2fa.dart';
import 'package:mescla_invest/screens/public/auth/signin.dart';
import 'package:mescla_invest/screens/public/auth/signup.dart';
import 'package:mescla_invest/screens/public/auth/verify_2fa.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/screens/app/startups/startup_details.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    FirebaseService.init();
  }

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
      home: AppRoot(),
      routes: {
        "/welcome": (ctx) => const WelcomeScreen(),

        "/dashboard/home": (ctx) => const CatalogScreen(),
        "/dashboard/startup-details": (ctx) {
          final startupId = ModalRoute.of(ctx)!.settings.arguments as String?;
          return StartupDetailsScreen(startupId: startupId);
        },

        "/auth/signin": (ctx) => const SigninScreen(),
        "/auth/signup": (ctx) => const SignupScreen(),
        "/auth/forgot-password": (ctx) => const ForgotPasswordScreen(),
        "/auth/verify-2fa": (ctx) => const Verify2FAScreen(),
        "/auth/enable-2fa": (ctx) => const Enable2FAScreen(),
        "/auth/confirm-2fa": (ctx) => const Confirm2FAScreen(),
      },
    );
  }
}
