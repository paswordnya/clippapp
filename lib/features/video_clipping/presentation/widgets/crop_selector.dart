import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:video_player/video_player.dart';

class CropSelector extends StatelessWidget {
  const CropSelector({
    super.key,
    required this.controller,
    required this.cropOffset,
    required this.onOffsetChanged,
  });

  final VideoPlayerController controller;
  final double cropOffset;
  final ValueChanged<double> onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final videoWidth = constraints.maxWidth;
            final videoHeight = constraints.maxHeight;
            final sourceAspect = videoWidth / videoHeight;
            final cropHorizontally = sourceAspect >= AppConstants.outputAspectRatio;

            final cropWidth = cropHorizontally
                ? videoHeight * AppConstants.outputAspectRatio
                : videoWidth;
            final cropHeight = cropHorizontally
                ? videoHeight
                : videoWidth / AppConstants.outputAspectRatio;
            final maxOffset = cropHorizontally
                ? (videoWidth - cropWidth).clamp(0.0, double.infinity)
                : (videoHeight - cropHeight).clamp(0.0, double.infinity);
            final cropLeft = cropHorizontally ? maxOffset * cropOffset : 0.0;
            final cropTop = cropHorizontally ? 0.0 : maxOffset * cropOffset;

            return Stack(
              children: [
                Positioned.fill(child: VideoPlayer(controller)),
                if (cropHorizontally) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: cropLeft,
                    child: const ColoredBox(color: Colors.black54),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: videoWidth - cropLeft - cropWidth,
                    child: const ColoredBox(color: Colors.black54),
                  ),
                ] else ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: cropTop,
                    child: const ColoredBox(color: Colors.black54),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: videoHeight - cropTop - cropHeight,
                    child: const ColoredBox(color: Colors.black54),
                  ),
                ],
                Positioned(
                  left: cropLeft,
                  top: cropTop,
                  width: cropWidth,
                  height: cropHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: cropHorizontally && maxOffset > 0
                        ? (details) {
                            final next =
                                (cropOffset + details.delta.dx / maxOffset).clamp(0.0, 1.0);
                            onOffsetChanged(next);
                          }
                        : null,
                    onVerticalDragUpdate: !cropHorizontally && maxOffset > 0
                        ? (details) {
                            final next =
                                (cropOffset + details.delta.dy / maxOffset).clamp(0.0, 1.0);
                            onOffsetChanged(next);
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                AppConstants.outputAspectLabel,
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const _CornerHandle(top: true, left: true),
                          const _CornerHandle(top: true, left: false),
                          const _CornerHandle(top: false, left: true),
                          const _CornerHandle(top: false, left: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CornerHandle extends StatelessWidget {
  const _CornerHandle({required this.top, required this.left});

  final bool top;
  final bool left;

  static const _size = 16.0;
  static const _overhang = -5.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? _overhang : null,
      bottom: top ? null : _overhang,
      left: left ? _overhang : null,
      right: left ? null : _overhang,
      width: _size,
      height: _size,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}
