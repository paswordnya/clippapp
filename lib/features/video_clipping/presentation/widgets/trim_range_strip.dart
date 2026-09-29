import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/core/constants/app_constants.dart';

enum _Drag { start, end, range }

class TrimRangeStrip extends StatefulWidget {
  const TrimRangeStrip({
    super.key,
    required this.videoDuration,
    required this.start,
    required this.end,
    required this.playhead,
    required this.onChanged,
    this.onScrubStart,
    this.onScrub,
    this.onScrubEnd,
  });

  final Duration videoDuration;
  final Duration start;
  final Duration end;
  final Duration playhead;
  final ValueChanged<(Duration start, Duration end)> onChanged;

  /// Called when a drag begins, so the host can pause playback.
  final VoidCallback? onScrubStart;

  /// Called while dragging with the timestamp the user is looking at
  /// (the edge being moved), so the host can seek the preview to it.
  final ValueChanged<Duration>? onScrub;

  /// Called when the drag finishes.
  final VoidCallback? onScrubEnd;

  static const double _height = 56;
  static const double _handleWidth = 18;
  static const double _hitWidth = 32;

  @override
  State<TrimRangeStrip> createState() => _TrimRangeStripState();
}

class _TrimRangeStripState extends State<TrimRangeStrip> {
  static const _height = TrimRangeStrip._height;
  static const _handleWidth = TrimRangeStrip._handleWidth;
  static const _hitWidth = TrimRangeStrip._hitWidth;

  Duration get videoDuration => widget.videoDuration;
  Duration get start => widget.start;
  Duration get end => widget.end;
  Duration get playhead => widget.playhead;

  _Drag? _active;
  late Duration _originStart;
  late Duration _originEnd;
  double _accumulated = 0;

  @override
  Widget build(BuildContext context) {
    final totalMs = videoDuration.inMilliseconds.toDouble();
    if (totalMs <= 0) return const SizedBox(height: _height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        final trackWidth = (boxWidth - _handleWidth * 2).clamp(0.0, double.infinity);

        double timeToX(Duration d) => _handleWidth + d.inMilliseconds / totalMs * trackWidth;

        void beginDrag(_Drag kind) {
          _active = kind;
          _originStart = start;
          _originEnd = end;
          _accumulated = 0;
          widget.onScrubStart?.call();
        }

        // Always computed from the drag origin + total finger travel, so
        // clamping at an edge never causes drift or lost pixels.
        void updateDrag(_Drag kind, double dxPixels) {
          if (_active != kind || trackWidth <= 0) return;
          _accumulated += dxPixels;
          final dt = Duration(
            microseconds: (_accumulated / trackWidth * totalMs * 1000).round(),
          );
          var s = _originStart;
          var e = _originEnd;
          Duration scrubTo;
          switch (kind) {
            case _Drag.start:
              s = _clampDuration(s + dt, Duration.zero, e - AppConstants.minClipDuration);
              if (e - s > AppConstants.maxClipDuration) {
                s = e - AppConstants.maxClipDuration;
              }
              scrubTo = s;
            case _Drag.end:
              e = _clampDuration(e + dt, s + AppConstants.minClipDuration, videoDuration);
              if (e - s > AppConstants.maxClipDuration) {
                e = s + AppConstants.maxClipDuration;
              }
              scrubTo = e;
            case _Drag.range:
              final len = e - s;
              s = _clampDuration(s + dt, Duration.zero, videoDuration - len);
              e = s + len;
              scrubTo = s;
          }
          if (s != start || e != end) widget.onChanged((s, e));
          widget.onScrub?.call(scrubTo);
        }

        void endDrag() {
          if (_active == null) return;
          _active = null;
          widget.onScrubEnd?.call();
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
                  onHorizontalDragStart: (_) => beginDrag(_Drag.range),
                  onHorizontalDragUpdate: (d) => updateDrag(_Drag.range, d.delta.dx),
                  onHorizontalDragEnd: (_) => endDrag(),
                  onHorizontalDragCancel: endDrag,
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
                left: selLeftX - _hitWidth,
                width: _hitWidth,
                top: -3,
                bottom: -3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (_) => beginDrag(_Drag.start),
                  onHorizontalDragUpdate: (d) => updateDrag(_Drag.start, d.delta.dx),
                  onHorizontalDragEnd: (_) => endDrag(),
                  onHorizontalDragCancel: endDrag,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(width: _handleWidth, child: _Handle(alignRight: true)),
                  ),
                ),
              ),
              Positioned(
                left: selRightX,
                width: _hitWidth,
                top: -3,
                bottom: -3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (_) => beginDrag(_Drag.end),
                  onHorizontalDragUpdate: (d) => updateDrag(_Drag.end, d.delta.dx),
                  onHorizontalDragEnd: (_) => endDrag(),
                  onHorizontalDragCancel: endDrag,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: _handleWidth, child: _Handle(alignRight: false)),
                  ),
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
