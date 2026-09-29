enum CaptionFont { sans, serif, mono, display }

enum CaptionSize { small, medium, large }

enum CaptionPosition { top, middle, bottom }

enum CaptionColor { white, black, purple, coral, sky }

enum CaptionBackground { none, box, glow }

class CaptionStyle {
  const CaptionStyle({
    this.font = CaptionFont.sans,
    this.size = CaptionSize.medium,
    this.position = CaptionPosition.bottom,
    this.color = CaptionColor.white,
    this.background = CaptionBackground.box,
  });

  final CaptionFont font;
  final CaptionSize size;
  final CaptionPosition position;
  final CaptionColor color;
  final CaptionBackground background;

  CaptionStyle copyWith({
    CaptionFont? font,
    CaptionSize? size,
    CaptionPosition? position,
    CaptionColor? color,
    CaptionBackground? background,
  }) {
    return CaptionStyle(
      font: font ?? this.font,
      size: size ?? this.size,
      position: position ?? this.position,
      color: color ?? this.color,
      background: background ?? this.background,
    );
  }
}
