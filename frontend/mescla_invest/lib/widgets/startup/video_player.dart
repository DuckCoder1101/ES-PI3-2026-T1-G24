/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:video_player/video_player.dart';

class StartupVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const StartupVideoPlayer({super.key, required this.videoUrl});

  @override
  State<StartupVideoPlayer> createState() => _StartupVideoPlayerState();
}

class _StartupVideoPlayerState extends State<StartupVideoPlayer> {
  late VideoPlayerController _controller;

  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          _isReady = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Container(
        color: AppColors.campoEscuro,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.verdeMescla),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_controller),

        GestureDetector(
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              size: 72,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
