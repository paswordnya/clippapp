import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';

enum VideoClippingStatus {
  initial,
  pickingVideo,
  videoSelected,
  editing,
  processing,
  success,
  error,
}

enum EditorStep { trim, frame, caption }

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class VideoClippingState {
  const VideoClippingState({
    this.status = VideoClippingStatus.initial,
    this.sourceVideo,
    this.trimStart = Duration.zero,
    this.trimEnd = Duration.zero,
    this.editorStep = EditorStep.trim,
    this.cropOffset = 0.5,
    this.caption = '',
    this.captionStyle = const CaptionStyle(),
    this.processedVideo,
    this.processingProgress = 0.0,
    this.errorMessage,
  });

  final VideoClippingStatus status;
  final Video? sourceVideo;
  final Duration trimStart;
  final Duration trimEnd;
  final EditorStep editorStep;

  final double cropOffset;
  final String caption;
  final CaptionStyle captionStyle;
  final ProcessedVideo? processedVideo;
  final double processingProgress;
  final String? errorMessage;

  Duration get clipDuration =>
      trimEnd > trimStart ? trimEnd - trimStart : Duration.zero;

  bool get isProcessing => status == VideoClippingStatus.processing;
  bool get hasSource => sourceVideo != null;

  VideoClippingState copyWith({
    VideoClippingStatus? status,
    Object? sourceVideo = _unset,
    Duration? trimStart,
    Duration? trimEnd,
    EditorStep? editorStep,
    double? cropOffset,
    String? caption,
    CaptionStyle? captionStyle,
    Object? processedVideo = _unset,
    double? processingProgress,
    Object? errorMessage = _unset,
  }) {
    return VideoClippingState(
      status: status ?? this.status,
      sourceVideo: identical(sourceVideo, _unset)
          ? this.sourceVideo
          : sourceVideo as Video?,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      editorStep: editorStep ?? this.editorStep,
      cropOffset: cropOffset ?? this.cropOffset,
      caption: caption ?? this.caption,
      captionStyle: captionStyle ?? this.captionStyle,
      processedVideo: identical(processedVideo, _unset)
          ? this.processedVideo
          : processedVideo as ProcessedVideo?,
      processingProgress: processingProgress ?? this.processingProgress,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
