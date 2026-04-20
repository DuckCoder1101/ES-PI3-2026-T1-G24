// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/ui/primary_button.dart';

class Confirm2FAScreen extends StatefulWidget {
  const Confirm2FAScreen({super.key});

  @override
  State<Confirm2FAScreen> createState() => _Confirm2FAScreenState();
}

class _Confirm2FAScreenState extends State<Confirm2FAScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateCode() async {
    if (_pinController.text.length < 6) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFunctions.instance.httpsCallable('confirm2FA').call({
        "token": _pinController.text,
      });
      if (!mounted) return;

      // Sucesso: Volta ao início
      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('2FA ativado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String erro = 'Código inválido.';
      if (e is FirebaseFunctionsException) erro = e.message ?? erro;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.redAccent),
      );
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Verificar Código',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Digite o código de 6 dígitos gerado pelo seu app autenticador.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.verdeMescla),
                ),
              ),
              onCompleted: (_) => _validateCode(),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Confirmar e Ativar',
              onPressed: _validateCode,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
