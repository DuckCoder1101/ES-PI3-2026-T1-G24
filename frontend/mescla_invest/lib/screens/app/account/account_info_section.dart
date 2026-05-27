/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/uppercase_format.dart';
import 'package:mescla_invest/models/user/user_model.dart';
import 'package:mescla_invest/screens/app_root.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/layout/account_section.dart';

class AccountInfoSection extends StatefulWidget {
  const AccountInfoSection({super.key});

  @override
  State<AccountInfoSection> createState() => _AccountInfoSectionState();
}

class _AccountInfoSectionState extends State<AccountInfoSection> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSavingData = false;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    final user = authUserDataProvider.value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
    _nameController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onDataChanged);
    _phoneController.removeListener(_onDataChanged);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    final user = authUserDataProvider.value;
    final changed =
        user != null &&
        (_nameController.text != user.name ||
            _phoneController.text != user.phone);
    if (changed != _dataChanged) setState(() => _dataChanged = changed);
  }

  Future<void> _savePersonalData() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      showSnackbar(
        msg: 'Preencha todos os campos!',
        context: context,
        isError: true,
      );
      return;
    }

    setState(() => _isSavingData = true);

    try {
      await UserService.updateProfile(name: name, phone: phone);
      final updated = await UserService.getFullUserData();
      authUserDataProvider.value = updated;

      if (mounted) {
        setState(() => _dataChanged = false);
        showSnackbar(msg: 'Dados salvos com sucesso!', context: context);
      }
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isSavingData = false);
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.verdeMescla, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: authUserDataProvider,
      builder: (_, user, _) {
        return AccountCard(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                inputFormatters: [UpperCaseTextFormatter()],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nome completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Telefone'),
              ),
              const SizedBox(height: 12),
              AccountReadOnlyField(label: 'CPF', value: user?.cpf ?? ''),
              const SizedBox(height: 12),
              AccountReadOnlyField(label: 'E-mail', value: user?.email ?? ''),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _dataChanged ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.verdeMescla,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _dataChanged && !_isSavingData
                        ? _savePersonalData
                        : null,
                    child: _isSavingData
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.verdeMescla,
                            ),
                          )
                        : const Text(
                            'Salvar alterações',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const AccountReadOnlyField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
