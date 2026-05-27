// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:pinput/pinput.dart';

import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';

/// Tela de verificação TOTP usada durante o login
class Verify2FAScreen extends StatefulWidget {
  final FirebaseAuthMultiFactorException multiFactorException;

  const Verify2FAScreen({super.key, required this.multiFactorException});

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    final token = _pinController.text.trim();
    if (token.length != 6) {
      showSnackbar(
        msg: 'Digite o código completo de 6 dígitos.',
        context: context,
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService.resolveTotp(widget.multiFactorException, token);

      if (mounted) {
        Navigator.of(context).pop();
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
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: LogoMesclaInvest(),
              ),
              const SizedBox(height: 60),
              const Text(
                'Verificação de duas etapas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Abra seu app autenticador e insira\no código de 6 dígitos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),
              const Text(
                'Código de verificação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.verdeMescla),
                    ),
                  ),
                  onCompleted: (_) => _verificarCodigo(),
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Verificar',
                onPressed: _verificarCodigo,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
