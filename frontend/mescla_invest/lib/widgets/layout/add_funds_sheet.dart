import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

class AddFundsSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddFundsSheet({super.key, required this.onSuccess});

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0;

    if (value < 10) {
      setState(() => _error = 'O valor mínimo é R\$ 10,00.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await UserService.addFunds(value);
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 20),
          _buildInput(),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicionar fundos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Simulação — nenhum valor real será cobrado. Mínimo: R\$ 10,00.',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: true,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        prefixText: 'R\$ ',
        prefixStyle: const TextStyle(
          color: AppColors.verdeMescla,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        hintText: '0,00',
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 28),
        errorText: _error,
        errorStyle: const TextStyle(color: Colors.redAccent),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.verdeMescla, width: 2),
        ),
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
    );
  }

  Widget _buildConfirmButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.verdeMescla,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _isLoading ? null : _submit,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.verdeMescla,
              ),
            )
          : const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
    );
  }
}
