// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mescla_invest/components/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/ui/input.dart';
import 'package:mescla_invest/components/ui/primary_button.dart';
import 'package:mescla_invest/formatters/cpf_input_format.dart';
import 'package:mescla_invest/formatters/phone_input_format.dart';

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

  // Mapa de erros por campo
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _setFieldErrors(Map errors) {
    setState(() {
      _fieldErrors = Map<String, String>.from(errors);
    });
  }

  Future<void> _cadastrarUsuario() async {
    // Limpa erros antigos
    setState(() => _fieldErrors = {});

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

      await FirebaseFunctions.instance.httpsCallable('signup').call({
        'name': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'phone': _telefoneController.text.trim(),
      });

      if (!mounted) return;

      Navigator.of(context).pop();
      _showSnackBar('Cadastro realizado com sucesso!', isError: false);
    } catch (e) {
      if (!mounted) return;

      if (e is FirebaseFunctionsException) {
        final details = e.details;

        if (details is Map) {
          _setFieldErrors(details);
        }

        _showSnackBar(e.message ?? 'Erro ao cadastrar.');
      } else {
        _showSnackBar('Erro inesperado: $e');
      }
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
    TextInputFormatter? formatter,
    String? errorKey,
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
          decoration: AppInputDecoration.field(hintText: hint).copyWith(
            errorText: errorKey != null ? _fieldErrors[errorKey] : null,
          ),
          inputFormatters: formatter != null ? [formatter] : [],
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

              _buildField(
                'Nome Completo',
                _nomeController,
                'Seu nome',
                errorKey: 'name',
              ),
              _buildField(
                'E-mail',
                _emailController,
                'ex: seuemail@email.com',
                type: TextInputType.emailAddress,
                errorKey: 'email',
              ),
              _buildField(
                'CPF',
                _cpfController,
                '123.456.789-00',
                type: TextInputType.number,
                formatter: CpfInputFormatter(),
                errorKey: 'cpf',
              ),
              _buildField(
                'Telefone celular',
                _telefoneController,
                '(19) 99999-9999',
                type: TextInputType.phone,
                formatter: PhoneInputFormatter(),
                errorKey: 'phone',
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
                ).copyWith(errorText: _fieldErrors['password']),
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
