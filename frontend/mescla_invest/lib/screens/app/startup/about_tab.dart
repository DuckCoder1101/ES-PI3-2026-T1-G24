/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/screens/app/startup/video_player.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';

class TabAbout extends StatefulWidget {
  final StartupModel startup;

  const TabAbout({super.key, required this.startup});

  @override
  State<StatefulWidget> createState() => _TabAboutState();
}

class _TabAboutState extends State<TabAbout> {
  bool _isDownloading = false;

  Future<void> downloadExecutiveSummary() async {
    try {
      String? selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory == null) return;

      setState(() => _isDownloading = true);

      final String localPath =
          '$selectedDirectory/${widget.startup.name}/sumario_executivo.pdf';

      await StartupService.downloadExecutiveSummary(
        widget.startup.executiveSummaryPath!,
        localPath,
      );

      if (mounted) {
        showSnackbar(msg: "Download concluído com sucesso!", context: context);
      }
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

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
          widget.startup.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),

        if (widget.startup.executiveSummaryPath != null) ...[
          const SizedBox(height: 20),
          PrimaryButton(
            text: "Baixar sumário executivo: ",
            onPressed: _isDownloading ? null : downloadExecutiveSummary,
          ),
        ],

        if (widget.startup.videoUrl != null) _buildVideoSection(),
      ],
    );
  }

  Widget _buildVideoSection() {
    final videoUrl = widget.startup.videoUrl;

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
