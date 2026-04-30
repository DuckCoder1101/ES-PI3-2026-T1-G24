/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup.dart';

class TabSocios extends StatelessWidget {
  final StartupModel startup;
  final String startupId; // Parâmetro solicitado

  const TabSocios({super.key, required this.startup, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "FUNDADORES",
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...startup.founders.map(
          (f) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.campoEscuro,
              child: Icon(Icons.person, color: AppColors.verdeMescla),
            ),
            title: Text(f.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              "${f.role} • ${f.equityPercent}%",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
