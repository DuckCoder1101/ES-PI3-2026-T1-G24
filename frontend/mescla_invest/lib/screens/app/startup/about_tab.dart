/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup.dart';
import 'package:mescla_invest/screens/app/startup/video_player.dart';

class TabAbout extends StatelessWidget {
  final StartupModel startup;
  final String startupId;

  const TabAbout({super.key, required this.startup, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DESCRIÇÃO",
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          startup.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        if (startup.executiveSummary.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            "SUMÁRIO EXECUTIVO",
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            startup.executiveSummary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
        if (startup.videoUrl != null) _buildVideoSection(),
      ],
    );
  }

  Widget _buildVideoSection() {
    final videoUrl = startup.videoUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        const Text(
          'VÍDEO',
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: StartupVideoPlayer(videoUrl: videoUrl),
          ),
        ),
      ],
    );
  }
}
