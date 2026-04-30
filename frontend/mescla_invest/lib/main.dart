// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/firebase_options.dart';
import 'package:mescla_invest/screens/login_screen.dart';
import 'package:mescla_invest/screens/qa_screen.dart';

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
      home: const QaScreen(startupId: '3T6WbL2zAqFLL26ehGvU', startupName: 'EcoTech PUC'),
    );
  }
}