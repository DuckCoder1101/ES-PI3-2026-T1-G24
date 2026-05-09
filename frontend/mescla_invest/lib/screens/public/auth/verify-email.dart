// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isCheckingVerification = false;
  bool _isResending = false;
  bool _resentRecently = false;

  String get _email => FirebaseAuth.instance.currentUser?.email ?? 'seu e-mail';

  /// Recarrega o usuário do Firebase e verifica se o e-mail foi confirmado.
  Future<void> _checkVerification() async {
    setState(() => _isCheckingVerification = true);

    try {
      // Força atualização do token — sem isso emailVerified fica em cache
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;

      if (!mounted) return;

      if (verified) {
        // AppRoot vai detectar a mudança via authStateChanges e redirecionar
        // automaticamente. Não precisamos navegar manualmente.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-mail ainda não verificado. Confira sua caixa de entrada.',
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao verificar. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingVerification = false);
    }
  }

  /// Reenvia o e-mail de verificação com cooldown de 30s.
  Future<void> _resendEmail() async {
    if (_resentRecently) return;
    setState(() => _isResending = true);

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;

      setState(() {
        _isResending = false;
        _resentRecently = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail reenviado com sucesso!'),
          backgroundColor: AppColors.verdeMescla,
        ),
      );

      // Cooldown de 30s antes de permitir reenvio novamente
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) setState(() => _resentRecently = false);
    } catch (err) {
      debugPrint("Erro ao enviar email: $err");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao reenviar o e-mail. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _logout() async {
    await UserModel.signout();
    // AppRoot retorna para WelcomeScreen automaticamente
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _logout();
      },
      child: Scaffold(
        backgroundColor: AppColors.fundoEscuro,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Botão de sair no topo
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.campoEscuro,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                const LogoMesclaInvest(),

                const SizedBox(height: 26),

                const Text(
                  'Confirme seu e-mail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 36),

                // Descrição com e-mail em destaque
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Enviamos um link de verificação para\n',
                      ),
                      TextSpan(
                        text: _email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '\n\nClique no link do e-mail e depois toque em\n"Confirmar verificação" abaixo.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Botão principal
                PrimaryButton(
                  text: 'Confirmar verificação',
                  onPressed: _checkVerification,
                  isLoading: _isCheckingVerification,
                ),

                const SizedBox(height: 20),

                // Reenviar e-mail
                GestureDetector(
                  onTap: _isResending || _resentRecently ? null : _resendEmail,
                  child: AnimatedOpacity(
                    opacity: _resentRecently ? 0.4 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isResending)
                          const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.verdeMescla,
                            ),
                          )
                        else
                          const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.verdeMescla,
                            size: 16,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          _resentRecently
                              ? 'E-mail reenviado!'
                              : 'Reenviar e-mail de verificação',
                          style: const TextStyle(
                            color: AppColors.verdeMescla,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
