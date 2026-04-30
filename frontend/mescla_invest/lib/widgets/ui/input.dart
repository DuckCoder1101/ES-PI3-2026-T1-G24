// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppInputDecoration {
  static InputDecoration field({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textoHint),
      filled: true,
      fillColor: AppColors.campoEscuro,
      suffixIcon: suffixIcon,
      border: _outlineBorder(AppColors.bordaPadrao),
      enabledBorder: _outlineBorder(AppColors.bordaPadrao),
      focusedBorder: _outlineBorder(AppColors.verdeMescla),
    );
  }

  static OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class InputLabel extends StatelessWidget {
  final String texto;
  final bool obrigatorio;

  const InputLabel({super.key, required this.texto, this.obrigatorio = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: texto),
          if (obrigatorio)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
