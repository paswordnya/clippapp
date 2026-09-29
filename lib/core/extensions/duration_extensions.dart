// Author: Rakka Purnama

extension DurationFormatting on Duration {
  /// Formats as `m:ss`, e.g. 1:05. Good enough for clips capped at 60s and
  /// source videos of a few minutes.
  String toClockString() {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats with one decimal of precision, e.g. 12.3s. Used where sub-second
  /// accuracy matters (clip duration, trim boundaries).
  String toSecondsString() {
    return '${(inMilliseconds / 1000).toStringAsFixed(1)}s';
  }
}
