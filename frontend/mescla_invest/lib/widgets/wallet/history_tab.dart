/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/user/transaction_model.dart';
import 'package:mescla_invest/screens/app_root.dart';

class HistoryTab extends StatefulWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;

  const HistoryTab({
    super.key,
    required this.transactions,
    required this.isLoading,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  TransactionTypeFilter _selectedType = TransactionTypeFilter.all;

  List<TransactionModel> get _filtered {
    if (_selectedType == TransactionTypeFilter.all) return widget.transactions;
    return widget.transactions
        .where((tx) => tx.type.name == _selectedType.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdeMescla),
      );
    }

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildFilterTags(),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.white24,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma transação encontrada.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _TransactionCard(tx: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransactionTypeFilter.values.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () {
              if (_selectedType != type) {
                setState(() => _selectedType = type);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla
                    : AppColors.campoEscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final uid = authUserDataProvider.value?.uid ?? '';

    final IconData icon;
    final Color iconColor;
    final String title;
    final String subtitle;
    final bool isPositive;

    switch (tx.type) {
      case TransactionType.funds:
        icon = Icons.add_card_rounded;
        iconColor = Colors.greenAccent;
        title = 'Depósito';
        subtitle = 'Saldo adicionado à conta.';
        isPositive = true;

      case TransactionType.investment:
        final t = tx as InvestmentTransactionModel;

        icon = Icons.rocket_launch_rounded;
        iconColor = AppColors.verdeMescla;
        title = 'Compra — ${t.startup.name}';
        subtitle =
            '${t.tokensPurchased} tokens × ${formatCurrency(t.tokenPrice)}';
        isPositive = false;

      case TransactionType.trade:
        final t = tx as TradeTransactionModel;
        final isBuyer = t.purchaserUId == uid;

        icon = isBuyer ? Icons.shopping_cart : Icons.sell;
        iconColor = isBuyer ? AppColors.verdeMescla : Colors.orangeAccent;
        title = isBuyer
            ? 'Compra — ${t.startup.name}'
            : 'Venda — ${t.startup.name}';
        subtitle =
            '${t.tokensPurchased} tokens × ${formatCurrency(t.tokenPrice)}';
        isPositive = !isBuyer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TransactionIcon(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          _TransactionInfo(
            title: title,
            subtitle: subtitle,
            date: formatDate(tx.createdAt),
          ),
          const SizedBox(width: 8),
          _TransactionAmount(amount: tx.amount, isPositive: isPositive),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TransactionIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TransactionInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _TransactionInfo({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TransactionAmount extends StatelessWidget {
  final double amount;
  final bool isPositive;

  const _TransactionAmount({required this.amount, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${isPositive ? '+' : '-'} ${formatCurrency(amount)}',
      style: TextStyle(
        color: isPositive ? Colors.greenAccent : Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}
