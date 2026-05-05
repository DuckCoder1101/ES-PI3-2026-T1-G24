import 'package:flutter/material.dart';

class LogoMesclaInvest extends StatelessWidget {
  const LogoMesclaInvest({super.key, double fontSize = 24})
    : _fontSize = fontSize;

  static const Color verdeMescla = Color(0xFF7FDD3A);
  final double _fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
        children: const [
          TextSpan(
            text: 'Mescla',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Invest',
            style: TextStyle(color: verdeMescla),
          ),
        ],
      ),
    );
  }
}
