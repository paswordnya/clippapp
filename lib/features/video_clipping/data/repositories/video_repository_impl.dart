import 'package:semarewards/core/error/app_exception.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/data/datasources/file_storage_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/share_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/video_picker_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/video_processor_datasource.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  const VideoRepositoryImpl({
    required VideoPickerDataSource picker,
    required VideoProcessorDataSource processor,
    required FileStorageDataSource storage,
    required ShareDataSource share,
  }) : _picker = picker,
       _processor = processor,
       _storage = storage,
       _share = share;

  final VideoPickerDataSource _picker;
  final VideoProcessorDataSource _processor;
  final FileStorageDataSource _storage;
  final ShareDataSource _share;

  @override
  Future<Result<Video>> pickVideo() async {
    try {
      final model = await _picker.pickVideo();
      if (model == null) {
        return const Result.failure(VideoPickFailure('No video selected.'));
      }
      return Result.success(model.toEntity());
    } on VideoPickException catch (e) {
      return Result.failure(VideoPickFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('$e'));
    }
  }

  @override
  Future<Result<ProcessedVideo>> processVideo({
    required Video source,
    required Duration start,
    required Duration end,
    required double cropOffset,
    required String caption,
    required CaptionStyle captionStyle,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final model = await _processor.process(
        inputPath: source.path,
        sourceWidth: source.width,
        sourceHeight: source.height,
        start: start,
        end: end,
        cropOffset: cropOffset,
        caption: caption,
        captionStyle: captionStyle,
        onProgress: onProgress,
      );
      return Result.success(model.toEntity());
    } on VideoProcessingException catch (e) {
      return Result.failure(ProcessingFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('$e'));
    }
  }

  @override
  Future<void> cancelProcessing() => _processor.cancel();

  @override
  Future<Result<void>> saveToGallery(ProcessedVideo video) async {
    try {
      await _storage.saveToGallery(video.path);
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('$e'));
    }
  }

  @override
  Future<Result<void>> shareVideo(ProcessedVideo video) async {
    try {
      await _share.share(video.path);
      return const Result.success(null);
    } on ShareException catch (e) {
      return Result.failure(ShareFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('$e'));
    }
  }
}
