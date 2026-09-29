import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';
import 'package:semarewards/features/video_clipping/domain/entities/video.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';

class PickVideoUseCase {
  const PickVideoUseCase(this._repository);

  final VideoRepository _repository;

  Future<Result<Video>> call() async {
    final result = await _repository.pickVideo();
    return result.when(
      success: (video) {
        if (!video.isLandscape) {
          return const Result.failure(
            ValidationFailure('Please pick a landscape video.'),
          );
        }
        return Result.success(video);
      },
      failure: (failure) => Result.failure(failure),
    );
  }
}
