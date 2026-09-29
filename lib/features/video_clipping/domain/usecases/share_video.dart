import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/processed_video.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';

class ShareVideoUseCase {
  const ShareVideoUseCase(this._repository);

  final VideoRepository _repository;

  Future<Result<void>> call(ProcessedVideo video) {
    return _repository.shareVideo(video);
  }
}
