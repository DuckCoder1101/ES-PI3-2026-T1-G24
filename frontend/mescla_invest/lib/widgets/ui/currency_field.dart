/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/number_limit_formatter.dart';

class CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? label;
  final double fontSize;
  final bool autofocus;
  final String? errorText;
  final int? maxValue;
  final Color prefixColor;
  final bool bordered;

  const CurrencyField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = 'Preço por token (R\$)',
    this.fontSize = 16,
    this.autofocus = false,
    this.errorText,
    this.maxValue,
    this.prefixColor = Colors.white54,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: autofocus,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        prefixText: 'R\$ ',
        prefixStyle: TextStyle(
          color: prefixColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        hintText: '0,00',
        hintStyle: TextStyle(color: Colors.white24, fontSize: fontSize),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        border: InputBorder.none,
        enabledBorder: bordered
            ? InputBorder.none
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white12),
              ),
        focusedBorder: bordered
            ? InputBorder.none
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.verdeMescla, width: 2),
              ),
        contentPadding: bordered
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : null,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
        maxValue != null
            ? NumberLimitFormatter(maxValue: maxValue!)
            : NumberLimitFormatter(),
      ],
      onChanged: (_) => onChanged(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
        ],
        if (bordered)
          Container(
            decoration: BoxDecoration(
              color: AppColors.campoEscuro,
              border: Border.all(color: AppColors.verdeMescla),
              borderRadius: BorderRadius.circular(8),
            ),
            child: textField,
          )
        else
          textField,
      ],
    );
  }
}
