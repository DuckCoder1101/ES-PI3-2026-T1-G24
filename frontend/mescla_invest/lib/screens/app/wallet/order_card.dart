/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/services/order_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';

class OrderCard extends StatefulWidget {
  final OrderTypeFilter tab;
  final OrderModel order;
  final Future<void> Function() onUpdate;

  const OrderCard({
    super.key,
    required this.tab,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExecuting = false;

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.campoEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: AppColors.verdeMescla),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Executa a compra de tokens de uma ordem de venda existente
  Future<void> _executeBuy() async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar compra',
      message:
          'Comprar ${widget.order.tokenAmount} tokens de ${widget.order.startup.name} por R\$ ${formatCurrency(widget.order.totalValue)}?',
    );

    if (!confirm || !mounted) return;
    setState(() => isExecuting = true);

    try {
      await OrderService.buyOrder(widget.order.id);

      if (mounted) {
        showSnackbar(msg: 'Compra realizada com sucesso!', context: context);
      }

      await widget.onUpdate();
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) setState(() => isExecuting = false);
    }
  }

  // Executa a venda de tokens para uma ordem de compra existente
  Future<void> _executeSell() async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar venda',
      message:
          'Vender ${widget.order.tokenAmount} tokens de ${widget.order.startup.name} por ${formatCurrency(widget.order.totalValue)}?',
    );
    if (!confirm || !mounted) return;

    setState(() => isExecuting = true);
    try {
      await OrderService.sellOrder(widget.order.id);

      if (mounted) {
        showSnackbar(msg: 'Venda efetuada com sucesso!', context: context);
      }

      await widget.onUpdate();
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) setState(() => isExecuting = false);
    }
  }

  // Cancela uma ordem própria e devolve os fundos/tokens bloqueados
  Future<void> _cancelOrder() async {
    final confirm = await _showConfirmDialog(
      title: 'Cancelar ordem',
      message:
          'Deseja cancelar esta ordem? Os fundos/tokens bloqueados serão devolvidos.',
    );
    if (!confirm || !mounted) return;

    setState(() => isExecuting = true);
    try {
      await OrderService.deleteOrder(widget.order.id);

      if (mounted) {
        showSnackbar(msg: 'Ordem cancelada.', context: context);
      }

      await widget.onUpdate();
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) setState(() => isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuyTab = widget.tab == OrderTypeFilter.buy;
    final isMyOrders = widget.tab == OrderTypeFilter.myOrders;

    // Rótulo do botão de ação
    final actionLabel = switch (widget.tab) {
      OrderTypeFilter.buy => "Comprar",
      OrderTypeFilter.sell => "Vender",
      OrderTypeFilter.myOrders => "Cancelar",
    };

    // Cor do botão
    final actionColor = isMyOrders ? Colors.redAccent : AppColors.verdeMescla;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
        border: widget.order.isAuthor
            ? Border.all(color: AppColors.verdeMescla.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qtd: ${widget.order.tokenAmount} tokens',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (isMyOrders)
                  Text(
                    widget.order.type == OrderType.buy
                        ? 'Ordem de compra'
                        : 'Ordem de venda',
                    style: TextStyle(
                      color: widget.order.type == OrderType.buy
                          ? Colors.greenAccent.withValues(alpha: 0.8)
                          : Colors.orangeAccent.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${widget.order.pricePerToken.toStringAsFixed(2).replaceAll('.', ',')}',
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
              // Não mostra o botão de ação para as próprias ordens nas abas Compra/Venda
              if (isMyOrders || !widget.order.isAuthor)
                GestureDetector(
                  onTap: isExecuting
                      ? null
                      : () {
                          if (isMyOrders) {
                            _cancelOrder();
                          } else if (isBuyTab) {
                            _executeSell();
                          } else {
                            _executeBuy();
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isExecuting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                )
              else
                // Badge "Sua ordem" para ordens próprias nas abas Compra/Venda
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeMescla.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.verdeMescla.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Sua ordem',
                    style: TextStyle(
                      color: AppColors.verdeMescla,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
