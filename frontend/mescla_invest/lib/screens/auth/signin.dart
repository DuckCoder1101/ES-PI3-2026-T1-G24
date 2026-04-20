// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/components/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/ui/input.dart';
import 'package:mescla_invest/components/ui/primary_button.dart';
import 'package:mescla_invest/models/authSession.dart';

import 'forgot_password.dart'; // Importe a nova tela

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
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

      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final idTokenResult = await credencial.user?.getIdTokenResult(true);

      if (!mounted) return;

      final bool has2FA = idTokenResult?.claims?['twoFactorEnabled'] ?? false;

      if (has2FA) {
        AuthSession.isFullyAuthenticated = false;
        Navigator.pushReplacementNamed(context, '/auth/verify-otp');
        return;
      }

      // sem 2FA
      AuthSession.isFullyAuthenticated = true;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagemErro;

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          mensagemErro = 'E-mail ou senha incorretos.';
          break;

        case 'invalid-email':
          mensagemErro = 'E-mail inválido.';
          break;

        case 'user-disabled':
          mensagemErro = 'Esta conta foi desativada.';
          break;

        case 'too-many-requests':
          mensagemErro = 'Muitas tentativas. Tente novamente mais tarde.';
          break;

        case 'network-request-failed':
          mensagemErro = 'Erro de conexão. Verifique sua internet.';
          break;

        default:
          mensagemErro = 'Erro ao fazer login. Tente novamente.';
          debugPrint("Erro FirebaseAuth: ${e.code} - ${e.message}");
      }

      _showSnackBar(mensagemErro);
    } catch (e) {
      if (!mounted) return;

      debugPrint("Erro inesperado: $e");
      _showSnackBar('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
