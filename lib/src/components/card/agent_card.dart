import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Visual state variant of a [NasikoAgentCard].
///
/// Controls the left accent border colour and, for [error], the body layout.
enum NasikoAgentCardVariant {
  /// Default — no left accent border.
  normal,

  /// Agent is being configured / deployed — yellow left accent.
  settingUp,

  /// Agent is live and healthy — green left accent.
  active,

  /// Agent failed to start — red left accent with error-specific body content.
  error,
}

/// A compact card for displaying an agent or an agent-like entry.
///
/// Distinct from [NasikoCard]: optimised for agent listings with an optional
/// leading badge, a small version suffix next to the title, uppercase tag
/// chips, and a trailing three-dot menu for contextual actions.
///
/// Set [variant] to control the left-accent colour and body layout:
/// - [NasikoAgentCardVariant.normal] — no accent (default).
/// - [NasikoAgentCardVariant.settingUp] — yellow accent.
/// - [NasikoAgentCardVariant.active] — green accent.
/// - [NasikoAgentCardVariant.error] — red accent; supply [errorBody],
///   [errorDetails], [onRetry], and [onDelete]. Title is always
///   "Agent upload failed!".
class NasikoAgentCard extends StatefulWidget {
  const NasikoAgentCard({
    super.key,
    required this.title,
    this.version,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconColor,
    this.description,
    this.tags = const [],
    this.maxVisibleTags = 2,
    this.menuActions,
    this.showMore = true,
    this.disabled = false,
    this.selected = false,
    this.author,
    this.onTap,
    this.maxWidth = double.infinity,
    this.variant = NasikoAgentCardVariant.normal,
    this.errorTitle,
    this.errorBody,
    this.errorDetails,
    this.onRetry,
    this.onDelete,
  });

  /// The agent's name.
  final String title;

  /// Optional small text shown after the title (e.g. "v1.1.0").
  final String? version;

  /// Optional supporting line shown directly below the title row.
  final String? subtitle;

  /// Optional icon at the top-left — useful for a verification/status badge.
  final HugeIconsType? leadingIcon;

  /// Colour of [leadingIcon]. Ignored for [NasikoAgentCardVariant.error]
  /// (always rendered in error red).
  final Color? leadingIconColor;

  /// Short description — clamps to 2 lines with ellipsis.
  final String? description;

  /// Tag strings rendered as uppercase chips. Tags beyond [maxVisibleTags]
  /// are collapsed into a single "+N" chip.
  final List<String> tags;

  /// Maximum number of tag chips rendered before the "+N" overflow chip.
  final int maxVisibleTags;

  /// When non-empty, a three-dot menu appears at the top-right.
  final List<SectionItemAction>? menuActions;

  /// Whether to render the three-dot menu slot at all. Ignored when
  /// [variant] is [NasikoAgentCardVariant.error].
  final bool showMore;

  /// When `true`, the card renders in a muted style and interactions are
  /// suppressed.
  final bool disabled;

  /// When `true`, the card shows the hover background persistently unless
  /// disabled or rendered as an error card.
  final bool selected;

  /// Optional attribution line rendered below the description.
  final String? author;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Maximum width for the card.
  final double maxWidth;

  /// Card state variant — controls the left accent colour and body layout.
  final NasikoAgentCardVariant variant;

  /// Bold headline shown at the top of the error body.
  /// Only rendered when [variant] is [NasikoAgentCardVariant.error].
  final String? errorTitle;

  /// Status message from the API shown as the error description.
  /// Only rendered when [variant] is [NasikoAgentCardVariant.error].
  final String? errorBody;

  /// Full error detail text shown in the click-triggered overlay when the user
  /// taps "Know more". Only used when [variant] is [NasikoAgentCardVariant.error].
  final String? errorDetails;

  /// Callback for the retry icon button in the error header.
  final VoidCallback? onRetry;

  /// Callback for the delete icon button in the error header.
  final VoidCallback? onDelete;

