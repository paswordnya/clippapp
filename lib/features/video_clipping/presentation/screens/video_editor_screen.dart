import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semarewards/app/router/app_router.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/features/video_clipping/presentation/state/video_clipping_state.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/caption_overlay.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/caption_panel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/crop_selector.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/export_progress_view.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/frame_panel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/glass_panel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/step_top_bar.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/trim_panel.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/video_crop_preview.dart';
import 'package:video_player/video_player.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final source = context.read<VideoClippingViewModel>().state.sourceVideo!;
    _controller = VideoPlayerController.file(File(source.path))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
    _controller.addListener(_loopWithinTrim);
  }

  @override
  void dispose() {
    _controller.removeListener(_loopWithinTrim);
    _controller.dispose();
    super.dispose();
  }

  void _loopWithinTrim() {
    if (!_controller.value.isPlaying) return;
    final state = context.read<VideoClippingViewModel>().state;
    final pos = _controller.value.position;
    if (pos >= state.trimEnd || pos < state.trimStart) {
      _controller.seekTo(state.trimStart);
    }
  }

  void _togglePlay() {
    final state = context.read<VideoClippingViewModel>().state;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (_controller.value.position >= state.trimEnd) {
        _controller.seekTo(state.trimStart);
      }
      _controller.play();
    }
  }

  bool _resumeAfterScrub = false;
  bool _seeking = false;

  void _scrubStart() {
    _resumeAfterScrub = _controller.value.isPlaying;
    _controller.pause();
  }

  Future<void> _scrub(Duration position) async {
    // Drop intermediate positions while a seek is in flight so the preview
    // keeps up with the finger instead of queueing stale seeks.
    if (_seeking) {
      _pendingSeek = position;
      return;
    }
    _seeking = true;
    var target = position;
    do {
      _pendingSeek = null;
      await _controller.seekTo(target);
      target = _pendingSeek ?? target;
    } while (_pendingSeek != null && mounted);
    _seeking = false;
  }

  Duration? _pendingSeek;

  void _scrubEnd() {
    final state = context.read<VideoClippingViewModel>().state;
    _controller.seekTo(state.trimStart);
    if (_resumeAfterScrub) _controller.play();
    _resumeAfterScrub = false;
  }

  void _handleBack(VideoClippingViewModel viewModel) {
    if (!viewModel.previousStep()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleNext(VideoClippingViewModel viewModel) async {
    if (viewModel.state.editorStep != EditorStep.caption) {
      viewModel.nextStep();
      return;
    }
    if (!viewModel.canProcess) return;

    _controller.pause();
    await viewModel.processVideo();
    if (!mounted) return;

    final state = viewModel.state;
    if (state.status == VideoClippingStatus.success) {
      Navigator.of(context).pushNamed(AppRouter.result);
    } else if (state.status == VideoClippingStatus.error && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
      viewModel.dismissError();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final viewModel = context.watch<VideoClippingViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: Colors.black,
      body: state.isProcessing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ExportProgressView(
                    progress: state.processingProgress,
                    trimStart: state.trimStart,
                    trimEnd: state.trimEnd,
                    caption: state.caption,
                    onCancel: viewModel.cancelExport,
                  ),
                ),
              ),
            )
          : _WizardBody(
              controller: _controller,
              state: state,
              viewModel: viewModel,
              onTogglePlay: _togglePlay,
              onScrubStart: _scrubStart,
              onScrub: _scrub,
              onScrubEnd: _scrubEnd,
              onBack: () => _handleBack(viewModel),
              onNext: () => _handleNext(viewModel),
            ),
    );
  }
}

class _WizardBody extends StatelessWidget {
  const _WizardBody({
    required this.controller,
    required this.state,
    required this.viewModel,
    required this.onTogglePlay,
    required this.onScrubStart,
    required this.onScrub,
    required this.onScrubEnd,
    required this.onBack,
    required this.onNext,
  });

  final VideoPlayerController controller;
  final VideoClippingState state;
  final VideoClippingViewModel viewModel;
  final VoidCallback onTogglePlay;
  final VoidCallback onScrubStart;
  final ValueChanged<Duration> onScrub;
  final VoidCallback onScrubEnd;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isCaptionStep = state.editorStep == EditorStep.caption;
    final isFrameStep = state.editorStep == EditorStep.frame;

    final preview = isFrameStep
        ? CropSelector(
            controller: controller,
            cropOffset: state.cropOffset,
            onOffsetChanged: viewModel.setCropOffset,
          )
        : AspectRatio(
            aspectRatio: AppConstants.outputAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoCropPreview(controller: controller, cropOffset: state.cropOffset),
                CaptionOverlay(text: state.caption, style: state.captionStyle),
              ],
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isCaptionStep) const ColoredBox(color: Colors.black) else Center(child: preview),
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 160,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                StepTopBar(
                  currentStep: state.editorStep,
                  onBack: onBack,
                  onStepSelected: viewModel.goToStep,
                  onNext: onNext,
                  nextLabel: state.editorStep == EditorStep.caption ? 'Export' : 'Next',
                ),
                if (isCaptionStep)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: preview,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                GlassPanel(
                  child: _StepPanel(
                    controller: controller,
                    state: state,
                    viewModel: viewModel,
                    onTogglePlay: onTogglePlay,
                    onScrubStart: onScrubStart,
                    onScrub: onScrub,
                    onScrubEnd: onScrubEnd,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepPanel extends StatelessWidget {
  const _StepPanel({
    required this.controller,
    required this.state,
    required this.viewModel,
    required this.onTogglePlay,
    required this.onScrubStart,
    required this.onScrub,
    required this.onScrubEnd,
  });

  final VideoPlayerController controller;
  final VideoClippingState state;
  final VideoClippingViewModel viewModel;
  final VoidCallback onTogglePlay;
  final VoidCallback onScrubStart;
  final ValueChanged<Duration> onScrub;
  final VoidCallback onScrubEnd;

  @override
  Widget build(BuildContext context) {
    switch (state.editorStep) {
      case EditorStep.trim:
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) => TrimPanel(
            videoDuration: state.sourceVideo!.duration,
            start: state.trimStart,
            end: state.trimEnd,
            playhead: value.position,
            isPlaying: value.isPlaying,
            onTogglePlay: onTogglePlay,
            onChanged: (range) => viewModel.setTrimRange(range.$1, range.$2),
            onScrubStart: onScrubStart,
            onScrub: onScrub,
            onScrubEnd: onScrubEnd,
            errorMessage: viewModel.rangeValidationError,
          ),
        );
      case EditorStep.frame:
        return FramePanel(onCenter: viewModel.centerCrop);
      case EditorStep.caption:
        return CaptionPanel(
          initialCaption: state.caption,
          style: state.captionStyle,
          onCaptionChanged: viewModel.setCaption,
          onStyleChanged: viewModel.setCaptionStyle,
        );
    }
  }
}
