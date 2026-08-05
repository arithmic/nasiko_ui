import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Standard scrollable page chrome: title, short description, sections.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.titlePrimary.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
          SizedBox(height: spacing.s8),
          Text(
            description,
            style: typography.bodySecondary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
          SizedBox(height: spacing.s24),
          ...children,
        ],
      ),
    );
  }
}

/// A titled section within a page ("Default", "Disabled", "Loading", ...).
class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.titleSecondary.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
          if (description != null) ...[
            SizedBox(height: spacing.s4),
            Text(
              description!,
              style: typography.bodyTertiary.copyWith(
                color: colors.foregroundSecondary,
              ),
            ),
          ],
          SizedBox(height: spacing.s12),
          child,
        ],
      ),
    );
  }
}

/// A small caption + example pair, for labelling individual states.
class LabeledExample extends StatelessWidget {
  const LabeledExample({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.caption.copyWith(
            color: colors.foregroundSecondary,
          ),
        ),
        SizedBox(height: spacing.s4),
        child,
      ],
    );
  }
}

/// Wraps [LabeledExample]s in a consistent wrap layout.
class ExampleWrap extends StatelessWidget {
  const ExampleWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Wrap(
      spacing: spacing.s24,
      runSpacing: spacing.s16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children,
    );
  }
}
