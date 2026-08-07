import 'package:flutter/material.dart';

/// Elevation (shadow) tokens for the Nasiko design system.
///
/// Access via `context.elevation`:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: context.colors.backgroundSurface,
///     boxShadow: context.elevation.overlay,
///   ),
/// )
/// ```
///
/// Three levels:
/// * [low] — resting cards, banners, subtle lift.
/// * [overlay] — floating surfaces: menus, popovers, comboboxes, hover
///   cards, command palettes.
/// * [modal] — dialogs, sheets, and anything above a scrim.
///
/// Theme behavior: the light theme uses warm-tinted shadows (derived from
/// the sand ramp's dark end rather than pure black, so shadows don't read
/// cold against the warm surfaces). The dark theme keeps shadows minimal —
/// black shadows are nearly invisible on the near-black canvas, so dark
/// elevation is carried primarily by the surface ramp
/// (`sandDark950 → 800`); the faint shadows here only add edge definition
/// to floating surfaces.
@immutable
class NasikoElevationTheme extends ThemeExtension<NasikoElevationTheme> {
  const NasikoElevationTheme({
    required this.low,
    required this.overlay,
    required this.modal,
  });

  /// Resting lift: cards, banners.
  final List<BoxShadow> low;

  /// Floating surfaces: menus, popovers, dropdowns, hover cards.
  final List<BoxShadow> overlay;

  /// Modal surfaces: dialogs, sheets.
  final List<BoxShadow> modal;

  /// Warm-shadow light theme. The shadow color is sand800 (#3A3430) — the
  /// warm dark end of the neutral ramp — instead of pure black.
  factory NasikoElevationTheme.light() {
    const Color shadow = Color(0xFF3A3430);
    return NasikoElevationTheme(
      low: [
        BoxShadow(
          color: shadow.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      overlay: [
        BoxShadow(
          color: shadow.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      modal: [
        BoxShadow(
          color: shadow.withValues(alpha: 0.16),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  /// Minimal-shadow dark theme: the surface ramp carries elevation; these
  /// only sharpen the edge of floating surfaces against nearby content.
  factory NasikoElevationTheme.dark() {
    return NasikoElevationTheme(
      low: const [],
      overlay: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      modal: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  @override
  NasikoElevationTheme copyWith({
    List<BoxShadow>? low,
    List<BoxShadow>? overlay,
    List<BoxShadow>? modal,
  }) {
    return NasikoElevationTheme(
      low: low ?? this.low,
      overlay: overlay ?? this.overlay,
      modal: modal ?? this.modal,
    );
  }

  @override
  NasikoElevationTheme lerp(
    ThemeExtension<NasikoElevationTheme>? other,
    double t,
  ) {
    if (other is! NasikoElevationTheme) {
      return this;
    }
    return NasikoElevationTheme(
      low: BoxShadow.lerpList(low, other.low, t) ?? low,
      overlay: BoxShadow.lerpList(overlay, other.overlay, t) ?? overlay,
      modal: BoxShadow.lerpList(modal, other.modal, t) ?? modal,
    );
  }
}

/// Provides easy access like: `context.elevation.overlay`.
extension NasikoElevationThemeExtension on BuildContext {
  NasikoElevationTheme get elevation =>
      Theme.of(this).extension<NasikoElevationTheme>()!;
}
