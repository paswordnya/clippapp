import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';

class ValidateClipUseCase {
  const ValidateClipUseCase();

  Result<Duration> call({
    required Duration videoDuration,
    required Duration start,
    required Duration end,
  }) {
    if (start < Duration.zero || end > videoDuration) {
      return const Result.failure(
        ValidationFailure('Trim range is outside the video duration.'),
      );
    }

    if (end <= start) {
      return const Result.failure(
        ValidationFailure('End time must be after start time.'),
      );
    }

    final clipDuration = end - start;

    if (clipDuration > AppConstants.maxClipDuration) {
      return Result.failure(
        ValidationFailure(
          'Clip must be at most ${AppConstants.maxClipDuration.inSeconds} seconds.',
        ),
      );
    }

    if (clipDuration < AppConstants.minClipDuration) {
      return const Result.failure(
        ValidationFailure('Clip is too short.'),
      );
    }

    return Result.success(clipDuration);
  }
}
