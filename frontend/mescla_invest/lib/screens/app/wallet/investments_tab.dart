import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/investment_model.dart';

class InvestmentsTab extends StatelessWidget {
  final List<InvestmentModel> investments;
  final bool isLoading;

  const InvestmentsTab({
    super.key,
    required this.investments,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdeMescla),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: investments.length,
      itemBuilder: (_, i) => _InvestmentCard(investment: investments[i]),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final InvestmentModel investment;

  const _InvestmentCard({required this.investment});

  @override
  Widget build(BuildContext context) {
    final availablePct = investment.totalTokens > 0
        ? investment.tokenAmount / investment.totalTokens
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildProgressBar(availablePct),
          const SizedBox(height: 10),
          _buildTokenChips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            investment.startup.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.verdeMescla.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${investment.totalTokens} tokens',
            style: const TextStyle(
              color: AppColors.verdeMescla,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.25),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.verdeMescla),
        minHeight: 6,
      ),
    );
  }

  Widget _buildTokenChips() {
    return Row(
      children: [
        _TokenChip(
          label: 'Disponível',
          value: investment.tokenAmount,
          color: AppColors.verdeMescla,
        ),
        if (investment.lockedTokenAmount > 0) ...[
          const SizedBox(width: 16),
          _TokenChip(
            label: 'Bloqueado',
            value: investment.lockedTokenAmount,
            color: Colors.white38,
          ),
        ],
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TokenChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$value $label', style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
