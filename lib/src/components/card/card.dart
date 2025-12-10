import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/components/buttons/button_size.dart';
import 'package:nasiko_ui/src/components/buttons/primary_button.dart';
import 'package:nasiko_ui/src/components/buttons/secondary_button.dart';
import 'package:nasiko_ui/src/components/chip/chip.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A content card component that displays rich content with optional image,
/// title, tags, description, and action buttons.
///
/// The card supports three states:
/// - Default: Full color, interactive
/// - Hover: Slightly elevated appearance
/// - Disabled: Greyed out with a "Coming Soon" style button
///
/// Example usage:
/// \`\`\`dart
/// NasikoCard(
///   image: Image.network('https://example.com/image.jpg'),
///   badgeLabel: 'New',
///   titleIcon: Icon(Icons.settings), // or Image.network() or Image.asset()
///   title: 'Card Title',
///   tags: ['Tag 1', 'Tag 2', 'Tag 3'],
///   subtitle: 'This is a good card.',
///   description: 'Accepted Input: URL of a public GitHub repository',
///   primaryButtonLabel: 'Button',
///   secondaryButtonLabel: 'Button',
///   onPrimaryPressed: () {},
///   onSecondaryPressed: () {},
/// )
/// \`\`\`
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
    this.primaryButtonLabel,
    this.primaryButtonIcon,
    this.primaryButtonTrailingIcon,
    this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.secondaryButtonIcon,
    this.secondaryButtonTrailingIcon,
    this.onSecondaryPressed,
    this.disabledButtonLabel,
    this.enabled = true,
    this.onTap,
    this.width,
  });

  /// Optional image widget to display at the top of the card.
  final Widget? image;

  /// Optional badge label (e.g., "New") displayed in top-right corner of the image.
  final String? badgeLabel;

  /// Optional icon or image widget displayed before the title.
  /// Can be an Icon, Image.network, Image.asset, or any other widget.
  final Widget? titleIcon;

  /// The main title text of the card.
  final String title;

  /// List of tag labels to display as chips.
  final List<String> tags;

  /// Optional subtitle text displayed below the tags.
  final String? subtitle;

  /// Optional description text displayed below the subtitle.
  final String? description;

  /// Label for the primary action button.
  final String? primaryButtonLabel;

  /// Optional leading icon for the primary button.
  final IconData? primaryButtonIcon;

  /// Optional trailing icon for the primary button.
  final IconData? primaryButtonTrailingIcon;

  /// Callback when the primary button is pressed.
  final VoidCallback? onPrimaryPressed;

  /// Label for the secondary action button.
  final String? secondaryButtonLabel;

  /// Optional leading icon for the secondary button.
  final IconData? secondaryButtonIcon;

  /// Optional trailing icon for the secondary button.
  final IconData? secondaryButtonTrailingIcon;

  /// Callback when the secondary button is pressed.
  final VoidCallback? onSecondaryPressed;

  /// Label for the disabled state button (e.g., "Coming Soon").
  final String? disabledButtonLabel;

  /// Whether the card is enabled. When false, the card appears greyed out.
  final bool enabled;

  /// Optional callback when the card itself is tapped.
  final VoidCallback? onTap;

  /// Optional fixed width for the card. If null, the card expands to fit its parent.
  final double? width;

  @override
  State<NasikoCard> createState() => _NasikoCardState();
}

class _NasikoCardState extends State<NasikoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;

    // Determine opacity based on enabled and hover state
    final double contentOpacity = widget.enabled ? 1.0 : 0.5;

    Widget cardContent = Container(
      width: widget.width,
      padding: EdgeInsets.all(spacing.s20),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(
          color: _isHovered && widget.enabled
              ? colors.borderSecondary
              : colors.borderPrimary,
          width: 1,
        ),
        boxShadow: _isHovered && widget.enabled
            ? [
                BoxShadow(
                  color: colors.backgroundOverlay.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Opacity(
        opacity: contentOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Badge
            if (widget.image != null) _buildImageSection(context),

            // Content Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                _buildTitleRow(context),

                // Tags
                if (widget.tags.isNotEmpty) ...[
                  SizedBox(height: spacing.s16),
                  _buildTagsRow(context),
                ],

                // Subtitle
                if (widget.subtitle != null) ...[
                  SizedBox(height: spacing.s8),
                  Text(
                    widget.subtitle!,
                    style: typography.bodyTertiaryBold.copyWith(
                      color: colors.foregroundSecondary,
                    ),
                  ),
                ],

                // Description
                if (widget.description != null) ...[
                  SizedBox(height: spacing.s8),
                  Text(
                    widget.description!,
                    style: typography.bodyTertiary.copyWith(
                      color: colors.foregroundPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Action Buttons
                if (_hasActionButtons) ...[
                  SizedBox(height: spacing.s16),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Wrap with interaction handlers
    if (widget.onTap != null && widget.enabled) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: widget.onTap, child: cardContent),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: cardContent,
    );
  }

  bool get _hasActionButtons =>
      widget.primaryButtonLabel != null ||
      widget.secondaryButtonLabel != null ||
      widget.disabledButtonLabel != null;

  Widget _buildImageSection(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;

    return Padding(
      padding: EdgeInsets.all(spacing.s12),
      child: Stack(
        children: [
          // Image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(radii.r8),
            child: AspectRatio(aspectRatio: 16 / 9, child: widget.image),
          ),

          // Badge overlay
          if (widget.badgeLabel != null)
            Positioned(
              top: spacing.s8,
              right: spacing.s8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.s12,
                  vertical: spacing.s8,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? colors.backgroundBrand
                      : colors.backgroundDisabled,
                  borderRadius: BorderRadius.circular(radii.r4),
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

  Widget _buildTitleRow(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final spacing = context.spacing;

    return Row(
      children: [
        if (widget.titleIcon != null) ...[
          SizedBox(
            width: iconSizes.m,
            height: iconSizes.m,
            child: widget.titleIcon,
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Text(
            widget.title,
            style: typography.bodyPrimaryBold.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    final spacing = context.spacing;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.tags
              .map(
                (tag) => Padding(
                  padding: EdgeInsets.only(right: spacing.s8),
                  child: NasikoChip(label: tag, enabled: widget.enabled),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final spacing = context.spacing;

    // If disabled with a disabled button label, show single disabled button
    if (!widget.enabled && widget.disabledButtonLabel != null) {
      return SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          onPressed: null,
          label: widget.disabledButtonLabel!,
          size: NasikoButtonSize.small,
        ),
      );
    }

    // Show primary and/or secondary buttons
    return Row(
      children: [
        if (widget.primaryButtonLabel != null)
          Expanded(
            child: PrimaryButton(
              onPressed: widget.enabled ? widget.onPrimaryPressed : null,
              label: widget.primaryButtonLabel!,
              leadingIcon: widget.primaryButtonIcon,
              trailingIcon: widget.primaryButtonTrailingIcon,
              size: NasikoButtonSize.small,
            ),
          ),
        if (widget.primaryButtonLabel != null &&
            widget.secondaryButtonLabel != null)
          SizedBox(width: spacing.s8),
        if (widget.secondaryButtonLabel != null)
          Expanded(
            child: SecondaryButton(
              onPressed: widget.enabled ? widget.onSecondaryPressed : null,
              label: widget.secondaryButtonLabel!,
              leadingIcon: widget.secondaryButtonIcon,
              trailingIcon: widget.secondaryButtonTrailingIcon,
              size: NasikoButtonSize.small,
            ),
          ),
      ],
    );
  }
}
