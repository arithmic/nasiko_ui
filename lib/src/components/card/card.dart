import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A content card component that displays rich content with optional image,
/// title, tags, description, and action button.
///
/// The card supports two states:
/// - Enabled: Full color, interactive and clickable (default)
/// - Disabled: Greyed out with a "Coming Soon" style button
///
/// The entire card is clickable when [onPressed] is provided.
///
/// Example usage for enabled card with clickable card:
/// ```dart
/// NasikoCard(
///   title: 'Card Title',
///   secondaryButtonLabel: 'View Details',
///   onSecondaryPressed: () {},
///   onPressed: () {}, // Makes the entire card clickable
/// )
/// ```
///
/// Example usage for disabled card:
/// ```dart
/// NasikoCard.disabled(
///   title: 'Card Title',
///   disabledButtonLabel: 'Coming Soon',
/// )
/// ```
class NasikoCard extends StatefulWidget {
  const NasikoCard({
    super.key,
    this.image,
    this.badgeLabel,
    this.titleIcon,
    required this.title,
    this.tags = const [],
    this.subtitle,
    this.description,
    this.secondaryButtonLabel,
    this.secondaryButtonIcon,
    this.secondaryButtonTrailingIcon,
    this.onSecondaryPressed,
    this.onPressed,
    this.width,
    this.maxWidth = 420,
  }) : enabled = true,
       disabledButtonLabel = null;

  const NasikoCard._internal({
    super.key,
    this.image,
    this.badgeLabel,
    this.titleIcon,
    required this.title,
    this.tags = const [],
    this.subtitle,
    this.description,
    required this.disabledButtonLabel,
    required this.enabled,
    this.width,
    this.maxWidth = 420,
  }) : secondaryButtonLabel = null,
       secondaryButtonIcon = null,
       secondaryButtonTrailingIcon = null,
       onSecondaryPressed = null,
       onPressed = null;

  factory NasikoCard.disabled({
    Key? key,
    Widget? image,
    String? badgeLabel,
    List<List<dynamic>>? titleIcon,
    required String title,
    List<String> tags = const [],
    String? subtitle,
    String? description,
    required String disabledButtonLabel,
    double? width,
    double maxWidth = 420,
  }) {
    return NasikoCard._internal(
      key: key,
      image: image,
      badgeLabel: badgeLabel,
      titleIcon: titleIcon,
      title: title,
      tags: tags,
      subtitle: subtitle,
      description: description,
      disabledButtonLabel: disabledButtonLabel,
      enabled: false,
      width: width,
      maxWidth: maxWidth,
    );
  }

  final Widget? image;
  final String? badgeLabel;
  final List<List<dynamic>>? titleIcon;
  final String title;
  final List<String> tags;
  final String? subtitle;
  final String? description;

  final String? secondaryButtonLabel;
  final List<List<dynamic>>? secondaryButtonIcon;
  final List<List<dynamic>>? secondaryButtonTrailingIcon;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPressed;

  final String? disabledButtonLabel;
  final bool enabled;

  final double? width;
  final double maxWidth;

  @override
  State<NasikoCard> createState() => _NasikoCardState();
}

class _NasikoCardState extends State<NasikoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;

    Widget card = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width ?? widget.maxWidth),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: spacing.s20),
        decoration: BoxDecoration(
          color: widget.enabled
              ? colors.backgroundGroup
              : colors.foregroundConstantWhite,
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(
            color: !widget.enabled
                ? colors.borderDisabled
                : _hovered
                ? colors.borderSecondary
                : colors.borderPrimary,
          ),
          boxShadow: _hovered && widget.enabled
              ? [
                  BoxShadow(
                    color: colors.foregroundConstantBlack.withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: _buildContent(context),
      ),
    );

    return MouseRegion(
      cursor: widget.onPressed != null && widget.enabled
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.onPressed != null && widget.enabled
          ? GestureDetector(onTap: widget.onPressed, child: card)
          : card,
    );
  }

  Widget _buildContent(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min, // CRITICAL for grid safety
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.image != null) _buildImage(context),
        _buildTitle(context),

        if (widget.tags.isNotEmpty) ...[
          SizedBox(height: spacing.s16),
          _buildTags(context),
        ],

        if (widget.subtitle != null) ...[
          SizedBox(height: spacing.s8),
          _buildSubtitle(context),
        ],

        if (widget.description?.isNotEmpty == true) ...[
          SizedBox(height: spacing.s8),
          _buildDescription(context),
        ],

        if (_hasButtons) ...[
          SizedBox(height: spacing.s16),
          _buildButtons(context),
        ],
      ],
    );
  }

  bool get _hasButtons =>
      widget.secondaryButtonLabel != null || widget.disabledButtonLabel != null;

  Widget _buildImage(BuildContext context) {
    final spacing = context.spacing;
    final radii = context.radius;
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.all(spacing.s12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radii.r8),
            child: AspectRatio(aspectRatio: 16 / 9, child: widget.image),
          ),
          if (widget.badgeLabel != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(spacing.s8),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? colors.backgroundBrand
                      : colors.backgroundDisabled,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(radii.r8),
                    bottomLeft: Radius.circular(radii.r8),
                  ),
                ),
                child: Text(
                  widget.badgeLabel!,
                  style: typography.bodyTertiaryBold.copyWith(
                    color: widget.enabled
                        ? colors.foregroundOnAction
                        : colors.foregroundDisabled,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;
    final iconSizes = context.iconSize;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s20),
      child: Row(
        children: [
          if (widget.titleIcon != null) ...[
            SizedBox(
              width: iconSizes.m,
              height: iconSizes.m,
              child: HugeIcon(
                icon: widget.titleIcon!,
                color: _hovered
                    ? colors.foregroundIconSecondary
                    : colors.foregroundIconPrimary,
              ),
            ),
            SizedBox(width: spacing.s16),
          ],
          Expanded(
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.bodyPrimaryBold.copyWith(
                color: !widget.enabled
                    ? colors.foregroundDisabled
                    : _hovered
                    ? colors.foregroundBrand
                    : colors.foregroundPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: spacing.s20),
      child: Row(
        children: widget.tags
            .map(
              (tag) => Padding(
                padding: EdgeInsets.only(right: spacing.s8),
                child: NasikoChip(
                  label: tag,
                  enabled: widget.enabled,
                  size: NasikoChipSize.small,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s20),
      child: Text(
        widget.subtitle!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: typography.bodyTertiaryBold.copyWith(
          color: widget.enabled
              ? colors.foregroundSecondary
              : colors.foregroundDisabled,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: spacing.s20),
      child: Text(
        widget.description!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: typography.bodySecondary.copyWith(
          color: widget.enabled
              ? colors.foregroundPrimary
              : colors.foregroundDisabled,
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final spacing = context.spacing;

    if (!widget.enabled && widget.disabledButtonLabel != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.s20),
        child: SizedBox(
          width: double.infinity, // 🔑 forces full width
          child: PrimaryButton(
            onPressed: null,
            label: widget.disabledButtonLabel!,
            size: NasikoButtonSize.small,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s20),
      child: SizedBox(
        width: double.infinity, // 🔑 forces full width
        child: SecondaryButton(
          onPressed: widget.onSecondaryPressed,
          label: widget.secondaryButtonLabel!,
          leadingIcon: widget.secondaryButtonIcon,
          trailingIcon: widget.secondaryButtonTrailingIcon,
          size: NasikoButtonSize.small,
        ),
      ),
    );
  }
}
