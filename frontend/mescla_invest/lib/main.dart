import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mescla_invest/screens/app/startup/startup_details_screen.dart';
import 'package:mescla_invest/screens/app/account/activate_2fa_screen.dart';
import 'package:mescla_invest/screens/public/auth/forgot_password.dart';
import 'package:mescla_invest/screens/public/welcome.dart';
import 'package:mescla_invest/screens/app_root.dart';
import 'package:mescla_invest/firebase_options.dart';
import 'package:mescla_invest/screens/public/auth/signin.dart';
import 'package:mescla_invest/screens/public/auth/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("pt_BR", null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MesclaInvest());
}

class MesclaInvest extends StatelessWidget {
  const MesclaInvest({super.key});

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

        "/startups/startup-details": (ctx) {
          final startupId = ModalRoute.of(ctx)!.settings.arguments as String;

          return StartupDetailsScreen(startupId: startupId);
        },

        "/auth/activate-2fa": (ctx) => const Activate2FAScreen(),

        "/auth/signin": (ctx) => const SigninScreen(),
        "/auth/signup": (ctx) => const SignupScreen(),
        "/auth/forgot-password": (ctx) => const ForgotPasswordScreen(),
      },
    );
  }
}
