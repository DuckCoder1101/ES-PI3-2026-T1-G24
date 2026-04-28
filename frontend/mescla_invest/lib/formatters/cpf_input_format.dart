// Autor: Cristian Fava
// RA: 25000636

import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(oldValue, newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) text = text.substring(0, 11);

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
