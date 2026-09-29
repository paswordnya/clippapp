import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';

abstract interface class VideoRepository {
  Future<Result<Video>> pickVideo();

  Future<Result<ProcessedVideo>> processVideo({
    required Video source,
    required Duration start,
    required Duration end,
    required double cropOffset,
    required String caption,
    required CaptionStyle captionStyle,
    void Function(double progress)? onProgress,
  });

  Future<void> cancelProcessing();

  Future<Result<void>> saveToGallery(ProcessedVideo video);

  Future<Result<void>> shareVideo(ProcessedVideo video);
}
