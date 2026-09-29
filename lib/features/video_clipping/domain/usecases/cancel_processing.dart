import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';

class CancelProcessingUseCase {
  const CancelProcessingUseCase(this._repository);

  final VideoRepository _repository;

  Future<void> call() => _repository.cancelProcessing();
}
