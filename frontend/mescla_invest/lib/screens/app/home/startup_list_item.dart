// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';

class StartupListItem extends StatelessWidget {
  final String nome;
  final String inicial;
  final double tokenPrice;
  final int tokens;
  // Valorização percentual desde o lançamento; null = dado indisponível
  final double? appreciationPercent;

  const StartupListItem({
    super.key,
    required this.nome,
    required this.inicial,
    required this.tokens,
    required this.tokenPrice,
    this.appreciationPercent,
  });

  static const Color _verde = Color(0xFF7FDD3A);

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
              color: _verde,
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.token, size: 12, color: AppColors.verdeMescla),
                    const SizedBox(width: 4),
                    Text(
                      '$tokens tokens',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Valor total + badge de valorização
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(tokenPrice * tokens),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              _AppreciationBadge(percent: appreciationPercent),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge compacto que exibe a variação percentual com cor e ícone.
class _AppreciationBadge extends StatelessWidget {
  final double? percent;

  const _AppreciationBadge({this.percent});

  @override
  Widget build(BuildContext context) {
    // Dado ainda não disponível
    if (percent == null) {
      return const Text(
        '–',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      );
    }

    final isPositive = percent! >= 0;
    final color = isPositive ? const Color(0xFF7FDD3A) : Colors.redAccent;
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          Text(
            '$sign${percent!.toStringAsFixed(2)}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