  @override
  State<NasikoAgentCard> createState() => _NasikoAgentCardState();
}

class _NasikoAgentCardState extends State<NasikoAgentCard> {
  bool _isHovered = false;
  bool _isMenuPointerDown = false;

  OverlayEntry? _errorDetailsOverlay;
  final GlobalKey _knowMoreKey = GlobalKey();

  bool get _hasMenu =>
      widget.menuActions != null && widget.menuActions!.isNotEmpty;

  bool get _isError => widget.variant == NasikoAgentCardVariant.error;

  @override
  void dispose() {
    _hideErrorDetails();
    super.dispose();
  }

  // ── Error-details click overlay ──────────────────────────────────────────────

  void _showErrorDetails() {
    if (_errorDetailsOverlay != null || widget.errorDetails == null) return;

    final renderBox =
        _knowMoreKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    // Position the bubble above "Know more", clamped to screen bounds.
    final bubbleLeft = min(max(8.0, offset.dx), screenWidth - 256.0);
    // bottom = distance from screen bottom to the top of "Know more" + gap
    final bubbleBottom = screenHeight - offset.dy + spacing.s8;

    _errorDetailsOverlay = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Full-screen barrier — tap anywhere outside to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hideErrorDetails,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          // Tooltip bubble — grows upward so its height doesn't matter.
          Positioned(
            left: bubbleLeft,
            bottom: bubbleBottom,
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Container(
                  padding: EdgeInsets.all(spacing.s8),
                  decoration: BoxDecoration(
                    color: colors.foregroundConstantBlack,
                    borderRadius: BorderRadius.circular(radii.r8),
                  ),
                  child: Text(
                    widget.errorDetails!,
                    style: typography.bodyTertiary.copyWith(
                      color: colors.foregroundConstantWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_errorDetailsOverlay!);
  }

  void _hideErrorDetails() {
    _errorDetailsOverlay?.remove();
    _errorDetailsOverlay = null;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final borderWidths = context.borderWidth;

    final visibleTags = widget.tags.take(widget.maxVisibleTags).toList();
    final overflowCount = widget.tags.length - visibleTags.length;

    final canShowHoverBg = !widget.disabled && !_isError;
    final showHover = _isHovered && canShowHoverBg;
    final showYellowBg = canShowHoverBg && (showHover || widget.selected);

    // Left accent bar colour — null means no accent bar.
    final Color? accentColor = widget.disabled
        ? null
        : switch (widget.variant) {
            NasikoAgentCardVariant.normal => null,
            NasikoAgentCardVariant.settingUp => colors.backgroundBrand,
            NasikoAgentCardVariant.active => colors.foregroundSuccess,
            NasikoAgentCardVariant.error => colors.borderError,
          };

    final bgColor = widget.disabled
        ? const Color.fromRGBO(248, 248, 248, 1)
        : showYellowBg
        ? colors.backgroundSecondaryBrand
        : const Color.fromRGBO(248, 248, 248, 1);

    final borderColor = widget.disabled
        ? colors.borderDisabled
        : colors.borderPrimary;

    final descriptionStyle = typography.bodySecondary.copyWith(
      color: widget.disabled
          ? colors.foregroundDisabled
          : colors.foregroundSecondary,
    );
    final descriptionReservedHeight =
        (descriptionStyle.height ?? 1.2) * descriptionStyle.fontSize! * 2;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: MouseRegion(
        cursor: widget.onTap != null && !widget.disabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (widget.onTap == null || widget.disabled)
              ? null
              : () {
                  if (_isMenuPointerDown) return;
                  widget.onTap!();
                },
          child: Stack(
            children: [
              // ── Card body ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(spacing.s16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(radii.r4),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidths.w1,
                  ),
                  boxShadow: showYellowBg
                      ? [
                          BoxShadow(
                            color: const Color.fromRGBO(251, 240, 206, 1),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      child: _buildHeader(
                        colors,
                        spacing,
                        typography,
                        iconSizes,
                      ),
                    ),
                    if (!_isError) ...[
                      if (widget.subtitle != null &&
                          widget.subtitle!.isNotEmpty) ...[
                        SizedBox(height: spacing.s4),
                        Padding(
                          padding: EdgeInsets.only(
                            left: widget.leadingIcon != null
                                ? iconSizes.m + spacing.s8
                                : 0.0,
                          ),
                          child: Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.bodyTertiaryBold.copyWith(
                              color: widget.disabled
                                  ? colors.foregroundDisabled
                                  : colors.foregroundSecondary,
                            ),
                          ),
                        ),
                      ],
                      if (widget.tags.isNotEmpty) ...[
                        SizedBox(height: spacing.s12),
                        _buildTags(
                          visibleTags,
                          overflowCount,
                          showYellowBg,
                          widget.disabled,
                        ),
                      ],
                      if (widget.description != null) ...[
                        SizedBox(height: spacing.s12),
                        SizedBox(
                          height: descriptionReservedHeight,
                          child: Text(
                            widget.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: descriptionStyle,
                          ),
                        ),
                      ],
                      if (widget.author != null &&
                          widget.author!.isNotEmpty) ...[
                        SizedBox(height: spacing.s8),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: typography.bodyTertiary.copyWith(
                              color: widget.disabled
                                  ? colors.foregroundDisabled
                                  : colors.foregroundSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Author : '),
                              TextSpan(
                                text: widget.author!,
                                style: typography.bodyTertiary.copyWith(
                                  color: widget.disabled
                                      ? colors.foregroundDisabled
                                      : colors.foregroundPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      _buildErrorBody(
                        colors,
                        spacing,
                        typography,
                        descriptionReservedHeight,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Left accent bar ────────────────────────────────────────
              if (accentColor != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radii.r4),
                      bottomLeft: Radius.circular(radii.r4),
                    ),
                    child: Container(
                      width: borderWidths.w4,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    NasikoColorTheme colors,
    NasikoSpacingTheme spacing,
    NasikoTypography typography,
    NasikoIconSizeTheme iconSizes,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          HugeIcon(
            icon: widget.leadingIcon!,
            size: iconSizes.m,
            color: widget.disabled
                ? colors.foregroundDisabled
                : _isError
                ? colors.foregroundError
                : (widget.leadingIconColor ?? colors.foregroundSuccess),
          ),
          SizedBox(width: spacing.s4),
        ],
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.s8,
            children: [
              Text(
                widget.title,
                style: typography.bodyPrimary.copyWith(
                  color: widget.disabled
                      ? colors.foregroundDisabled
                      : _isError
                      ? colors.foregroundSecondary
                      : colors.foregroundPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.version != null)
                Text(
                  widget.version!,
                  style: typography.bodyTertiary.copyWith(
                    color: widget.disabled
                        ? colors.foregroundDisabled
                        : colors.foregroundSecondary,
                  ),
                ),
            ],
          ),
        ),
        // Error variant: retry + delete replace the 3-dot menu.
        if (_isError) ...[
          if (widget.onRetry != null)
            _buildIconButton(
              icon: HugeIcons.strokeRoundedRefresh,
              color: colors.foregroundIconPrimary,
              onTap: widget.onRetry!,
              spacing: spacing,
              iconSizes: iconSizes,
            ),
          if (widget.onRetry != null && widget.onDelete != null)
            SizedBox(width: spacing.s4),
          if (widget.onDelete != null)
            _buildIconButton(
              icon: HugeIcons.strokeRoundedDelete01,
              color: colors.foregroundIconPrimary,
              onTap: widget.onDelete!,
              spacing: spacing,
              iconSizes: iconSizes,
            ),
        ] else if (widget.showMore) ...[
          (_hasMenu && !widget.disabled)
              ? Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _isMenuPointerDown = true,
                  onPointerUp: (_) => _isMenuPointerDown = false,
                  onPointerCancel: (_) => _isMenuPointerDown = false,
                  child: _AgentCardMenuButton(actions: widget.menuActions!),
                )
              : Padding(
                  padding: EdgeInsets.all(spacing.s2),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMoreVertical,
                    size: iconSizes.s,
                    color: colors.foregroundDisabled,
                  ),
                ),
        ],
      ],
    );
  }

  Widget _buildIconButton({
    required HugeIconsType icon,
    required Color color,
    required VoidCallback onTap,
    required NasikoSpacingTheme spacing,
    required NasikoIconSizeTheme iconSizes,
  }) {
    final radii = context.radius;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(spacing.s2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radii.r8),
          ),
          child: HugeIcon(icon: icon, size: iconSizes.s, color: color),
        ),
      ),
    );
  }

  // ── Error body ──────────────────────────────────────────────────────────────

  Widget _buildErrorBody(
    NasikoColorTheme colors,
    NasikoSpacingTheme spacing,
    NasikoTypography typography,
    double descriptionReservedHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.s12),
        if (widget.errorTitle != null)
          Text(
            widget.errorTitle!,
            style: typography.bodySecondaryBold.copyWith(
              color: colors.foregroundError,
            ),
          ),
        SizedBox(height: spacing.s4),
        // API status_message shown in a reserved 2-line area (matches
        // the description slot height in normal cards for visual height parity).
        SizedBox(
          height: descriptionReservedHeight,
          child: widget.errorBody != null
              ? Text(
                  widget.errorBody!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySecondary.copyWith(
                    color: colors.foregroundSecondary,
                  ),
                )
              : null,
        ),
        if (widget.errorDetails != null) ...[
          SizedBox(height: spacing.s8),
          GestureDetector(
            key: _knowMoreKey,
            onTap: _showErrorDetails,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'Know more',
                style: typography.bodySecondary.copyWith(
                  color: colors.foregroundPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.foregroundPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Tags ────────────────────────────────────────────────────────────────────

  Widget _buildTags(
    List<String> visibleTags,
    int overflowCount,
    bool accent,
    bool disabled,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Wrap(
      spacing: spacing.s8,
      runSpacing: spacing.s8,
      children: [
        for (final tag in visibleTags)
          NasikoChip(
            label: tag.toUpperCase(),
            size: NasikoChipSize.small,
            variant: NasikoChipVariant.neutral,
            enabled: !disabled,
            borderColor: accent ? colors.borderHover : colors.borderPrimary,
          ),
        if (overflowCount > 0)
          NasikoTooltip(
            message: widget.tags
                .skip(widget.maxVisibleTags)
                .map((t) => t.toUpperCase())
                .join(', '),
            preferBelow: false,
            child: NasikoChip(
              label: '+$overflowCount',
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.neutral,
              enabled: !disabled,
              borderColor: accent ? colors.borderHover : colors.borderPrimary,
            ),
          ),
      ],
    );
  }
}

// ── Menu button ──────────────────────────────────────────────────────────────

/// Three-dot popover trigger rendered at the end of a [NasikoAgentCard]
/// header.
class _AgentCardMenuButton extends StatelessWidget {
  const _AgentCardMenuButton({required this.actions});

  final List<SectionItemAction> actions;

  void _openMenu(BuildContext context) {
    NasikoPopover.show(
      context: context,
      anchorContext: context,
      items: [
        for (final action in actions)
          NasikoPopupMenuItemData(
            label: action.label,
            icon: action.icon,
            isDestructive: action.isDestructive,
          ),
      ],
      onSelect: (index) => actions[index].onTap(),
      width: 160,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final iconSizes = context.iconSize;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openMenu(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(spacing.s2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radii.r8),
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedMoreVertical,
            size: iconSizes.s,
            color: colors.foregroundIconPrimary,
          ),
        ),
      ),
    );
  }
}
