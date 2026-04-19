// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/components/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/input.dart';
import 'package:mescla_invest/components/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarUsuario() async {
    if ([
      _nomeController,
      _emailController,
      _cpfController,
      _telefoneController,
      _senhaController,
    ].any((c) => c.text.isEmpty)) {
      _showSnackBar('Preencha todos os campos obrigatórios.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      await credencial.user?.getIdToken(true);

      final result = await FirebaseFunctions.instance
          .httpsCallable('signup')
          .call({
            'name': _nomeController.text.trim(),
            'cpf': _cpfController.text.trim(),
            'phone': _telefoneController.text.trim(),
          });

      if (result.data['success'] != true) throw Exception('Falha no cadastro');

      if (!mounted) return;
      _showSnackBar('Cadastro realizado com sucesso!', isError: false);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Erro ao cadastrar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(texto: label, obrigatorio: true),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: AppInputDecoration.field(hintText: hint),
        ),
        const SizedBox(height: 20),
      ],
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
                padding: EdgeInsets.only(top: 85),
                child: LogoMesclaInvest(),
              ),
              const SizedBox(height: 45),
              const Text(
                'Cadastro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              _buildField('Nome Completo', _nomeController, 'Seu nome'),
              _buildField(
                'E-mail',
                _emailController,
                'ex: seuemail@email.com',
                type: TextInputType.emailAddress,
              ),
              _buildField(
                'CPF',
                _cpfController,
                '123.456.789 - 12',
                type: TextInputType.number,
              ),
              _buildField(
                'Telefone celular',
                _telefoneController,
                '+12 34 5678 - 9123',
                type: TextInputType.phone,
              ),

              const InputLabel(texto: 'Crie sua Senha', obrigatorio: true),
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

              const SizedBox(height: 34),
              PrimaryButton(
                text: 'Cadastrar',
                onPressed: _cadastrarUsuario,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              Row(
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
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: AppColors.verdeMescla,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
