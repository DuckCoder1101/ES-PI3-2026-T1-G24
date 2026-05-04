// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/ui/input.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';

import 'forgot_password.dart'; // Importe a nova tela

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _senhaVisivel = false;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUsuario() async {
    try {
      setState(() => _isLoading = true);

      // Tenta efetuar o login
      await UserModel.signin(_emailController.text, _passwordController.text);
    } on ArgumentError catch (e) {
      _errorMessage = e.message;
    } on FirebaseAuthException catch (e) {
      // Mensagens de erro de acordo com o código
      if (e.code == "user-not-found" || e.code == "auth/wrong-password") {
        _errorMessage = "E-Mail ou senha inválidos!";
      } else if (e.code == "auth/network-request-failed") {
        _errorMessage = "Falha ao conectar com a internet!";
      } else {
        debugPrint(e.code);
        rethrow;
      }
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = "Tente novamente mais tarde ou contate o suporte!";
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);

        // Mensagem final
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? "Login efetuado com sucesso!"),
            backgroundColor: _errorMessage != null
                ? Colors.redAccent
                : Colors.green,
          ),
        );
      }
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
                controller: _passwordController,
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
