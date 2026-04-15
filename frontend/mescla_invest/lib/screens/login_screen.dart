// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cadastro_screen.dart';

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

              _EntrarButton(onPressed: _loginUsuario),

              const SizedBox(height: 18),

              _FooterLinks(
                onCadastrarTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroScreen(),
                    ),
                  );
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

  Future<void> _loginUsuario() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha email e senha.')));
      return;
    }

    try {
      // 1. Login no Firebase Auth
      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // 2. Garante que o token está atualizado (importante para onCall depois)
      await credencial.user?.getIdToken(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login efetuado com sucesso!")));

      // Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');

      String mensagemErro = 'Erro ao fazer login.';

      if (e.code == 'user-not-found') {
        mensagemErro = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        mensagemErro = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'E-mail inválido.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErro)));
    } catch (e) {
      debugPrint('Erro inesperado: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
    }
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
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  const _EmailField({required this.controller, required this.decoration});

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

  const _EntrarButton({required this.onPressed});

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: verdeMescla,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Entrar',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.white70, fontSize: 13),
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
            style: TextStyle(color: verdeMescla, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
