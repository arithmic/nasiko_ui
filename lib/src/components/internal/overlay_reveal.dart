// lib/src/components/internal/overlay_reveal.dart

import 'package:flutter/widgets.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Internal one-shot entrance animation for overlay/inline surfaces
/// (menus, banners, custom tooltips).
///
/// Fades the [child] in while sliding it from [slideFrom] to its resting
/// position using `context.motion.enter`. Paint-only (Opacity +
/// Transform.translate), so layout is identical before, during, and after
/// the animation settles.
///
/// Reduced-motion aware: when the platform requests disabled animations the
/// child is shown immediately with no transition.
///
/// Not exported from the package barrel — internal use only.
class NasikoOverlayReveal extends StatelessWidget {
  const NasikoOverlayReveal({
    super.key,
    required this.child,
    this.duration,
    this.slideFrom = const Offset(0, -4),
  });

  final Widget child;

  /// Defaults to `context.motion.base` when null.
  final Duration? duration;

  /// Starting offset in logical pixels; animates to [Offset.zero].
  final Offset slideFrom;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    final resolved = motion.resolve(context, duration ?? motion.base);
    if (resolved == Duration.zero) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: resolved,
      curve: motion.enter,
      child: child,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: slideFrom * (1 - t),
            child: child,
          ),
        );
      },
    );
  }
}
