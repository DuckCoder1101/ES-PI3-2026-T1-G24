/*
 * Autor: Vinicius Santuci Virgolino
 * RA: 25000294
 */

import 'package:flutter/material.dart';

class HintText extends StatelessWidget {
  final String text;
  const HintText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
