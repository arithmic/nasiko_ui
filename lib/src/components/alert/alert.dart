// lib/src/components/alert/alert.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

// Structure: an inline icon + title + description callout with a neutral
// and a destructive variant, plus success/warning/info variants mapped onto
// the Nasiko feedback palette. Visuals, tokens, and motion follow the
// Nasiko design system.

/// Semantic variant of a [NasikoAlert], mapped onto the same feedback color
/// tokens used by [NasikoBadge] and [NasikoToast].
enum NasikoAlertVariant {
  /// Neutral callout — base background with the primary border.
  normal,

  /// Errors and destructive outcomes.
  destructive,

  /// Positive outcomes: saved, verified, completed.
  success,

  /// Cautionary notices: expiring, degraded, at-risk.
  warning,

  /// Informational notices: tips, version notes.
  info,
}

/// An inline callout with an icon, title, and optional description.
///
/// Not to be confused with [NasikoBanner]: a banner is a page-level
/// announcement — elevated, entrance-animated, and built around a required
/// action — while an alert sits inline within content, is status-colored,
/// carries no action, and is non-dismissable by default.
///
/// Provide [onDismiss] to show a close button; dismissal collapses the alert
/// in place (height + fade at `motion.base`, reduced-motion aware) before
/// invoking the callback. There are deliberately no shake or other
/// attention effects — alerts inform; they don't nag.
///
/// ```dart
/// NasikoAlert.warning(
///   title: 'Certificate expiring',
///   description: 'Renew before June 30 to avoid downtime.',
/// )
/// ```
class NasikoAlert extends StatefulWidget {
  /// Creates a neutral alert.
  const NasikoAlert({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.variant = NasikoAlertVariant.normal,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
  });

  /// Creates a destructive alert (errors, destructive outcomes).
  const NasikoAlert.destructive({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
  }) : variant = NasikoAlertVariant.destructive;

  /// Creates a success alert.
  const NasikoAlert.success({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
  }) : variant = NasikoAlertVariant.success;

  /// Creates a warning alert.
  const NasikoAlert.warning({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
  }) : variant = NasikoAlertVariant.warning;

  /// Creates an informational alert.
  const NasikoAlert.info({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
  }) : variant = NasikoAlertVariant.info;

  /// The one-line heading of the alert.
  final String title;

  /// Optional supporting copy under the title.
  final String? description;

  /// Leading icon; defaults to a variant-appropriate icon when null.
  final HugeIconsType? icon;

  /// The semantic variant driving the alert's palette.
  final NasikoAlertVariant variant;

  /// When provided, shows a close button; called after the collapse
  /// animation completes so the caller can remove the alert from its tree.
  final VoidCallback? onDismiss;

  /// Accessibility label for the close button.
  final String dismissLabel;

  @override
  State<NasikoAlert> createState() => _NasikoAlertState();
}

class _NasikoAlertState extends State<NasikoAlert>
    with SingleTickerProviderStateMixin {
  /// Drives the reveal (1.0 = fully shown). Dismissal reverses it, shrinking
  /// the height and fading simultaneously (AppReveal-style collapse).
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    value: 1.0,
    // Placeholder; the token duration is applied in didChangeDependencies.
    duration: const Duration(milliseconds: 200),
  );

  CurvedAnimation? _curved;
  bool _dismissing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = context.motion;
    _reveal.duration = motion.resolve(context, motion.base);
    _curved?.dispose();
    // Exit curve: the collapse accelerates away, per the motion personality.
    _curved = CurvedAnimation(parent: _reveal, curve: motion.exit.flipped);
  }

  @override
  void dispose() {
    _curved?.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (_dismissing) return;
    _dismissing = true;
    final motion = context.motion;
    if (motion.resolve(context, motion.base) == Duration.zero) {
      // Reduced motion: collapse instantly and notify synchronously.
      _reveal.value = 0.0;
      widget.onDismiss?.call();
      return;
    }
    _reveal.reverse().whenComplete(() {
      if (mounted) widget.onDismiss?.call();
    });
  }

  HugeIconsType get _defaultIcon => switch (widget.variant) {
        NasikoAlertVariant.normal ||
        NasikoAlertVariant.info =>
          HugeIcons.strokeRoundedInformationCircle,
        NasikoAlertVariant.success => HugeIcons.strokeRoundedTick02,
        NasikoAlertVariant.warning ||
        NasikoAlertVariant.destructive =>
          HugeIcons.strokeRoundedAlert02,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;
    final typography = context.typography;

    // Variant palette — the same feedback tokens as NasikoBadge/NasikoToast.
    final (Color background, Color border, Color foreground) =
        switch (widget.variant) {
      NasikoAlertVariant.normal => (
          colors.backgroundBase,
          colors.borderPrimary,
          colors.foregroundPrimary,
        ),
      NasikoAlertVariant.destructive => (
          colors.backgroundError,
          colors.borderError,
          colors.foregroundError,
        ),
      NasikoAlertVariant.success => (
          colors.backgroundSuccess,
          colors.borderSuccess,
          colors.foregroundSuccess,
        ),
      NasikoAlertVariant.warning => (
          colors.backgroundWarning,
          colors.borderWarning,
          colors.foregroundWarning,
        ),
      NasikoAlertVariant.info => (
          colors.backgroundInformation,
          colors.borderInformation,
          colors.foregroundInformation,
        ),
    };
    final descriptionColor = widget.variant == NasikoAlertVariant.normal
        ? colors.foregroundSecondary
        : foreground;

    final content = Container(
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(color: border, width: borderWidths.w1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: widget.icon ?? _defaultIcon,
            size: context.iconSize.s,
            color: foreground,
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: typography.bodyPrimaryBold.copyWith(color: foreground),
                ),
                if (widget.description != null) ...[
                  SizedBox(height: spacing.s4),
                  Text(
                    widget.description!,
                    style: typography.bodySecondary.copyWith(
                      color: descriptionColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onDismiss != null) ...[
            SizedBox(width: spacing.s8),
            Semantics(
              label: widget.dismissLabel,
              child: TertiaryIconButton(
                size: NasikoButtonSize.small,
                icon: HugeIcons.strokeRoundedCancel01,
                onPressed: _handleDismiss,
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      child: FadeTransition(
        opacity: _curved ?? _reveal,
        child: SizeTransition(
          sizeFactor: _curved ?? _reveal,
          axisAlignment: -1.0,
          child: content,
        ),
      ),
    );
  }
}
