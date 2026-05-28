import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/models/user/investment_model.dart';

class InvestmentsTab extends StatefulWidget {
  final List<InvestmentModel> investments;
  final bool isLoading;

  const InvestmentsTab({
    super.key,
    required this.investments,
    required this.isLoading,
  });

  @override
  State<InvestmentsTab> createState() => _InvestmentsTabState();
}

class _InvestmentsTabState extends State<InvestmentsTab> {
  StartupStageFilter _selectedStage = StartupStageFilter.all;

  List<InvestmentModel> get _filtered {
    if (_selectedStage == StartupStageFilter.all) return widget.investments;
    return widget.investments.where((inv) {
      return inv.startup.stage?.name == _selectedStage.name;
    }).toList();
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
                  child: Text(
                    'Nenhum investimento encontrado.',
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _InvestmentCard(investment: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StartupStageFilter.values.map((stage) {
          final isSelected = _selectedStage == stage;
          return GestureDetector(
            onTap: () {
              if (_selectedStage != stage) {
                setState(() => _selectedStage = stage);
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
                stage.label,
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
