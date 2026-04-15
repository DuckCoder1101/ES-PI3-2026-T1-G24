// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;

  static const Color verdeMescla = Color(0xFF7FDD3A);
  static const Color fundoEscuro = Color(0xFF121212);
  static const Color campoEscuro = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
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
                padding: EdgeInsets.only(top: 85),
                child: _LogoMesclaInvest(),
              ),
              const SizedBox(height: 45),
              const _TituloCadastro(),
              const SizedBox(height: 40),

              _CampoCadastro(
                label: 'Nome Completo',
                obrigatorio: true,
                controller: _nomeController,
                decoration: _inputDecoration(
                  hintText: 'Seu nome',
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),

              _CampoCadastro(
                label: 'E-mail',
                obrigatorio: true,
                controller: _emailController,
                decoration: _inputDecoration(
                  hintText: 'ex: seuemail@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _CampoCadastro(
                label: 'CPF',
                obrigatorio: true,
                controller: _cpfController,
                decoration: _inputDecoration(
                  hintText: '123.456.789 - 12',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _CampoCadastro(
                label: 'Telefone celular',
                obrigatorio: true,
                controller: _telefoneController,
                decoration: _inputDecoration(
                  hintText: '+12 34 5678 - 9123',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _CampoSenhaCadastro(
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
              const SizedBox(height: 34),

              _BotaoCadastrar(
                onPressed: () {
                  // TODO: implementar cadastro
                },
              ),
              const SizedBox(height: 16),

              _FooterCadastro(
                onEntrarTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
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

class _TituloCadastro extends StatelessWidget {
  const _TituloCadastro();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Cadastro',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CampoCadastro extends StatelessWidget {
  final String label;
  final bool obrigatorio;
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;

  const _CampoCadastro({
    required this.label,
    required this.obrigatorio,
    required this.controller,
    required this.decoration,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelCampo(
          texto: label,
          obrigatorio: obrigatorio,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
        ),
      ],
    );
  }
}

class _CampoSenhaCadastro extends StatelessWidget {
  final TextEditingController controller;
  final bool senhaVisivel;
  final InputDecoration decoration;

  const _CampoSenhaCadastro({
    required this.controller,
    required this.senhaVisivel,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabelCampo(
          texto: 'Crie sua Senha',
          obrigatorio: true,
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

class _LabelCampo extends StatelessWidget {
  final String texto;
  final bool obrigatorio;

  const _LabelCampo({
    required this.texto,
    required this.obrigatorio,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: texto),
          if (obrigatorio)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

class _BotaoCadastrar extends StatelessWidget {
  final VoidCallback onPressed;

  const _BotaoCadastrar({
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Cadastrar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FooterCadastro extends StatelessWidget {
  final VoidCallback onEntrarTap;

  const _FooterCadastro({
    required this.onEntrarTap,
  });

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Já tem uma conta? ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: onEntrarTap,
          child: const Text(
            'Entrar',
            style: TextStyle(
              color: verdeMescla,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}