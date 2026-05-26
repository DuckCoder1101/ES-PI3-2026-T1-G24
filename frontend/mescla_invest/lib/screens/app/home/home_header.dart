// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';
import 'package:mescla_invest/screens/app_root.dart';
import 'package:mescla_invest/screens/app/wallet/wallet_screen.dart';

class HomeHeader extends StatelessWidget {
  final WalletModel? wallet;
  final bool isLoadingWallet;
  final VoidCallback onWalletUpdated;

  const HomeHeader({
    super.key,
    required this.wallet,
    required this.isLoadingWallet,
    required this.onWalletUpdated,
  });

  void _showAddFundsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddFundsSheet(onSuccess: onWalletUpdated),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authUserDataProvider.value;
    final nome = user?.name.split(' ').first ?? 'usuário';
    final saldo = isLoadingWallet
        ? 'Carregando...'
        : 'R\$ ${(wallet?.funds ?? 0).toStringAsFixed(2).replaceAll('.', ',')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Olá, $nome',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.notifications_outlined, color: Colors.white),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  saldo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showAddFundsModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FDD3A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Adicionar fundos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}