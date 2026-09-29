import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/app/theme/app_spacing.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/segmented_control.dart';

class CaptionPanel extends StatefulWidget {
  const CaptionPanel({
    super.key,
    required this.initialCaption,
    required this.style,
    required this.onCaptionChanged,
    required this.onStyleChanged,
  });

  final String initialCaption;
  final CaptionStyle style;
  final ValueChanged<String> onCaptionChanged;
  final ValueChanged<CaptionStyle> onStyleChanged;

  @override
  State<CaptionPanel> createState() => _CaptionPanelState();
}

class _CaptionPanelState extends State<CaptionPanel> {
  late final TextEditingController _controller;

  static const _fonts = [
    (CaptionFont.sans, 'Sans', 'Instrument Sans', FontWeight.w700, FontStyle.normal),
    (CaptionFont.serif, 'Serif', 'Instrument Serif', FontWeight.w400, FontStyle.italic),
    (CaptionFont.mono, 'Mono', 'JetBrains Mono', FontWeight.w600, FontStyle.normal),
    (CaptionFont.display, 'BOLD', 'Anton', FontWeight.w400, FontStyle.normal),
  ];

  static const _colors = [
    (CaptionColor.white, Colors.white),
    (CaptionColor.black, AppColors.captionBlack),
    (CaptionColor.purple, AppColors.captionPurple),
    (CaptionColor.coral, AppColors.captionCoral),
    (CaptionColor.sky, AppColors.captionSky),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCaption);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CaptionInputField(
          controller: _controller,
          onChanged: widget.onCaptionChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _fonts.map((f) {
            final isActive = f.$1 == style.font;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => widget.onStyleChanged(style.copyWith(font: f.$1)),
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.textPrimary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontFamily: f.$3,
                        fontWeight: f.$4,
                        fontStyle: f.$5,
                        fontSize: 15,
                        color: isActive ? AppColors.background : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: SegmentedControl<CaptionSize>(
                options: const [
                  (CaptionSize.small, 'S'),
                  (CaptionSize.medium, 'M'),
                  (CaptionSize.large, 'L'),
                ],
                value: style.size,
                onChanged: (v) => widget.onStyleChanged(style.copyWith(size: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: SegmentedControl<CaptionPosition>(
                options: const [
                  (CaptionPosition.top, 'Top'),
                  (CaptionPosition.middle, 'Mid'),
                  (CaptionPosition.bottom, 'Bottom'),
                ],
                value: style.position,
                onChanged: (v) => widget.onStyleChanged(style.copyWith(position: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            ..._colors.map((c) {
              final isActive = c.$1 == style.color;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => widget.onStyleChanged(style.copyWith(color: c.$1)),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c.$2,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: AppColors.textPrimary, width: 2)
                          : Border.all(color: AppColors.divider),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: 168,
              child: SegmentedControl<CaptionBackground>(
                options: const [
                  (CaptionBackground.none, 'None'),
                  (CaptionBackground.box, 'Box'),
                  (CaptionBackground.glow, 'Glow'),
                ],
                value: style.background,
                onChanged: (v) => widget.onStyleChanged(style.copyWith(background: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CaptionInputField extends StatelessWidget {
  const _CaptionInputField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: AppConstants.maxCaptionLength,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: 'Add one line of caption',
              ),
              onChanged: (text) => onChanged(text.replaceAll('\n', ' ')),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Text(
              '${value.text.length}/${AppConstants.maxCaptionLength}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
