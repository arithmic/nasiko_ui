import 'package:flutter/material.dart';

import 'scale.dart';

/// Single source of truth for icon stroke weight.
///
/// `icon/stroke-width` = 1 (-> `scale/1`). This token only *defines* the
/// value; binding it onto individual icon instances is handled in the icon
/// system pass (DESIGN-8), since the underlying glyph library is read-only
/// here and requires an instance-level override.
@immutable
class NasikoIconStrokeWidthTheme
    extends ThemeExtension<NasikoIconStrokeWidthTheme> {
  const NasikoIconStrokeWidthTheme({required this.width});

  /// Stroke weight applied to icons, in logical pixels.
  final double width;

  @override
  NasikoIconStrokeWidthTheme copyWith({double? width}) {
    return NasikoIconStrokeWidthTheme(width: width ?? this.width);
  }

  @override
  NasikoIconStrokeWidthTheme lerp(
    ThemeExtension<NasikoIconStrokeWidthTheme>? other,
    double t,
  ) {
    if (other is! NasikoIconStrokeWidthTheme) {
      return this;
    }
    return NasikoIconStrokeWidthTheme(width: width + (other.width - width) * t);
  }
}

// --- Default Icon Stroke Width Instance ---
const NasikoIconStrokeWidthTheme defaultNasikoIconStrokeWidth =
    NasikoIconStrokeWidthTheme(width: scale1);

// --- BuildContext Extension ---
// Provides easy access like: `context.iconStrokeWidth.width`
extension NasikoIconStrokeWidthThemeExtension on BuildContext {
  NasikoIconStrokeWidthTheme get iconStrokeWidth =>
      Theme.of(this).extension<NasikoIconStrokeWidthTheme>()!;
}
