import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCropPreview extends StatelessWidget {
  const VideoCropPreview({
    super.key,
    required this.controller,
    required this.cropOffset,
    this.onOffsetChanged,
  });

  final VideoPlayerController controller;
  final double cropOffset;
  final ValueChanged<double>? onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    final aspect = controller.value.aspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        final boxHeight = constraints.maxHeight;
        final targetAspect = boxWidth / boxHeight;
        final cropHorizontally = aspect >= targetAspect;

        final childWidth = cropHorizontally ? boxHeight * aspect : boxWidth;
        final childHeight = cropHorizontally ? boxHeight : boxWidth / aspect;
        final overflow =
            cropHorizontally ? childWidth - boxWidth : childHeight - boxHeight;
        final align = overflow > 0 ? cropOffset * 2 - 1 : 0.0;
        final alignment = cropHorizontally ? Alignment(align, 0) : Alignment(0, align);

        Widget content = ClipRect(
          child: OverflowBox(
            maxWidth: childWidth,
            minWidth: childWidth,
            maxHeight: childHeight,
            minHeight: childHeight,
            alignment: alignment,
            child: VideoPlayer(controller),
          ),
        );

        final onChanged = onOffsetChanged;
        if (onChanged != null && overflow > 0) {
          content = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: cropHorizontally
                ? (details) {
                    final next = (cropOffset - details.delta.dx / overflow).clamp(0.0, 1.0);
                    onChanged(next);
                  }
                : null,
            onVerticalDragUpdate: !cropHorizontally
                ? (details) {
                    final next = (cropOffset - details.delta.dy / overflow).clamp(0.0, 1.0);
                    onChanged(next);
                  }
                : null,
            child: content,
          );
        }

        return content;
      },
    );
  }
}
