// Author: Rakka Purnama

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/cancel_processing.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/pick_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/process_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/save_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/share_video.dart';
import 'package:semarewards/features/video_clipping/presentation/state/video_clipping_state.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';

class _MockPickVideo extends Mock implements PickVideoUseCase {}

class _MockProcessVideo extends Mock implements ProcessVideoUseCase {}

class _MockSaveVideo extends Mock implements SaveVideoUseCase {}

class _MockShareVideo extends Mock implements ShareVideoUseCase {}

class _MockCancelProcessing extends Mock implements CancelProcessingUseCase {}

void main() {
  late _MockPickVideo pickVideo;
  late _MockProcessVideo processVideo;
  late _MockSaveVideo saveVideo;
  late _MockShareVideo shareVideo;
  late _MockCancelProcessing cancelProcessing;
  late VideoClippingViewModel viewModel;

  final video = Video(
    path: '/tmp/a.mp4',
    duration: const Duration(seconds: 90),
    width: 1920,
    height: 1080,
  );
  const style = CaptionStyle();

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(video);
    registerFallbackValue('');
    registerFallbackValue(style);
    registerFallbackValue(
      const ProcessedVideo(path: '', duration: Duration.zero, fileSizeBytes: 0),
    );
  });

  setUp(() {
    pickVideo = _MockPickVideo();
    processVideo = _MockProcessVideo();
    saveVideo = _MockSaveVideo();
    shareVideo = _MockShareVideo();
    cancelProcessing = _MockCancelProcessing();
    viewModel = VideoClippingViewModel(
      pickVideo: pickVideo,
      processVideo: processVideo,
      saveVideo: saveVideo,
      shareVideo: shareVideo,
      cancelProcessing: cancelProcessing,
    );
  });

  test('picking a video moves to editing and defaults the trim window', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));

    await viewModel.pickVideo();

    expect(viewModel.state.status, VideoClippingStatus.editing);
    expect(viewModel.state.sourceVideo, video);
    expect(viewModel.state.trimStart, Duration.zero);
    expect(viewModel.state.trimEnd, const Duration(seconds: 60));
    expect(viewModel.state.editorStep, EditorStep.trim);
    expect(viewModel.state.cropOffset, 0.5);
  });

  test('a pick failure surfaces the error and stays on the initial state', () async {
    when(() => pickVideo()).thenAnswer(
      (_) async => const Result.failure(VideoPickFailure('No video selected.')),
    );

    await viewModel.pickVideo();

    expect(viewModel.state.status, VideoClippingStatus.initial);
    expect(viewModel.state.errorMessage, 'No video selected.');
  });

  test('canProcess is false until the trim range is valid', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    viewModel.setTrimRange(const Duration(seconds: 10), const Duration(seconds: 5));
    expect(viewModel.canProcess, isFalse);

    viewModel.setTrimRange(const Duration(seconds: 10), const Duration(seconds: 30));
    expect(viewModel.canProcess, isTrue);
  });

  test('wizard step navigation moves through trim -> frame -> caption', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    expect(viewModel.nextStep(), isTrue);
    expect(viewModel.state.editorStep, EditorStep.frame);
    expect(viewModel.nextStep(), isTrue);
    expect(viewModel.state.editorStep, EditorStep.caption);
    expect(viewModel.nextStep(), isFalse); // already last step
    expect(viewModel.state.editorStep, EditorStep.caption);

    expect(viewModel.previousStep(), isTrue);
    expect(viewModel.state.editorStep, EditorStep.frame);
  });

  test('setCaptionStyle and setCropOffset update state', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    viewModel.setCropOffset(1.4); // clamped
    expect(viewModel.state.cropOffset, 1.0);

    viewModel.setCaptionStyle(style.copyWith(color: CaptionColor.coral));
    expect(viewModel.state.captionStyle.color, CaptionColor.coral);
  });

  test('processVideo reports progress and transitions to success', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    const processed = ProcessedVideo(
      path: '/tmp/out.mp4',
      duration: Duration(seconds: 60),
      fileSizeBytes: 2048,
    );

    when(
      () => processVideo(
        source: any(named: 'source'),
        start: any(named: 'start'),
        end: any(named: 'end'),
        cropOffset: any(named: 'cropOffset'),
        caption: any(named: 'caption'),
        captionStyle: any(named: 'captionStyle'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final onProgress = invocation.namedArguments[#onProgress]
          as void Function(double)?;
      onProgress?.call(0.5);
      onProgress?.call(1.0);
      return const Result.success(processed);
    });

    final progressValues = <double>[];
    viewModel.addListener(() {
      progressValues.add(viewModel.state.processingProgress);
    });

    await viewModel.processVideo();

    expect(viewModel.state.status, VideoClippingStatus.success);
    expect(viewModel.state.processedVideo, processed);
    expect(progressValues, containsAll([0.5, 1.0]));
  });

  test('a concurrent processVideo call while processing is ignored', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    when(
      () => processVideo(
        source: any(named: 'source'),
        start: any(named: 'start'),
        end: any(named: 'end'),
        cropOffset: any(named: 'cropOffset'),
        caption: any(named: 'caption'),
        captionStyle: any(named: 'captionStyle'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const Result.success(
        ProcessedVideo(path: '/tmp/out.mp4', duration: Duration(seconds: 60), fileSizeBytes: 1),
      );
    });

    final first = viewModel.processVideo();
    await viewModel.processVideo(); // should be a no-op: already processing
    await first;

    verify(
      () => processVideo(
        source: any(named: 'source'),
        start: any(named: 'start'),
        end: any(named: 'end'),
        cropOffset: any(named: 'cropOffset'),
        caption: any(named: 'caption'),
        captionStyle: any(named: 'captionStyle'),
        onProgress: any(named: 'onProgress'),
      ),
    ).called(1);
  });

  test('cancelExport cancels without surfacing an error banner', () async {
    when(() => pickVideo()).thenAnswer((_) async => Result.success(video));
    await viewModel.pickVideo();

    when(() => cancelProcessing()).thenAnswer((_) async {});
    when(
      () => processVideo(
        source: any(named: 'source'),
        start: any(named: 'start'),
        end: any(named: 'end'),
        cropOffset: any(named: 'cropOffset'),
        caption: any(named: 'caption'),
        captionStyle: any(named: 'captionStyle'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      await viewModel.cancelExport();
      return const Result.failure(ProcessingFailure('Export cancelled.'));
    });

    await viewModel.processVideo();

    expect(viewModel.state.status, VideoClippingStatus.editing);
    expect(viewModel.state.errorMessage, isNull);
    verify(() => cancelProcessing()).called(1);
  });
}
