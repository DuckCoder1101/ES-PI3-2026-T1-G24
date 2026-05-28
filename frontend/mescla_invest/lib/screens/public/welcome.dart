/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Center(child: LogoMesclaInvest(fontSize: 32)),

              const SizedBox(height: 20),

              // SUBTÍTULO
              const Text(
                'Sua plataforma inteligente para\ninvestimentos e startups.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // BOTÃO LOGIN
              PrimaryButton(
                text: 'Entrar',
                onPressed: () {
                  Navigator.pushNamed(context, "/auth/signin");
                },
              ),

              const SizedBox(height: 16),

              // BOTÃO CADASTRO
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/auth/signup");
                },

                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.verdeMescla,
                    width: 2,
                  ),

                  padding: const EdgeInsets.symmetric(vertical: 20),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  'Criar Conta',
                  style: TextStyle(
                    color: AppColors.verdeMescla,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
