import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/core/constants/app_constants.dart';

class TrimRangeStrip extends StatelessWidget {
  const TrimRangeStrip({
    super.key,
    required this.videoDuration,
    required this.start,
    required this.end,
    required this.playhead,
    required this.onChanged,
  });

  final Duration videoDuration;
  final Duration start;
  final Duration end;
  final Duration playhead;
  final ValueChanged<(Duration start, Duration end)> onChanged;

  static const double _height = 56;
  static const double _handleWidth = 18;

  @override
  Widget build(BuildContext context) {
    final totalMs = videoDuration.inMilliseconds.toDouble();
    if (totalMs <= 0) return const SizedBox(height: _height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        final trackWidth = (boxWidth - _handleWidth * 2).clamp(0.0, double.infinity);

        double timeToX(Duration d) => _handleWidth + d.inMilliseconds / totalMs * trackWidth;

        Duration msToDuration(double dxPixels) =>
            Duration(milliseconds: (dxPixels / trackWidth * totalMs).round());

        void applyDelta(String kind, double dxPixels) {
          final dt = msToDuration(dxPixels);
          var s = start;
          var e = end;
          switch (kind) {
            case 'start':
              s = _clampDuration(s + dt, Duration.zero, e - const Duration(milliseconds: 1));
              if (e - s > AppConstants.maxClipDuration) {
                s = e - AppConstants.maxClipDuration;
              }
            case 'end':
              e = _clampDuration(
                e + dt,
                s + const Duration(milliseconds: 1),
                videoDuration,
              );
              if (e - s > AppConstants.maxClipDuration) {
                e = s + AppConstants.maxClipDuration;
              }
            default:
              final len = e - s;
              s = _clampDuration(s + dt, Duration.zero, videoDuration - len);
              e = s + len;
          }
          onChanged((s, e));
        }

        final selLeftX = timeToX(start);
        final selRightX = timeToX(end);
        final selWidth = selRightX - selLeftX;
        final phX = timeToX(playhead);

        return SizedBox(
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _handleWidth,
                right: _handleWidth,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned(
                left: _handleWidth,
                top: 0,
                bottom: 0,
                width: selLeftX - _handleWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: selRightX,
                top: 0,
                bottom: 0,
                width: boxWidth - _handleWidth - selRightX,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: selLeftX,
                width: selWidth,
                top: -3,
                bottom: -3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => applyDelta('range', d.delta.dx),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.primary, width: 3),
                        bottom: BorderSide(color: AppColors.primary, width: 3),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: selLeftX - _handleWidth,
                width: _handleWidth,
                top: -3,
                bottom: -3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => applyDelta('start', d.delta.dx),
                  child: const _Handle(alignRight: true),
                ),
              ),
              Positioned(
                left: selRightX,
                width: _handleWidth,
                top: -3,
                bottom: -3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => applyDelta('end', d.delta.dx),
                  child: const _Handle(alignRight: false),
                ),
              ),
              Positioned(
                left: phX - 1,
                top: -8,
                bottom: -8,
                width: 2,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.alignRight});

  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.horizontal(
          left: alignRight ? const Radius.circular(9) : Radius.zero,
          right: alignRight ? Radius.zero : const Radius.circular(9),
        ),
      ),
      child: Center(
        child: Container(width: 3, height: 20, color: Colors.white),
      ),
    );
  }
}
