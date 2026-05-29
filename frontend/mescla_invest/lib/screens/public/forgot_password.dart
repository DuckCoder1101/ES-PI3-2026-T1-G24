// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/shared/ui/back_button.dart';
import 'package:mescla_invest/widgets/shared/ui/icon.dart';
import 'package:mescla_invest/widgets/shared/ui/input.dart';
import 'package:mescla_invest/widgets/shared/ui/primary_button.dart';
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

  void _goToLogin() {
    Navigator.of(context).pop();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar(
        msg: 'Insira seu e-mail para continuar.',
        context: context,
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        showSnackbar(msg: 'Link de recuperação enviado!', context: context);
        Navigator.pop(context);
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(onTap: _goToLogin),
                ),
              ),

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
