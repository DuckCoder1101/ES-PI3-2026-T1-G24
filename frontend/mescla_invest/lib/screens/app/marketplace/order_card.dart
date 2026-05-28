/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/screens/app/marketplace/order_card_info.dart';
import 'package:mescla_invest/services/order_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';

class OrderCard extends StatefulWidget {
  final OrderTypeFilter tab;
  final OrderModel order;
  final Future<void> Function() onUpdate;
  final VoidCallback? onRemove;

  const OrderCard({
    super.key,
    required this.tab,
    required this.order,
    required this.onUpdate,
    this.onRemove,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExecuting = false;

  bool get _isMyOrders => widget.tab == OrderTypeFilter.myOrders;
  bool get _isBuyTab => widget.tab == OrderTypeFilter.buy;

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    Color confirmColor = AppColors.verdeMescla,
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
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _executeBuy() async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar compra',
      message:
          'Comprar ${widget.order.tokenAmount} tokens de ${widget.order.startup.name} por ${formatCurrency(widget.order.totalValue)}?',
    );
    if (!confirm || !mounted) return;

    setState(() => _isExecuting = true);
    try {
      await OrderService.buyOrder(widget.order.id);

      if (mounted) {
        showSnackbar(msg: 'Compra realizada com sucesso!', context: context);
      }
      await widget.onUpdate();
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  Future<void> _executeSell() async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar venda',
      message:
          'Vender ${widget.order.tokenAmount} tokens de ${widget.order.startup.name} por ${formatCurrency(widget.order.totalValue)}?',
    );
    if (!confirm || !mounted) return;

    setState(() => _isExecuting = true);
    try {
      await OrderService.sellOrder(widget.order.id);
      if (mounted) {
        showSnackbar(msg: 'Venda efetuada com sucesso!', context: context);
      }
      await widget.onUpdate();
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  Future<void> _cancelOrder() async {
    setState(() => _isExecuting = true);
    try {
      await OrderService.deleteOrder(widget.order.id);
      if (mounted) showSnackbar(msg: 'Ordem cancelada.', context: context);
      await widget.onUpdate();
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
      await widget.onUpdate();
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
            child: OrderCardInfo(order: widget.order, showType: _isMyOrders),
          ),
          OrderCardTrailing(
            order: widget.order,
            isExecuting: _isExecuting,
            showSwipeHint: _isMyOrders,
            onBuy: _executeBuy,
            onSell: _executeSell,
            isBuyTab: _isBuyTab,
          ),
        ],
      ),
    );

    if (!_isMyOrders) return card;

    return Dismissible(
      key: Key(widget.order.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showConfirmDialog(
        title: 'Cancelar ordem',
        message:
            'Deseja cancelar esta ordem? Os fundos/tokens bloqueados serão devolvidos.',
        confirmLabel: 'Cancelar ordem',
        confirmColor: Colors.redAccent,
      ),
      onDismissed: (_) {
        widget.onRemove?.call();
        _cancelOrder();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: card,
    );
  }
}
