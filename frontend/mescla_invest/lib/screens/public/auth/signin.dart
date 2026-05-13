// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/models/user/user.dart';
import 'package:mescla_invest/screens/public/auth/verify_2fa.dart';
import 'package:mescla_invest/widgets/ui/back_button.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/ui/input.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';

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
  bool _invalidCredentials = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  Future<void> _loginUsuario() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _invalidCredentials = false;
      _errorMessage = null;
    });

    try {
      await UserModel.signin(_emailController.text, _passwordController.text);

      // Login simples (sem MFA): AppRoot detecta via authStateChanges
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      // Usuário tem TOTP enrolado: redireciona para verificação
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Verify2FAScreen(multiFactorException: e),
        ),
      );

      // Após resolver o MFA, volta à raiz (AppRoot assumirá o controle)
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "user-not-found" ||
            e.code == "invalid-credential" ||
            e.code == "wrong-password") {
          _invalidCredentials = true;
          _errorMessage = "E-Mail ou senha inválidos!";
        } else if (e.code == "network-request-failed") {
          _errorMessage = "Falha ao conectar com a internet!";
        } else {
          _errorMessage = "Erro de autenticação. Tente novamente.";
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (err) {
      debugPrint(err.toString());
      if (!mounted) return;
      setState(
        () => _errorMessage = "Erro desconhecido. Tente novamente mais tarde!",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 2),
  );

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
              // Botão quadrado de voltar no topo esquerdo
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(onTap: _goToWelcome),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 110),
                child: LogoMesclaInvest(fontSize: 32),
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
                onChanged: (_) {
                  if (_invalidCredentials) {
                    setState(() => _invalidCredentials = false);
                  }
                },
                decoration:
                    AppInputDecoration.field(
                      hintText: 'ex: seuemail@email.com',
                    ).copyWith(
                      enabledBorder: _border(
                        _invalidCredentials ? Colors.red : Colors.transparent,
                      ),
                      focusedBorder: _border(
                        _invalidCredentials
                            ? Colors.red
                            : AppColors.verdeMescla,
                      ),
                    ),
              ),
              const SizedBox(height: 28),
              const InputLabel(texto: 'Senha'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_senhaVisivel,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) {
                  if (_invalidCredentials) {
                    setState(() => _invalidCredentials = false);
                  }
                },
                decoration:
                    AppInputDecoration.field(
                      hintText: '• • • • • • •',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textoHint,
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ).copyWith(
                      enabledBorder: _border(
                        _invalidCredentials ? Colors.red : Colors.transparent,
                      ),
                      focusedBorder: _border(
                        _invalidCredentials
                            ? Colors.red
                            : AppColors.verdeMescla,
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
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, "/auth/forgot-password"),
                child: const Text(
                  'Esqueci minha senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.verdeMescla, fontSize: 13),
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
