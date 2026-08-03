import 'package:flutter/material.dart';

/// Motion tokens for the Nasiko design system.
///
/// Personality: subtle & fast — motion confirms state changes without ever
/// getting in the way. Entrances decelerate, exits accelerate, on-screen
/// movement is symmetric. Mirrors the app-side `AppMotion` scale so package
/// and app animation feel identical.
///
/// Access via `context.motion`:
/// ```dart
/// AnimatedContainer(
///   duration: context.motion.hover,
///   curve: context.motion.enter,
///   ...
/// )
/// ```
/// Reduced-motion convention: STRUCTURAL animations (things that move,
/// grow, or appear — expansions, entrances, thumb travel, press scale) must
/// pass their duration through `context.motion.resolve(context, d)` so they
/// disable under reduced motion. DECORATIVE hover/color fades may use the
/// raw tokens — they don't move content and are imperceptible as motion.
@immutable
class NasikoMotionTheme extends ThemeExtension<NasikoMotionTheme> {
  const NasikoMotionTheme({
    required this.pressed,
    required this.hover,
    required this.fast,
    required this.base,
    required this.panel,
    required this.page,
    required this.enter,
    required this.exit,
    required this.move,
    required this.emphasized,
  });

  /// Press feedback, instant-feel micro interactions. (100ms)
  final Duration pressed;

  /// Hover states. (120ms)
  final Duration hover;

  /// Small state changes: chevrons, checks, switch thumbs, ticks. (150ms)
  final Duration fast;

  /// Default enter/exit: menus, tooltips, dialogs, accordions. (200ms)
  final Duration base;

  /// Larger surfaces: panels, rails, expanding sections. (250ms)
  final Duration panel;

  /// Full-surface swaps and page-scale transitions. (300ms)
  final Duration page;

  /// Entrances — start fast, settle gently (decelerate).
  final Curve enter;

  /// Exits — accelerate away.
  final Curve exit;

  /// On-screen movement, resizing, thumb travel.
  final Curve move;

  /// Emphasized settle for the few moments that deserve presence.
  final Curve emphasized;

  /// Whether the platform requests animations to be disabled.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Returns [duration], or [Duration.zero] when reduced motion is on.
  Duration resolve(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;

  @override
  NasikoMotionTheme copyWith({
    Duration? pressed,
    Duration? hover,
    Duration? fast,
    Duration? base,
    Duration? panel,
    Duration? page,
    Curve? enter,
    Curve? exit,
    Curve? move,
    Curve? emphasized,
  }) {
    return NasikoMotionTheme(
      pressed: pressed ?? this.pressed,
      hover: hover ?? this.hover,
      fast: fast ?? this.fast,
      base: base ?? this.base,
      panel: panel ?? this.panel,
      page: page ?? this.page,
      enter: enter ?? this.enter,
      exit: exit ?? this.exit,
      move: move ?? this.move,
      emphasized: emphasized ?? this.emphasized,
    );
  }

  @override
  NasikoMotionTheme lerp(ThemeExtension<NasikoMotionTheme>? other, double t) {
    // Durations/curves are discrete tokens — snap rather than interpolate.
    if (other is! NasikoMotionTheme) return this;
    return t < 0.5 ? this : other;
  }
}

// --- Default Motion Instance ---
NasikoMotionTheme get defaultNasikoMotion => const NasikoMotionTheme(
      pressed: Duration(milliseconds: 100),
      hover: Duration(milliseconds: 120),
      fast: Duration(milliseconds: 150),
      base: Duration(milliseconds: 200),
      panel: Duration(milliseconds: 250),
      page: Duration(milliseconds: 300),
      enter: Curves.easeOutCubic,
      exit: Curves.easeInCubic,
      move: Curves.easeInOutCubic,
      emphasized: Cubic(0.2, 0.0, 0.0, 1.0),
    );

// --- BuildContext Extension ---
// Provides easy access like: `context.motion.base`
extension NasikoMotionThemeExtension on BuildContext {
  NasikoMotionTheme get motion =>
      Theme.of(this).extension<NasikoMotionTheme>() ?? defaultNasikoMotion;
}
