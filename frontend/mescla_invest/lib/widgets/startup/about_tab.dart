/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/widgets/startup/video_player.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/shared/ui/primary_button.dart';

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
          '$selectedDirectory/sumario_executivo_${widget.startup.name}.pdf';

      await StartupService.downloadPitch(widget.startup.id, localPath);

      if (mounted) {
        showSnackbar(msg: "Download concluído com sucesso!", context: context);
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
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

        _buildExecutiveSummarySection(),

        const SizedBox(height: 20),
        PrimaryButton(
          text: "Baixar pitch",
          onPressed: _isDownloading ? null : downloadExecutiveSummary,
          isLoading: _isDownloading,
        ),

        if (widget.startup.videoUrl != null) _buildVideoSection(),
      ],
    );
  }

  Widget _buildExecutiveSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'SUMÁRIO EXECUTIVO',
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.verdeMescla.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.startup.executiveSummary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
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
