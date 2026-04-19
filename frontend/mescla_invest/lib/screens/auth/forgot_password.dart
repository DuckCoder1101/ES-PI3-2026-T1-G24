// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/components/icon.dart';
import 'package:mescla_invest/components/input.dart';
import 'package:mescla_invest/components/primary_button.dart';
import 'package:mescla_invest/constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Insira seu e-mail para continuar.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showSnackBar('Link de recuperação enviado!', isError: false);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(
        e.code == 'user-not-found'
            ? 'E-mail não cadastrado.'
            : 'Erro ao processar pedido.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: LogoMesclaInvest(),
              ),
              const SizedBox(height: 50),
              const Text(
                'Esqueci a Senha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const InputLabel(texto: 'E-mail'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.field(
                  hintText: 'ex: seuemail@email.com',
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Enviar Email',
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '← Voltar para o Login',
                  style: TextStyle(color: AppColors.verdeMescla),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
