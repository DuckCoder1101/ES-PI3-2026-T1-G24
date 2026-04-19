// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/components/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/input.dart';
import 'package:mescla_invest/components/primary_button.dart';

import 'forgot_password.dart'; // Importe a nova tela

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loginUsuario() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _showSnackBar('Preencha email e senha.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final idTokenResult = await credencial.user?.getIdTokenResult(true);
      final bool has2FA = idTokenResult?.claims?['twoFactorEnabled'] ?? false;

      if (!mounted) return;

      if (has2FA) {
        Navigator.pushReplacementNamed(context, '/auth/verify-otp');
        return;
      }

      if (!mounted) return;
      _showSnackBar('Login realizado com sucesso!', isError: false);

      // Teste 2Fa
      Navigator.pushNamed(context, "/auth/enable-2fa");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagemErro;

      if (e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else if (e.code == 'user-disabled') {
        mensagemErro = 'Esta conta foi desativada.';
      } else if (e.code == 'too-many-requests') {
        mensagemErro = 'Muitas tentativas. Tente novamente mais tarde.';
      } else {
        mensagemErro = 'Erro ao fazer login: ${e.message}';
      }

      _showSnackBar(mensagemErro);
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
                padding: EdgeInsets.only(top: 110),
                child: LogoMesclaInvest(),
              ),
              const SizedBox(height: 55),
              const Text(
                'Entrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 42),

              const InputLabel(texto: 'E-mail'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.field(
                  hintText: 'ex: seuemail@email.com',
                ),
              ),

              const SizedBox(height: 28),

              const InputLabel(texto: 'Senha'),
              const SizedBox(height: 8),
              TextField(
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.field(
                  hintText: '• • • • • • •',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textoHint,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                text: 'Entrar',
                onPressed: _loginUsuario,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 18),

              _FooterLinks(
                onCadastrarTap: () =>
                    Navigator.pushNamed(context, "/auth/signup"),
                onEsqueciSenhaTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                ),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não tem uma conta? ',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            GestureDetector(
              onTap: onCadastrarTap,
              child: const Text(
                'Cadastrar',
                style: TextStyle(
                  color: AppColors.verdeMescla,
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
            style: TextStyle(color: AppColors.verdeMescla, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
