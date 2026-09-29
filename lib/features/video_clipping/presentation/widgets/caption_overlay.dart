import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';

class CaptionOverlay extends StatelessWidget {
  const CaptionOverlay({super.key, required this.text, required this.style});

  final String text;
  final CaptionStyle style;

  static const _fontFamilies = <CaptionFont, String>{
    CaptionFont.sans: 'Instrument Sans',
    CaptionFont.serif: 'Instrument Serif',
    CaptionFont.mono: 'JetBrains Mono',
    CaptionFont.display: 'Anton',
  };

  static const _fontWeights = <CaptionFont, FontWeight>{
    CaptionFont.sans: FontWeight.w700,
    CaptionFont.serif: FontWeight.w400,
    CaptionFont.mono: FontWeight.w600,
    CaptionFont.display: FontWeight.w400,
  };

  static const _sizeMultipliers = <CaptionSize, double>{
    CaptionSize.small: 0.8,
    CaptionSize.medium: 1.0,
    CaptionSize.large: 1.3,
  };

  static const _positionFractions = <CaptionPosition, double>{
    CaptionPosition.top: 0.16,
    CaptionPosition.middle: 0.5,
    CaptionPosition.bottom: 0.82,
  };

  static const _colors = <CaptionColor, Color>{
    CaptionColor.white: AppColors.captionWhite,
    CaptionColor.black: AppColors.captionBlack,
    CaptionColor.purple: AppColors.captionPurple,
    CaptionColor.coral: AppColors.captionCoral,
    CaptionColor.sky: AppColors.captionSky,
  };

  bool get _darkText => style.color == CaptionColor.black;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fontSize = width * AppConstants.captionFontRatio * _sizeMultipliers[style.size]!;
        final yFraction = _positionFractions[style.position]!;

        final textStyle = TextStyle(
          fontFamily: _fontFamilies[style.font],
          fontWeight: _fontWeights[style.font],
          fontStyle: style.font == CaptionFont.serif
              ? FontStyle.italic
              : FontStyle.normal,
          fontSize: fontSize,
          color: _colors[style.color],
          height: 1.2,
        );

        return Align(
          alignment: Alignment(0, yFraction * 2 - 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: _styledText(text, textStyle),
          ),
        );
      },
    );
  }

  Widget _styledText(String text, TextStyle textStyle) {
    switch (style.background) {
      case CaptionBackground.none:
        return Text(text, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
      case CaptionBackground.box:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (_darkText ? Colors.white : Colors.black).withValues(
              alpha: _darkText ? 0.92 : 0.8,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(text, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      case CaptionBackground.glow:
        final glowColor = (_darkText ? Colors.white : Colors.black).withValues(
          alpha: _darkText ? 0.85 : 0.7,
        );
        return Stack(
          children: [
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..color = glowColor,
              ),
            ),
            Text(text, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        );
    }
  }
}
