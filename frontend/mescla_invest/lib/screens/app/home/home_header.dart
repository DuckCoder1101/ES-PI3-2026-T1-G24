// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/screens/app_root.dart';
import 'package:mescla_invest/screens/app/wallet/wallet_screen.dart';

class HomeHeader extends StatelessWidget {
  final String saldo;

  const HomeHeader({
    super.key,
    required this.saldo,
  });

  void _showAddFundsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddFundsSheet(onSuccess: () {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authUserDataProvider.value;
    final nome = user?.name.split(' ').first ?? 'usuário';

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
                'Negociar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}