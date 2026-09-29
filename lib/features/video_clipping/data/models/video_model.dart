import 'package:semarewards/features/video_clipping/domain/entities/video.dart';

class VideoModel {
  const VideoModel({
    required this.path,
    required this.durationMs,
    required this.width,
    required this.height,
  });

  final String path;
  final int durationMs;
  final int width;
  final int height;

  Video toEntity() => Video(
    path: path,
    duration: Duration(milliseconds: durationMs),
    width: width,
    height: height,
  );
}
