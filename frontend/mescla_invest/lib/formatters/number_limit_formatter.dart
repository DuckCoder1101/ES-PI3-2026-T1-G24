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

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final intValue = int.tryParse(digitsOnly);

    if (intValue == null) return oldValue;

    if (intValue > maxValue) return oldValue;

    final corrected = intValue.toString();

    return newValue.copyWith(
      text: corrected,
      selection: TextSelection.collapsed(offset: corrected.length),
    );
  }
}
