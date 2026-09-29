// Author: Rakka Purnama

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/process_video.dart';

class _MockVideoRepository extends Mock implements VideoRepository {}

void main() {
  late _MockVideoRepository repository;
  late ProcessVideoUseCase useCase;

  final source = Video(
    path: '/tmp/source.mp4',
    duration: const Duration(minutes: 2),
    width: 1920,
    height: 1080,
  );
  const style = CaptionStyle();

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(source);
    registerFallbackValue(style);
  });

  setUp(() {
    repository = _MockVideoRepository();
    useCase = ProcessVideoUseCase(repository);
  });

  test('delegates to the repository when the clip range is valid', () async {
    const processed = ProcessedVideo(
      path: '/tmp/out.mp4',
      duration: Duration(seconds: 20),
      fileSizeBytes: 1024,
    );
    when(
      () => repository.processVideo(
        source: source,
        start: const Duration(seconds: 5),
        end: const Duration(seconds: 25),
        cropOffset: 0.5,
        caption: 'Hello',
        captionStyle: style,
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Result.success(processed));

    final result = await useCase(
      source: source,
      start: const Duration(seconds: 5),
      end: const Duration(seconds: 25),
      cropOffset: 0.5,
      caption: 'Hello',
      captionStyle: style,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, processed);
    verify(
      () => repository.processVideo(
        source: source,
        start: const Duration(seconds: 5),
        end: const Duration(seconds: 25),
        cropOffset: 0.5,
        caption: 'Hello',
        captionStyle: style,
        onProgress: any(named: 'onProgress'),
      ),
    ).called(1);
  });

  test('fails fast without calling the repository when the range is invalid', () async {
    final result = await useCase(
      source: source,
      start: Duration.zero,
      end: const Duration(seconds: 90),
      cropOffset: 0.5,
      caption: '',
      captionStyle: style,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    verifyNever(
      () => repository.processVideo(
        source: any(named: 'source'),
        start: any(named: 'start'),
        end: any(named: 'end'),
        cropOffset: any(named: 'cropOffset'),
        caption: any(named: 'caption'),
        captionStyle: any(named: 'captionStyle'),
        onProgress: any(named: 'onProgress'),
      ),
    );
  });

  test('rejects a caption longer than the max length', () async {
    final result = await useCase(
      source: source,
      start: Duration.zero,
      end: const Duration(seconds: 10),
      cropOffset: 0.5,
      caption: 'x' * 200,
      captionStyle: style,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });
}
