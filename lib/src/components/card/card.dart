import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A content card component that displays rich content with optional image,
/// title, tags, description, and action buttons.
///
/// The card supports two states:
/// - Enabled: Full color, interactive with action buttons (default)
/// - Disabled: Greyed out with a "Coming Soon" style button
///
/// Example usage for enabled card:
/// ```dart
/// NasikoCard(
///   title: 'Card Title',
///   iconButtonIcon: HugeIcons.strokeRoundedSettings01,
///   onIconButtonPressed: () {},
///   secondaryButtonLabel: 'Button',
///   onSecondaryPressed: () {},
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
  /// Creates an enabled card with action buttons.
  ///
  /// Either [iconButtonIcon] or [secondaryButtonLabel] should be provided for buttons to appear.
  const NasikoCard({
    super.key,
    this.image,
    this.badgeLabel,
    this.titleIcon,
    required this.title,
    this.tags = const [],
    this.subtitle,
    this.description,
    this.iconButtonIcon,
    this.onIconButtonPressed,
    this.secondaryButtonLabel,
    this.secondaryButtonIcon,
    this.secondaryButtonTrailingIcon,
    this.onSecondaryPressed,
    this.onTap,
    this.width,
  }) : enabled = true,
       disabledButtonLabel = null;

  /// Private internal constructor for disabled state
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
  }) : iconButtonIcon = null,
       onIconButtonPressed = null,
       secondaryButtonLabel = null,
       secondaryButtonIcon = null,
       secondaryButtonTrailingIcon = null,
       onSecondaryPressed = null,
       onTap = null;

  /// Creates a disabled card with a disabled button label.
  ///
  /// [disabledButtonLabel] is required for disabled cards.
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
    );
  }

  /// Optional image widget to display at the top of the card.
  final Widget? image;

  /// Optional badge label (e.g., "New") displayed in top-right corner of the image.
  final String? badgeLabel;

  /// Optional icon or image widget displayed before the title.
  /// Can be an Icon, Image.network, Image.asset, or any other widget.
  final List<List<dynamic>>? titleIcon;

  /// The main title text of the card.
  final String title;

  /// List of tag labels to display as chips.
  final List<String> tags;

  /// Optional subtitle text displayed below the tags.
  final String? subtitle;

  /// Optional description text displayed below the subtitle.
  final String? description;

  /// Optional leading icon for the icon button.
  /// Only available in enabled state.
  final List<List<dynamic>>? iconButtonIcon;

  /// Callback when the icon button is pressed.
  /// Only available in enabled state.
  final VoidCallback? onIconButtonPressed;

  /// Label for the secondary action button.
  /// Only available in enabled state.
  final String? secondaryButtonLabel;

  /// Optional leading icon for the secondary button.
  /// Only available in enabled state.
  final List<List<dynamic>>? secondaryButtonIcon;

  /// Optional trailing icon for the secondary button.
  /// Only available in enabled state.
  final List<List<dynamic>>? secondaryButtonTrailingIcon;

  /// Callback when the secondary button is pressed.
  /// Only available in enabled state.
  final VoidCallback? onSecondaryPressed;

  /// Label for the disabled state button (e.g., "Coming Soon").
  /// Only available in disabled state.
  final String? disabledButtonLabel;

  /// Whether the card is enabled. When false, the card appears greyed out.
  final bool enabled;

  /// Optional callback when the card itself is tapped.
  /// Only available in enabled state.
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
        color: widget.enabled
            ? colors.backgroundGroup
            : colors.foregroundConstantWhite,
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(
          color: widget.enabled
              ? _isHovered
                    ? colors.borderSecondary
                    : colors.borderPrimary
              : colors.borderDisabled,
          width: 1,
        ),
        boxShadow: _isHovered && widget.enabled
            ? [
                BoxShadow(
                  color: colors.foregroundConstantBlack.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
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
                _buildTitleRow(context, _isHovered),

                // Tags
                if (widget.tags.isNotEmpty) ...[
                  SizedBox(height: spacing.s16),
                  _buildTagsRow(context),
                ],

                // Subtitle
                if (widget.subtitle != null) ...[
                  SizedBox(height: spacing.s8),
                  _buildSubtitleRow(context),
                ],

                // Description
                if (widget.description != null &&
                    widget.description! != "") ...[
                  SizedBox(height: spacing.s8),
                  Text(
                    widget.description!,
                    style: typography.bodyTertiary.copyWith(
                      color: colors.foregroundPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  SizedBox(height: spacing.s4),
                  SizedBox(height: spacing.s36),
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
      widget.secondaryButtonLabel != null || widget.disabledButtonLabel != null;

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

  Widget _buildTitleRow(BuildContext context, bool isHovered) {
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
            child: HugeIcon(
              icon: widget.titleIcon!,
              color: isHovered
                  ? colors.foregroundIconSecondary
                  : colors.foregroundIconPrimary,
            ),
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Text(
            widget.title,
            style: typography.bodyPrimaryBold.copyWith(
              color: isHovered
                  ? colors.foregroundSecondary
                  : colors.foregroundPrimary,
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
                  child: NasikoChip(
                    label: tag,
                    enabled: widget.enabled,
                    size: NasikoChipSize.small,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSubtitleRow(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          widget.subtitle!,
          style: typography.bodyTertiaryBold.copyWith(
            color: colors.foregroundSecondary,
          ),
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

    // Show icon button and/or secondary button
    return Row(
      children: [
        if (widget.iconButtonIcon != null) ...[
          SecondaryIconButton(
            onPressed: widget.enabled ? widget.onIconButtonPressed : null,
            icon: widget.iconButtonIcon!,
            size: NasikoButtonSize.small,
          ),
          if (widget.secondaryButtonLabel != null) SizedBox(width: spacing.s8),
        ],
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
