// Author: Rakka Purnama

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:semarewards/app/router/app_router.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/cancel_processing.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/pick_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/process_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/save_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/share_video.dart';
import 'package:semarewards/features/video_clipping/presentation/screens/video_home_screen.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';

class _MockPickVideo extends Mock implements PickVideoUseCase {}

class _MockProcessVideo extends Mock implements ProcessVideoUseCase {}

class _MockSaveVideo extends Mock implements SaveVideoUseCase {}

class _MockShareVideo extends Mock implements ShareVideoUseCase {}

class _MockCancelProcessing extends Mock implements CancelProcessingUseCase {}

void main() {
  late _MockPickVideo pickVideo;
  late VideoClippingViewModel viewModel;

  setUp(() {
    pickVideo = _MockPickVideo();
    viewModel = VideoClippingViewModel(
      pickVideo: pickVideo,
      processVideo: _MockProcessVideo(),
      saveVideo: _MockSaveVideo(),
      shareVideo: _MockShareVideo(),
      cancelProcessing: _MockCancelProcessing(),
    );
  });

  Widget buildSubject() {
    return ChangeNotifierProvider<VideoClippingViewModel>.value(
      value: viewModel,
      child: const MaterialApp(home: VideoHomeScreen()),
    );
  }

  testWidgets('shows the pick video CTA', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Choose a video'), findsOneWidget);
  });

  testWidgets('shows an error snackbar when picking fails', (tester) async {
    when(() => pickVideo()).thenAnswer(
      (_) async => const Result.failure(VideoPickFailure('No video selected.')),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('Choose a video'));
    await tester.pump(); // start the frame that shows the SnackBar
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No video selected.'), findsOneWidget);
  });

  testWidgets('navigates to the editor route once a video is picked', (tester) async {
    when(() => pickVideo()).thenAnswer(
      (_) async => Result.success(
        Video(
          path: '/tmp/a.mp4',
          duration: const Duration(seconds: 30),
          width: 1920,
          height: 1080,
        ),
      ),
    );

    // A stand-in route table: the real editor screen needs a platform
    // channel (VideoPlayerController) that isn't available in widget tests.
    await tester.pumpWidget(
      ChangeNotifierProvider<VideoClippingViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          home: const VideoHomeScreen(),
          onGenerateRoute: (settings) => settings.name == AppRouter.editor
              ? MaterialPageRoute(builder: (_) => const Text('EDITOR'))
              : null,
        ),
      ),
    );

    await tester.tap(find.text('Choose a video'));
    await tester.pumpAndSettle();

    expect(find.text('EDITOR'), findsOneWidget);
    expect(find.byType(VideoHomeScreen), findsNothing);
  });
}
