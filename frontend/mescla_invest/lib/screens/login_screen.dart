// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  static const Color verdeMescla = Color(0xFF7FDD3A);
  static const Color fundoEscuro = Color(0xFF121212);
  static const Color campoEscuro = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: campoEscuro,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: verdeMescla),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoEscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 110),
                child: _LogoMesclaInvest(),
              ),
              const SizedBox(height: 55),
              const _TituloEntrar(),
              const SizedBox(height: 42),

              _EmailField(
                controller: _emailController,
                decoration: _inputDecoration(
                  hintText: 'ex: seuemail@email.com',
                ),
              ),

              const SizedBox(height: 28),

              _SenhaField(
                controller: _senhaController,
                senhaVisivel: _senhaVisivel,
                decoration: _inputDecoration(
                  hintText: '• • • • • • •',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _EntrarButton(
                onPressed: () {
                  // TODO: implementar autenticação
                },
              ),

              const SizedBox(height: 18),

              _FooterLinks(
                onCadastrarTap: () {
                  // TODO: navegar para cadastro
                },
                onEsqueciSenhaTap: () {
                  // TODO: navegar para recuperação de senha
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMesclaInvest extends StatelessWidget {
  const _LogoMesclaInvest();

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Mescla',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Invest',
            style: TextStyle(color: verdeMescla),
          ),
        ],
      ),
    );
  }
}

class _TituloEntrar extends StatelessWidget {
  const _TituloEntrar();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Entrar',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  const _EmailField({
    required this.controller,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-mail',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
        ),
      ],
    );
  }
}

class _SenhaField extends StatelessWidget {
  final TextEditingController controller;
  final bool senhaVisivel;
  final InputDecoration decoration;

  const _SenhaField({
    required this.controller,
    required this.senhaVisivel,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Senha',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !senhaVisivel,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
        ),
      ],
    );
  }
}

class _EntrarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EntrarButton({
    required this.onPressed,
  });

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: verdeMescla,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Entrar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final VoidCallback onCadastrarTap;
  final VoidCallback onEsqueciSenhaTap;

  const _FooterLinks({
    required this.onCadastrarTap,
    required this.onEsqueciSenhaTap,
  });

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não tem uma conta? ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            GestureDetector(
              onTap: onCadastrarTap,
              child: const Text(
                'Cadastrar',
                style: TextStyle(
                  color: verdeMescla,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onEsqueciSenhaTap,
          child: const Text(
            'Esqueci minha senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: verdeMescla,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}