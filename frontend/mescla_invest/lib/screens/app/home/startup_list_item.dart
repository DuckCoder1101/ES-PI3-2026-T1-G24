// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';

class StartupListItem extends StatelessWidget {
  final String nome;
  final String inicial;
  final int tokens;

  const StartupListItem({
    super.key,
    required this.nome,
    required this.inicial,
    required this.tokens,
  });

  static const Color verdeMescla = Color(0xFF7FDD3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: verdeMescla,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Nome e tokens
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$tokens tokens',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Quantidade
          Text(
            '$tokens',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}