import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semarewards/app/router/app_router.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/app/theme/app_typography.dart';
import 'package:semarewards/features/video_clipping/presentation/state/video_clipping_state.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/export_button.dart';

class VideoHomeScreen extends StatelessWidget {
  const VideoHomeScreen({super.key});

  Future<void> _pickVideo(BuildContext context) async {
    final viewModel = context.read<VideoClippingViewModel>();
    await viewModel.pickVideo();
    if (!context.mounted) return;

    final state = viewModel.state;
    if (state.status == VideoClippingStatus.editing) {
      Navigator.of(context).pushNamed(AppRouter.editor);
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
      viewModel.dismissError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPicking = context.select<VideoClippingViewModel, bool>(
      (vm) => vm.state.status == VideoClippingStatus.pickingVideo,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Brand(),
              const Expanded(child: Center(child: _AspectDiagram())),
              const Text(
                'Any landscape in.\nClean 9:16 clip out.',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _StepsGrid(),
              const SizedBox(height: AppSpacing.lg),
              ExportButton(
                label: 'Choose a video',
                isLoading: isPicking,
                onPressed: () => _pickVideo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        const Text(
          'Clipp App',
          style: TextStyle(
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AspectDiagram extends StatelessWidget {
  const _AspectDiagram();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 178,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            child: Container(
              width: 280,
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Text('any ratio', style: AppTypography.mono11),
          ),
          Positioned(
            top: 24,
            child: Container(
              width: 73,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Text(
              '9:16',
              style: AppTypography.mono11.copyWith(
                color: AppColors.accentText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsGrid extends StatelessWidget {
  const _StepsGrid();

  static const _steps = [
    ('01', 'Trim up to 60s'),
    ('02', 'Reframe to 9:16'),
    ('03', 'Add a caption'),
    ('04', 'Export & share'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 4.2,
      children: _steps.map((s) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.$1,
              style: AppTypography.mono11.copyWith(
                color: AppColors.accentText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(s.$2, style: AppTypography.bodyMuted)),
          ],
        );
      }).toList(),
    );
  }
}
