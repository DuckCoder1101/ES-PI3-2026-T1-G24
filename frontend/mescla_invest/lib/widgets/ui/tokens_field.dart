/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/number_limit_formatter.dart';

class TokenAmountField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const TokenAmountField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  void _decrement() {
    final current = int.tryParse(controller.text) ?? 1;
    if (current > 1) {
      controller.text = '${current - 1}';
      onChanged();
    }
  }

  void _increment() {
    final current = int.tryParse(controller.text) ?? 0;
    controller.text = '${current + 1}';
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantidade de tokens',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _decrement,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.campoEscuro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.campoEscuro,
                  border: Border.all(color: AppColors.verdeMescla),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    NumberLimitFormatter(maxValue: 999),
                  ],
                  onChanged: (_) => onChanged(),
                ),
              ),
            ),
            GestureDetector(
              onTap: _increment,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.verdeMescla,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
