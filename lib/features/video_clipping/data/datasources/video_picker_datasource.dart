import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:semarewards/core/error/app_exception.dart';
import 'package:semarewards/features/video_clipping/data/models/video_model.dart';
import 'package:video_player/video_player.dart';

abstract interface class VideoPickerDataSource {
  Future<VideoModel?> pickVideo();
}

class VideoPickerDataSourceImpl implements VideoPickerDataSource {
  VideoPickerDataSourceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<VideoModel?> pickVideo() async {
    final XFile? file;
    try {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      throw VideoPickException('Could not open the gallery: $e');
    }

    if (file == null) {
      return null;
    }

    final controller = VideoPlayerController.file(File(file.path));
    try {
      await controller.initialize();
      final value = controller.value;
      if (!value.isInitialized || value.duration == Duration.zero) {
        throw const VideoPickException('The selected file is not a playable video.');
      }
      return VideoModel(
        path: file.path,
        durationMs: value.duration.inMilliseconds,
        width: value.size.width.round(),
        height: value.size.height.round(),
      );
    } catch (e) {
      if (e is VideoPickException) rethrow;
      throw VideoPickException('Could not read video metadata: $e');
    } finally {
      await controller.dispose();
    }
  }
}
