import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/app/theme/app_typography.dart';
import 'package:semarewards/core/constants/app_constants.dart';

class FramePanel extends StatelessWidget {
  const FramePanel({super.key, required this.onCenter});

  final VoidCallback onCenter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Drag the crop box to reframe', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Output is ${AppConstants.outputWidth}×${AppConstants.outputHeight}.',
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        OutlinedButton(
          onPressed: onCenter,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: AppColors.surfaceVariant,
          ),
          child: const Text('Center', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
