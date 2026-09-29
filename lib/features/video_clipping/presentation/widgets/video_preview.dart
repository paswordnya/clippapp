import 'dart:io';

import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_radius.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({
    super.key,
    required this.path,
    this.borderRadius,
    this.miniControls = false,
  });

  final String path;
  final BorderRadius? borderRadius;

  final bool miniControls;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late final VideoPlayerController _controller;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _initialization = _controller.initialize().then((_) {
      _controller.setLooping(true);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? AppRadius.lgRadius,
      child: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ColoredBox(
              color: AppColors.surfaceVariant,
              child: SizedBox.expand(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: widget.miniControls ? null : _togglePlay,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColoredBox(
                  color: Colors.black,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                if (widget.miniControls)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _MiniControls(controller: _controller, onToggle: _togglePlay),
                  )
                else
                  AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniControls extends StatelessWidget {
  const _MiniControls({required this.controller, required this.onToggle});

  final VideoPlayerController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) => Icon(
                value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final total = value.duration.inMilliseconds;
                final fraction = total <= 0
                    ? 0.0
                    : (value.position.inMilliseconds / total).clamp(0.0, 1.0);
                return SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
