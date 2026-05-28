/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/services.dart';

class NumberLimitFormatter extends TextInputFormatter {
  final int maxValue;

  NumberLimitFormatter({this.maxValue = 9999});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final normalized = newValue.text.replaceAll(',', '.');
    final doubleValue = double.tryParse(normalized);

    if (doubleValue == null) return oldValue;
    if (doubleValue > maxValue) return oldValue;

    return newValue;
  }
}
