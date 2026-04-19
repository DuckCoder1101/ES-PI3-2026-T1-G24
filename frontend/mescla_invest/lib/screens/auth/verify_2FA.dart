/// Autor: Cristian Eduardo Fava
/// RA: 25000636

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/primary_button.dart';
import 'package:mescla_invest/components/icon.dart';

class Verify2FAScreen extends StatefulWidget {
  const Verify2FAScreen({super.key});

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

  Future<void> _enviarCodigo() async {
    final token = _pinController.text;
    if (token.length != 6) {
      _showSnackBar('Digite o código completo.');
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseFunctions.instance.httpsCallable("verify2FA").call({
        "token": token,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pop(context);
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        _showSnackBar(e.message ?? 'Erro ao validar código.');
      } else {
        _showSnackBar('Ocorreu um erro inesperado.');
      }
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
    // Estilo Pinput idêntico à tela de ativação para consistência
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
              // Logo MesclaInvest centralizado no topo
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
              const SizedBox(height: 48),

              // Label alinhado à esquerda
              const Text(
                'Código de verificação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Campo OTP (Pinput) centralizado
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
                  // Opcional: Enviar automaticamente quando preencher os 6 dígitos
                  onCompleted: (pin) => _enviarCodigo(),
                ),
              ),
              const SizedBox(height: 40),

              // Botão Enviar Reutilizado
              PrimaryButton(
                text:
                    'Enviar Código', // Ajustado do protótipo que dizia "Enviar Email"
                onPressed: _enviarCodigo,
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
