// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/shared/ui/back_button.dart';
import 'package:mescla_invest/widgets/shared/ui/icon.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/widgets/shared/ui/input.dart';
import 'package:mescla_invest/widgets/shared/ui/primary_button.dart';
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

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _cpfFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _passwordVisible = false;
  bool _isLoading = false;

  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasMinMaxLength =>
      _passwordController.text.length >= 8 &&
      _passwordController.text.length <= 16;

  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _cpfFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _cadastrarUsuario() async {
    if ([
      _nameController,
      _emailController,
      _cpfController,
      _phoneController,
      _passwordController,
    ].any((c) => c.text.isEmpty)) {
      showSnackbar(msg: "Preencha todos os campos!", context: context);
      return;
    }

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      await UserService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 2),
  );

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint,
    FocusNode focusNode,
    FocusNode? nextFocus, {
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
          focusNode: focusNode,
          keyboardType: type,
          // Se há próximo campo, avança; senão finaliza o teclado
          textInputAction: nextFocus != null
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: (_) => nextFocus != null
              ? FocusScope.of(context).requestFocus(nextFocus)
              : _cadastrarUsuario(),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToWelcome();
      },
      child: Scaffold(
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
                  padding: EdgeInsets.only(top: 28),
                  child: LogoMesclaInvest(fontSize: 32),
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
                  _nameFocus,
                  _emailFocus,
                  errorKey: 'name',
                ),
                _buildField(
                  'E-mail',
                  _emailController,
                  'ex: seuemail@email.com',
                  _emailFocus,
                  _cpfFocus,
                  type: TextInputType.emailAddress,
                  errorKey: 'email',
                ),
                _buildField(
                  'CPF',
                  _cpfController,
                  '123.456.789-00',
                  _cpfFocus,
                  _phoneFocus,
                  type: TextInputType.number,
                  formatter: CpfInputFormatter(),
                  errorKey: 'cpf',
                ),
                _buildField(
                  'Telefone celular',
                  _phoneController,
                  '(19) 99999-9999',
                  _phoneFocus,
                  _passwordFocus,
                  type: TextInputType.phone,
                  formatter: PhoneInputFormatter(),
                  errorKey: 'phone',
                ),

                const InputLabel(texto: 'Crie sua Senha', obrigatorio: true),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _cadastrarUsuario(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) {
                    setState(() => _fieldErrors.remove('password'));
                  },
                  decoration: AppInputDecoration.field(
                    hintText: '• • • • • • •',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textoHint,
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
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
      ),
    );
  }
}
