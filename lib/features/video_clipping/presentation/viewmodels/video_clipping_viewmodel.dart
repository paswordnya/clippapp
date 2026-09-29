import 'package:flutter/foundation.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/cancel_processing.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/pick_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/process_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/save_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/share_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/validate_clip.dart';
import 'package:semarewards/features/video_clipping/presentation/state/video_clipping_state.dart';

class VideoClippingViewModel extends ChangeNotifier {
  VideoClippingViewModel({
    required PickVideoUseCase pickVideo,
    required ProcessVideoUseCase processVideo,
    required SaveVideoUseCase saveVideo,
    required ShareVideoUseCase shareVideo,
    required CancelProcessingUseCase cancelProcessing,
    ValidateClipUseCase validateClip = const ValidateClipUseCase(),
  }) : _pickVideo = pickVideo,
       _processVideo = processVideo,
       _saveVideo = saveVideo,
       _shareVideo = shareVideo,
       _cancelProcessing = cancelProcessing,
       _validateClip = validateClip;

  final PickVideoUseCase _pickVideo;
  final ProcessVideoUseCase _processVideo;
  final SaveVideoUseCase _saveVideo;
  final ShareVideoUseCase _shareVideo;
  final CancelProcessingUseCase _cancelProcessing;
  final ValidateClipUseCase _validateClip;

  VideoClippingState _state = const VideoClippingState();
  VideoClippingState get state => _state;

  bool _isSaving = false;
  bool _isSharing = false;
  bool get isSaving => _isSaving;
  bool get isSharing => _isSharing;

  String? get rangeValidationError {
    final source = _state.sourceVideo;
    if (source == null) return null;
    final result = _validateClip(
      videoDuration: source.duration,
      start: _state.trimStart,
      end: _state.trimEnd,
    );
    return result.failureOrNull?.message;
  }

  bool get canProcess =>
      _state.hasSource && !_state.isProcessing && rangeValidationError == null;

  Future<void> pickVideo() async {
    _update(_state.copyWith(status: VideoClippingStatus.pickingVideo));

    final result = await _pickVideo();
    result.when(
      success: (video) => _applyPickedVideo(video),
      failure: (failure) => _update(
        _state.copyWith(
          status: VideoClippingStatus.initial,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void _applyPickedVideo(Video video) {
    final initialEnd = video.duration < AppConstants.maxClipDuration
        ? video.duration
        : AppConstants.maxClipDuration;

    _update(
      _state.copyWith(
        status: VideoClippingStatus.editing,
        sourceVideo: video,
        trimStart: Duration.zero,
        trimEnd: initialEnd,
        editorStep: EditorStep.trim,
        cropOffset: 0.5,
        caption: '',
        captionStyle: const CaptionStyle(),
        processedVideo: null,
        errorMessage: null,
      ),
    );
  }

  void setTrimRange(Duration start, Duration end) {
    _update(_state.copyWith(trimStart: start, trimEnd: end));
  }

  void setCropOffset(double offset) {
    _update(_state.copyWith(cropOffset: offset.clamp(0.0, 1.0)));
  }

  void centerCrop() {
    _update(_state.copyWith(cropOffset: 0.5));
  }

  void setCaption(String caption) {
    _update(_state.copyWith(caption: caption));
  }

  void setCaptionStyle(CaptionStyle style) {
    _update(_state.copyWith(captionStyle: style));
  }

  static const _stepOrder = [EditorStep.trim, EditorStep.frame, EditorStep.caption];

  void goToStep(EditorStep step) {
    _update(_state.copyWith(editorStep: step));
  }

  bool nextStep() {
    final idx = _stepOrder.indexOf(_state.editorStep);
    if (idx >= _stepOrder.length - 1) return false;
    _update(_state.copyWith(editorStep: _stepOrder[idx + 1]));
    return true;
  }

  bool previousStep() {
    final idx = _stepOrder.indexOf(_state.editorStep);
    if (idx <= 0) return false;
    _update(_state.copyWith(editorStep: _stepOrder[idx - 1]));
    return true;
  }

  Future<void> processVideo() async {
    final source = _state.sourceVideo;
    if (source == null || _state.isProcessing) return;
    if (rangeValidationError != null) return;

    _update(
      _state.copyWith(
        status: VideoClippingStatus.processing,
        processingProgress: 0,
        errorMessage: null,
      ),
    );

    final result = await _processVideo(
      source: source,
      start: _state.trimStart,
      end: _state.trimEnd,
      cropOffset: _state.cropOffset,
      caption: _state.caption,
      captionStyle: _state.captionStyle,
      onProgress: (progress) {
        _update(_state.copyWith(processingProgress: progress));
      },
    );

    result.when(
      success: (processed) => _update(
        _state.copyWith(
          status: VideoClippingStatus.success,
          processedVideo: processed,
        ),
      ),
      failure: (failure) {
        if (_cancelling) {
          _cancelling = false;
          _update(_state.copyWith(status: VideoClippingStatus.editing));
          return;
        }
        _update(
          _state.copyWith(
            status: VideoClippingStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  bool _cancelling = false;

  Future<void> cancelExport() async {
    if (!_state.isProcessing) return;
    _cancelling = true;
    await _cancelProcessing();
  }

  Future<String?> save() async {
    final processed = _state.processedVideo;
    if (processed == null || _isSaving) return 'Nothing to save yet.';

    _isSaving = true;
    notifyListeners();

    final result = await _saveVideo(processed);

    _isSaving = false;
    notifyListeners();

    return result.failureOrNull?.message;
  }

  Future<String?> share() async {
    final processed = _state.processedVideo;
    if (processed == null || _isSharing) return 'Nothing to share yet.';

    _isSharing = true;
    notifyListeners();

    final result = await _shareVideo(processed);

    _isSharing = false;
    notifyListeners();

    return result.failureOrNull?.message;
  }

  void dismissError() {
    _update(_state.copyWith(errorMessage: null));
  }

  void startOver() {
    _update(const VideoClippingState());
  }

  void _update(VideoClippingState next) {
    _state = next;
    notifyListeners();
  }
}
