// Autor: Cristian Fava
// RA: 25000636

import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const AppHeader({super.key, required this.userName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Olá, ${userName.split(' ')[0]}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.campoEscuro,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white24)
                : null,
          ),
        ],
      ),
    );
  }
}
