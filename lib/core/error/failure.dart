// Author: Rakka Purnama

/// Domain-level failures. Kept small and specific enough for the UI to show
/// a meaningful message without leaking infrastructure details (FFmpeg
/// return codes, platform exceptions, etc.) into the presentation layer.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class VideoPickFailure extends Failure {
  const VideoPickFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class ShareFailure extends Failure {
  const ShareFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
