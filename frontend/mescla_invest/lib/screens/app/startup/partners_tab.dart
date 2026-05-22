/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';

class TabPartners extends StatelessWidget {
  final StartupModel startup;
  final String startupId;

  const TabPartners({
    super.key,
    required this.startup,
    required this.startupId,
  });

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
        if (startup.externalMembers.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "CONSELHO / MENTORES",
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...startup.externalMembers.map(
            (m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.campoEscuro,
                child: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.white38,
                ),
              ),
              title: Text(m.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                m.role,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
