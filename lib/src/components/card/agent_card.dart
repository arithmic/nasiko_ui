import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Visual state variant of a [NasikoAgentCard].
///
/// Controls the left accent border colour and, for [error], the body layout.
enum NasikoAgentCardVariant {
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
/// - [NasikoAgentCardVariant.settingUp] — yellow accent; supply a yellow
///   [leadingIcon] + [leadingIconColor].
/// - [NasikoAgentCardVariant.active] — green accent; supply a green
///   [leadingIcon] + [leadingIconColor].
/// - [NasikoAgentCardVariant.error] — red accent; supply a warning
///   [leadingIcon] and the [errorTitle], [errorBody], [errorDetails],
///   [onRetry], and [onDelete] props.
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
    required this.variant,
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

  /// Optional supporting line shown directly below the title.
  final String? subtitle;

  /// Optional icon at the top-left — useful for a verification/status badge.
  final HugeIconsType? leadingIcon;

  /// Colour of [leadingIcon].
  ///
  /// Defaults to success green for [NasikoAgentCardVariant.active]; ignored for
  /// [NasikoAgentCardVariant.error] (always rendered in error red).
  final Color? leadingIconColor;

  /// Short description — clamps to 2 lines with ellipsis.
  final String? description;

  /// Tag strings rendered as uppercase chips. Tags beyond [maxVisibleTags]
  /// are collapsed into a single "+N" chip.
  final List<String> tags;

  /// Maximum number of tag chips rendered before the "+N" overflow chip.
  final int maxVisibleTags;

  /// When non-empty, a three-dot menu appears at the top-right on hover or
  /// when the card is selected/focused.
  final List<SectionItemAction>? menuActions;

  /// Whether to render the three-dot menu slot at all. Ignored when
  /// [variant] is [NasikoAgentCardVariant.error] (retry/delete shown instead).
  final bool showMore;

  /// When `true`, the card renders in a muted visual style, hover effects
  /// are suppressed, `onTap` is ignored, and the menu button (if any) is
  /// replaced by a non-interactive disabled three-dot icon.
  final bool disabled;

  /// When `true`, the card shows the yellow hover background persistently.
  final bool selected;

  /// Optional attribution line rendered below the description.
  final String? author;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Maximum width for the card.
  final double maxWidth;

  /// Card state variant — controls the left accent colour and body layout.
  final NasikoAgentCardVariant variant;

  /// Bold error headline shown in the error body.
  /// Only rendered when [variant] is [NasikoAgentCardVariant.error].
  final String? errorTitle;

  /// Secondary error description shown below [errorTitle].
  /// Only rendered when [variant] is [NasikoAgentCardVariant.error].
  final String? errorBody;

  /// Tooltip text revealed when hovering "Know more".
  /// Only used when [variant] is [NasikoAgentCardVariant.error].
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

  /// Guards against the row's onTap firing when the user clicks the popup
  /// menu trigger.
  bool _isMenuPointerDown = false;

  bool get _hasMenu =>
      widget.menuActions != null && widget.menuActions!.isNotEmpty;

  bool get _isError => widget.variant == NasikoAgentCardVariant.error;

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

    final showHover = _isHovered && !widget.disabled;
    final showYellowBg = showHover || widget.selected;

    // Left accent bar colour — null means no accent bar.
    final Color? accentColor = widget.disabled
        ? null
        : switch (widget.variant) {
            NasikoAgentCardVariant.settingUp => colors.borderHover,
            NasikoAgentCardVariant.active => colors.borderSuccess,
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

    final subtitleStyle = typography.bodyTertiaryBold.copyWith(
      color: widget.disabled
          ? colors.foregroundDisabled
          : colors.foregroundSecondary,
    );
    final subtitleReservedHeight =
        (subtitleStyle.height ?? 1.2) * subtitleStyle.fontSize!;
    final subtitleLeftIndent = widget.leadingIcon != null
        ? iconSizes.m + spacing.s8
        : 0.0;

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
                      height: 28,
                      child: _buildHeader(
                        colors,
                        spacing,
                        typography,
                        iconSizes,
                      ),
                    ),
                    if (!_isError) ...[
                      SizedBox(
                        height: subtitleReservedHeight,
                        child: Padding(
                          padding: EdgeInsets.only(left: subtitleLeftIndent),
                          child:
                              (widget.subtitle != null &&
                                  widget.subtitle!.isNotEmpty)
                              ? Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: subtitleStyle,
                                )
                              : null,
                        ),
                      ),
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
                      _buildErrorBody(colors, spacing, typography),
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
        // Error variant: retry + delete icon buttons replace the 3-dot menu.
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.s8),
        if (widget.errorTitle != null)
          Text(
            widget.errorTitle!,
            style: typography.bodySecondaryBold.copyWith(
              color: colors.foregroundError,
            ),
          ),
        if (widget.errorBody != null) ...[
          SizedBox(height: spacing.s4),
          Text(
            widget.errorBody!,
            style: typography.bodySecondary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ],
        if (widget.errorDetails != null) ...[
          SizedBox(height: spacing.s8),
          NasikoTooltip(
            message: widget.errorDetails!,
            preferBelow: true,
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
