import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/app/theme/app_typography.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/extensions/duration_extensions.dart';

class ExportProgressView extends StatelessWidget {
  const ExportProgressView({
    super.key,
    required this.progress,
    required this.trimStart,
    required this.trimEnd,
    required this.caption,
    required this.onCancel,
  });

  final double progress;
  final Duration trimStart;
  final Duration trimEnd;
  final String caption;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0, 100);
    final stages = [
      (
        'Trim',
        '${trimStart.toClockString()} → ${trimEnd.toClockString()}',
      ),
      (
        'Reframe to ${AppConstants.outputAspectLabel}',
        '${AppConstants.outputWidth}×${AppConstants.outputHeight}',
      ),
      ('Burn in caption', caption.trim().isNotEmpty ? '“${caption.trim()}”' : 'none'),
      ('Encode', 'MPEG-4 · AAC'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Exporting clip', style: AppTypography.title),
        const SizedBox(height: AppSpacing.lg),
        AspectRatio(
          aspectRatio: AppConstants.outputAspectRatio,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.black),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: progress.clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          border: const Border(
                            top: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${pct.round()}%',
                      style: AppTypography.headline.copyWith(
                        fontFamily: AppTypography.mono,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...stages.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, detail) = entry.value;
          final done = pct >= (i + 1) * 25;
          final active = !done && pct >= i * 25;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Opacity(
              opacity: done || active ? 1 : 0.45,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: done
                          ? null
                          : Border.all(
                              color: active ? AppColors.primary : AppColors.textSecondary,
                              width: active ? 2 : 1.5,
                            ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(label, style: AppTypography.body)),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      detail,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mono11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(140, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
