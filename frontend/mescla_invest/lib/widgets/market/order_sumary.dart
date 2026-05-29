/*
 * Autor: Vinicius Santuci Virgolino
 * RA: 25000294
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final int tokenAmount;
  final int pricePerTokenCents;
  final OrderType orderType;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.tokenAmount,
    required this.pricePerTokenCents,
    required this.orderType,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoEscuro,
        border: Border.all(color: AppColors.verdeMescla.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _row('Tokens', tokenAmount > 0 ? '$tokenAmount' : '—'),
          const SizedBox(height: 8),
          _row(
            'Preço/token',
            pricePerTokenCents > 0
                ? formatCurrency(pricePerTokenCents / 100)
                : '—',
          ),
          const SizedBox(height: 8),
          _row('Tipo', orderType.label),
          const Divider(color: Colors.white12, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total > 0 ? formatCurrency(total) : '—',
                style: const TextStyle(
                  color: AppColors.verdeMescla,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
