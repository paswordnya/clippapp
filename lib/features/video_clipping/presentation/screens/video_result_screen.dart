import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/app/theme/app_typography.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/extensions/duration_extensions.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/export_button.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/video_preview.dart';

class VideoResultScreen extends StatelessWidget {
  const VideoResultScreen({super.key});

  Future<void> _save(BuildContext context) async {
    final viewModel = context.read<VideoClippingViewModel>();
    final error = await viewModel.save();
    if (!context.mounted) return;
    _showResult(context, error ?? (Platform.isIOS ? 'Saved to Photos' : 'Saved to Gallery'));
  }

  Future<void> _share(BuildContext context) async {
    final viewModel = context.read<VideoClippingViewModel>();
    final error = await viewModel.share();
    if (!context.mounted || error == null) return;
    _showResult(context, error);
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startOver(BuildContext context) {
    context.read<VideoClippingViewModel>().startOver();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VideoClippingViewModel>();
    final processed = viewModel.state.processedVideo;

    if (processed == null) {
      return const Scaffold(body: Center(child: Text('Nothing to show yet.')));
    }

    final meta =
        '${processed.duration.toSecondsString()} · ${processed.fileSizeMegabytes.toStringAsFixed(1)} MB';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              const Text('Clip ready', style: AppTypography.title),
              const SizedBox(height: 4),
              Text(meta, style: AppTypography.mono11),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: AppConstants.outputAspectRatio,
                    child: VideoPreview(path: processed.path, miniControls: true),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ExportButton(
                      label: Platform.isIOS ? 'Save to Photos' : 'Save to Gallery',
                      isLoading: viewModel.isSaving,
                      outlined: true,
                      onPressed: () => _save(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ExportButton(
                      label: 'Share…',
                      isLoading: viewModel.isSharing,
                      onPressed: () => _share(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _startOver(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Start a new clip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
