/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/screens/app/marketplace/order_card_action_button.dart';

class OrderCardInfo extends StatelessWidget {
  final OrderModel order;
  final bool showType;

  const OrderCardInfo({super.key, required this.order, required this.showType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.startup.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Qtd: ${order.tokenAmount} tokens',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        if (showType)
          Text(
            order.type == OrderType.buy ? 'Ordem de compra' : 'Ordem de venda',
            style: TextStyle(
              color: order.type == OrderType.buy
                  ? Colors.greenAccent.withValues(alpha: 0.8)
                  : Colors.orangeAccent.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class OrderCardTrailing extends StatelessWidget {
  final OrderModel order;
  final bool isExecuting;
  final bool showSwipeHint;
  final bool isBuyTab;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const OrderCardTrailing({
    super.key,
    required this.order,
    required this.isExecuting,
    required this.showSwipeHint,
    required this.isBuyTab,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(order.pricePerToken),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              '/token',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 12),
        if (!order.isAuthor)
          ActionButton(
            label: order.type == OrderType.buy ? 'Vender' : 'Comprar',
            color: AppColors.verdeMescla,
            isExecuting: isExecuting,
            onTap: isBuyTab ? onSell : onBuy,
          )
        else
          AuthorBadge(showSwipeHint: showSwipeHint),
      ],
    );
  }
}
