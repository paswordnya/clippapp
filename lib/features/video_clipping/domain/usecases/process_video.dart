import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/validate_clip.dart';

class ProcessVideoUseCase {
  const ProcessVideoUseCase(
    this._repository, {
    ValidateClipUseCase validateClip = const ValidateClipUseCase(),
  }) : _validateClip = validateClip;

  final VideoRepository _repository;
  final ValidateClipUseCase _validateClip;

  Future<Result<ProcessedVideo>> call({
    required Video source,
    required Duration start,
    required Duration end,
    required double cropOffset,
    required String caption,
    required CaptionStyle captionStyle,
    void Function(double progress)? onProgress,
  }) async {
    final validation = _validateClip(
      videoDuration: source.duration,
      start: start,
      end: end,
    );
    if (validation.isFailure) {
      return Result.failure(validation.failureOrNull!);
    }

    final trimmedCaption = caption.trim();
    if (trimmedCaption.length > AppConstants.maxCaptionLength) {
      return Result.failure(
        ValidationFailure(
          'Caption must be at most ${AppConstants.maxCaptionLength} characters.',
        ),
      );
    }

    return _repository.processVideo(
      source: source,
      start: start,
      end: end,
      cropOffset: cropOffset.clamp(0.0, 1.0),
      caption: trimmedCaption,
      captionStyle: captionStyle,
      onProgress: onProgress,
    );
  }
}
