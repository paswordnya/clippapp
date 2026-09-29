// Author: Rakka Purnama

/// Cross-cutting business/tech constants for the video clipping feature.
abstract final class AppConstants {
  /// Hard cap enforced by [ValidateClipUseCase] and passed to FFmpeg as a
  /// safety net (`-t`), per the assignment's "max 60 seconds" rule.
  static const Duration maxClipDuration = Duration(seconds: 60);

  /// Minimum viable clip length; avoids degenerate 0-frame exports.
  static const Duration minClipDuration = Duration(milliseconds: 500);

  /// Output aspect ratio (width / height) for the vertical export.
  static const double outputAspectRatio = 9 / 16;

  /// Human-readable label for [outputAspectRatio], reused across UI copy.
  static const String outputAspectLabel = '9:16';

  /// Fixed output resolution. Chosen over "match input height" so exports
  /// are predictable in size/quality regardless of source resolution.
  static const int outputWidth = 720;
  static const int outputHeight = 1280;

  static const int maxCaptionLength = 40;

  /// Caption font size as a fraction of the output width. Shared by the
  /// on-screen preview and the FFmpeg drawtext so both render the same.
  static const double captionFontRatio = 0.05;
}
