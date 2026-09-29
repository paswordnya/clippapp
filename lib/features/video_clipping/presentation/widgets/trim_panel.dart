import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/app/theme/app_typography.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/extensions/duration_extensions.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/trim_range_strip.dart';

class TrimPanel extends StatelessWidget {
  const TrimPanel({
    super.key,
    required this.videoDuration,
    required this.start,
    required this.end,
    required this.playhead,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onChanged,
    this.onScrubStart,
    this.onScrub,
    this.onScrubEnd,
    this.errorMessage,
  });

  final Duration videoDuration;
  final Duration start;
  final Duration end;
  final Duration playhead;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final ValueChanged<(Duration, Duration)> onChanged;
  final VoidCallback? onScrubStart;
  final ValueChanged<Duration>? onScrub;
  final VoidCallback? onScrubEnd;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final clipLen = end - start;
    final overLimit = clipLen > AppConstants.maxClipDuration;
    final fill = (clipLen.inMilliseconds / AppConstants.maxClipDuration.inMilliseconds)
        .clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PlayButton(isPlaying: isPlaying, onTap: onTogglePlay),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${start.toClockString()} – ${end.toClockString()}',
                    style: AppTypography.bodyMuted,
                  ),
                  Text(clipLen.toSecondsString(), style: AppTypography.monoTimecode),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    overLimit
                        ? 'Max ${AppConstants.maxClipDuration.inSeconds}s reached'
                        : 'of ${AppConstants.maxClipDuration.inSeconds}s max',
                    style: AppTypography.mono11.copyWith(
                      color: overLimit ? AppColors.accentText : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        value: fill,
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TrimRangeStrip(
            videoDuration: videoDuration,
            start: start,
            end: end,
            playhead: playhead,
            onChanged: onChanged,
            onScrubStart: onScrubStart,
            onScrub: onScrub,
            onScrubEnd: onScrubEnd,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0:00', style: AppTypography.mono11),
              Text(videoDuration.toClockString(), style: AppTypography.mono11),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage!,
            style: AppTypography.bodyMuted.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
