// Author: Rakka Purnama

import 'package:flutter_test/flutter_test.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/validate_clip.dart';

void main() {
  const useCase = ValidateClipUseCase();
  const videoDuration = Duration(minutes: 3);

  test('returns the clip duration when the range is valid', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: const Duration(seconds: 10),
      end: const Duration(seconds: 40),
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, const Duration(seconds: 30));
  });

  test('rejects a range longer than 60 seconds', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: Duration.zero,
      end: const Duration(seconds: 61),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('rejects end time at or before start time', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: const Duration(seconds: 20),
      end: const Duration(seconds: 20),
    );

    expect(result.isFailure, isTrue);
  });

  test('rejects a range outside the source video duration', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: const Duration(seconds: 10),
      end: const Duration(minutes: 5),
    );

    expect(result.isFailure, isTrue);
  });

  test('rejects a near-zero duration clip', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: const Duration(seconds: 10),
      end: const Duration(seconds: 10, milliseconds: 100),
    );

    expect(result.isFailure, isTrue);
  });

  test('accepts a clip exactly at the 60 second cap', () {
    final result = useCase(
      videoDuration: videoDuration,
      start: Duration.zero,
      end: const Duration(seconds: 60),
    );

    expect(result.isSuccess, isTrue);
  });
}
