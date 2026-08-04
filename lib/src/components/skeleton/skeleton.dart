// lib/src/components/skeleton/skeleton.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Period of one shimmer sweep. The motion theme intentionally has no
/// shimmer token — this is a skeleton-only rhythm, kept private here.
const Duration _shimmerPeriod = Duration(milliseconds: 1300);

/// Drives a single shared shimmer sweep across every [NasikoSkeletonBlock]
/// (or arbitrary skeleton painting) below it, using one shared ticker.
///
/// Usage:
/// ```dart
/// NasikoSkeletonScope(
///   child: Column(children: [
///     NasikoSkeletonBlock(width: 120, height: 16),
///     …
///   ]),
/// )
/// ```
/// Reduced-motion aware: when the platform requests disabled animations the
/// sweep stops and skeletons render as static surface-colored blocks.
///
/// The whole scope is wrapped in [ExcludeSemantics] — skeletons are pure
/// decoration. Hosts must provide their own loading announcement (e.g. a
/// `Semantics(label: 'Loading …')` on the surrounding surface).
class NasikoSkeletonScope extends StatefulWidget {
  const NasikoSkeletonScope({super.key, required this.child});

  /// The skeleton layout swept by the shared gradient.
  final Widget child;

  @override
  State<NasikoSkeletonScope> createState() => _NasikoSkeletonScopeState();
}

class _NasikoSkeletonScopeState extends State<NasikoSkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _shimmerPeriod);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect reduced motion: show static skeletons instead of the sweep.
    if (NasikoMotionTheme.reduceMotion(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.colors.backgroundSurface;
    final highlightColor = context.colors.backgroundSurfaceHover;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final slide = _controller.value * 2.8 - 1.4;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  baseColor,
                  baseColor,
                  highlightColor,
                  baseColor,
                  baseColor,
                ],
                stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
                begin: Alignment(-1.0 + slide, 0),
                end: Alignment(1.0 + slide, 0),
              ).createShader(bounds);
            },
            child: child,
          );
        },
      ),
    );
  }
}

/// A skeleton placeholder block. Inside a [NasikoSkeletonScope] it shimmers;
/// on its own it renders as a static surface-colored block.
class NasikoSkeletonBlock extends StatelessWidget {
  const NasikoSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius,
  });

  /// Block width; `null` expands to the parent's constraints.
  final double? width;

  /// Block height.
  final double height;

  /// Corner radius. Defaults to `context.radius.r4`.
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.backgroundSurface,
        borderRadius: radius ?? BorderRadius.circular(context.radius.r4),
      ),
    );
  }
}
