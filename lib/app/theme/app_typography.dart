// Author: Rakka Purnama

import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';

/// UI copy uses Instrument Sans; numeric/technical labels (timecodes,
/// resolutions, counters) use JetBrains Mono, matching the reference design's
/// use of a mono face to set data apart from prose.
abstract final class AppTypography {
  static const String sans = 'Instrument Sans';
  static const String mono = 'JetBrains Mono';

  static const TextStyle headline = TextStyle(
    fontFamily: sans,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.05,
  );

  static const TextStyle title = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  static const TextStyle mono11 = TextStyle(
    fontFamily: mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: -0.2,
  );

  static const TextStyle monoTimecode = TextStyle(
    fontFamily: mono,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );
}
