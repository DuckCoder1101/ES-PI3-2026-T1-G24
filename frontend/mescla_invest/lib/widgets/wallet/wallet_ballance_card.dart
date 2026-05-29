/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletModel? wallet;
  final bool isLoading;
  final bool balanceVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onAddFunds;

  const WalletBalanceCard({
    super.key,
    required this.wallet,
    required this.isLoading,
    required this.balanceVisible,
    required this.onToggleVisibility,
    required this.onAddFunds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.verdeMescla),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTotalBalance(),
                const SizedBox(height: 16),
                _buildBalanceChips(),
                const SizedBox(height: 16),
                _buildAddFundsButton(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MINHA CARTEIRA',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
        GestureDetector(
          onTap: onToggleVisibility,
          child: Icon(
            balanceVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white38,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalance() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        balanceVisible ? formatCurrency(wallet?.totalFunds ?? 0) : 'R\$ ••••••',
        key: ValueKey(balanceVisible),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildBalanceChips() {
    return Row(
      children: [
        Expanded(
          child: _BalanceChip(
            label: 'Disponível',
            value: balanceVisible ? formatCurrency(wallet?.funds ?? 0) : '••••',
            color: AppColors.verdeMescla,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceChip(
            label: 'Bloqueado',
            value: balanceVisible
                ? formatCurrency(wallet?.lockedFunds ?? 0)
                : '••••',
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildAddFundsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onAddFunds,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Adicionar fundos'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.verdeMescla,
          side: const BorderSide(color: AppColors.verdeMescla),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BalanceChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.fundoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
