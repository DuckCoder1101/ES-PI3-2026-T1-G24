// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/widgets/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/ui/input.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:mescla_invest/formatters/cpf_input_format.dart';
import 'package:mescla_invest/formatters/phone_input_format.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _senhaVisivel = false;
  bool _isLoading = false;

  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasMinMaxLength =>
      _passwordController.text.length >= 8 &&
      _passwordController.text.length <= 16;

  String? _errorMessage;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarUsuario() async {
    if ([
      _nameController,
      _emailController,
      _cpfController,
      _phoneController,
      _passwordController,
    ].any((c) => c.text.isEmpty)) {
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
      _errorMessage = null;
      _fieldErrors = {};
    });

    try {
      await UserModel.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        if (e.code == "invalid-argument" && e.details is Map) {
          _errorMessage = "Um ou mais campos inválidos!";
          _fieldErrors = Map<String, String>.from(e.details);
        } else {
          _errorMessage =
              "Erro desconhecido no servidor! Tente novamente mais tarde!";
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
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "email-already-in-use") {
          _errorMessage =
              "Este email já está sendo utilizado por outro usuário!";
        } else if (e.code == "weak-password") {
          _errorMessage =
              "A senha precisa ter entre 8 a 16 dígitos, incluindo uma letra maiúscula, uma letra minúscula e um número!";
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

      setState(() {
        _errorMessage = "Erro desconhecido. Tente novamente mais tarde!";
      });

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

  InputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 2),
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
            enabledBorder: _border(
              _fieldErrors[errorKey] != null ? Colors.red : Colors.transparent,
            ),
            focusedBorder: _border(
              _fieldErrors[errorKey] != null
                  ? Colors.red
                  : AppColors.verdeMescla,
            ),
          ),
          inputFormatters: formatter != null ? [formatter] : [],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _passwordRequirement(String text, {required bool met}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: met ? Colors.green : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.white70 : Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
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
                _nameController,
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
                _phoneController,
                '(19) 99999-9999',
                type: TextInputType.phone,
                formatter: PhoneInputFormatter(),
                errorKey: 'phone',
              ),

              const InputLabel(texto: 'Crie sua Senha', obrigatorio: true),
              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: !_senhaVisivel,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) {
                  setState(() {
                    _fieldErrors.remove('password');
                  });
                },
                decoration: AppInputDecoration.field(
                  hintText: '• • • • • • •',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textoHint,
                    ),
                    onPressed: () {
                      setState(() => _senhaVisivel = !_senhaVisivel);
                    },
                  ),
                ).copyWith(errorText: _fieldErrors['password']),
              ),

              const SizedBox(height: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _passwordRequirement(
                    'Entre 8 e 16 caracteres',
                    met: _hasMinMaxLength,
                  ),
                  _passwordRequirement(
                    'Uma letra maiúscula',
                    met: _hasUppercase,
                  ),
                  _passwordRequirement(
                    'Uma letra minúscula',
                    met: _hasLowercase,
                  ),
                  _passwordRequirement('Um número', met: _hasNumber),
                ],
              ),

              const SizedBox(height: 34),

              PrimaryButton(
                text: 'Cadastrar',
                onPressed: _cadastrarUsuario,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
