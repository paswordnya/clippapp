// Author: Rakka Purnama

import 'package:flutter/material.dart';

/// Dark-theme palette matching the "Clipp App" reference design. A light theme
/// isn't implemented — the reference explores both, but one cohesive theme
/// keeps this within a realistic scope.
abstract final class AppColors {
  static const Color background = Color(0xFF0F0F0E);
  static const Color surface = Color(0xFF1B1A19);
  static const Color surfaceVariant = Color(0xFF2A2926);
  static const Color track = Color(0xFF1B1A19);
  static const Color active = Color(0xFF3A3834);

  static const Color primary = Color(0xFF5D17EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color accentText = Color(0xFFA98BFF);

  static const Color textPrimary = Color(0xFFF3F1EC);
  static const Color textSecondary = Color(0xFF9A968F);
  static const Color divider = Color(0x14FFFFFF);

  static const Color error = Color(0xFFEF5A5A);
  static const Color success = Color(0xFF4CD787);

  /// Frosted bottom-panel background (used with BackdropFilter blur).
  static const Color glass = Color(0xCC181716);
  static const Color sheet = Color(0xFF1B1A19);
  static const Color sheet2 = Color(0xFF242321);
  static const Color overlay = Color(0x8C000000);

  // Burned-in caption color choices offered on the Caption step.
  static const Color captionWhite = Color(0xFFFFFFFF);
  static const Color captionBlack = Color(0xFF141412);
  static const Color captionPurple = primary;
  static const Color captionCoral = Color(0xFFFF7A66);
  static const Color captionSky = Color(0xFF5AC8F5);
}
