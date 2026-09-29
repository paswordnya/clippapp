// Author: Rakka Purnama

/// Exceptions thrown by data sources / infrastructure. The repository is
/// responsible for catching these and mapping them to a [Failure] so the
/// domain and presentation layers never depend on infrastructure error types.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class VideoPickException extends AppException {
  const VideoPickException(super.message);
}

final class VideoProcessingException extends AppException {
  const VideoProcessingException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class ShareException extends AppException {
  const ShareException(super.message);
}
