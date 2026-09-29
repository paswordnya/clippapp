import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';

class ProcessedVideoModel {
  const ProcessedVideoModel({
    required this.path,
    required this.durationMs,
    required this.fileSizeBytes,
  });

  final String path;
  final int durationMs;
  final int fileSizeBytes;

  ProcessedVideo toEntity() => ProcessedVideo(
    path: path,
    duration: Duration(milliseconds: durationMs),
    fileSizeBytes: fileSizeBytes,
  );
}
