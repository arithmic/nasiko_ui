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
    this.onMenuActionSelected,
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

  /// Colour of [leadingIcon]. Defaults to [NasikoColorTheme.foregroundPrimary].
  /// Ignored for [NasikoAgentCardVariant.error] (always rendered in error red).
  final Color? leadingIconColor;

  /// Short description — clamps to 2 lines with ellipsis.
  final String? description;

  /// Tag strings rendered as uppercase chips. Tags beyond [maxVisibleTags]
  /// are collapsed into a single "+N" chip.
  final List<String> tags;

  /// Maximum number of tag chips rendered before the "+N" overflow chip.
  final int maxVisibleTags;

  /// When non-empty, a three-dot menu appears at the top-right.
  final List<NasikoPopupMenuItemData>? menuActions;

  /// Called with the index of the selected menu item when [menuActions] is set.
  final ValueChanged<int>? onMenuActionSelected;

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
  final LayerLink _knowMoreLayerLink = LayerLink();

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

    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

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
          // Follows "Know more" exactly — no manual coordinate math.
          CompositedTransformFollower(
            link: _knowMoreLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(0, spacing.s8),
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
            NasikoAgentCardVariant.error => colors.foregroundError,
          };

    final bgColor = widget.disabled || widget.errorDetails != null
        ? colors.backgroundBase
        : showYellowBg
        ? colors.backgroundSecondaryBrand
        : colors.backgroundGroup;

    final borderColor = widget.disabled || widget.errorDetails != null
        ? colors.borderDisabled
        : showYellowBg
        ? colors.borderSecondary
        : colors.borderPrimary;

    final descriptionStyle = typography.bodyTertiary.copyWith(
      color: widget.disabled
          ? colors.foregroundDisabled
          : colors.foregroundSecondary,
    );
    final descriptionReservedHeight =
        (descriptionStyle.height ?? 1.2) * descriptionStyle.fontSize! * 2;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: MouseRegion(
        cursor:
            widget.onTap != null &&
                !widget.disabled &&
                widget.errorDetails != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap:
              (widget.onTap == null ||
                  widget.disabled ||
                  widget.errorDetails != null)
              ? null
              : () {
                  if (_isMenuPointerDown) return;
                  widget.onTap!();
                },
          child: Stack(
            children: [
              // ── Card body ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(spacing.s20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(radii.r8),
                  border: Border.all(color: borderColor),
                  boxShadow: showYellowBg
                      ? [
                          BoxShadow(
                            color: colors.backgroundSecondaryBrand,
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
                      height: spacing.s36,
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
                        SizedBox(height: spacing.s16),
                        Text(
                          widget.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.bodyTertiaryBold.copyWith(
                            color:
                                widget.disabled || widget.errorDetails != null
                                ? colors.foregroundDisabled
                                : colors.foregroundPrimary,
                          ),
                        ),
                      ],
                      if (widget.tags.isNotEmpty) ...[
                        SizedBox(height: spacing.s16),
                        _buildTags(
                          showYellowBg,
                          widget.disabled || widget.errorDetails != null,
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
                        SizedBox(height: spacing.s12),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: typography.bodyTertiary.copyWith(
                              color:
                                  widget.disabled || widget.errorDetails != null
                                  ? colors.foregroundDisabled
                                  : colors.foregroundSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Author : '),
                              TextSpan(
                                text: widget.author!,
                                style: typography.bodyTertiaryBold.copyWith(
                                  color:
                                      widget.disabled ||
                                          widget.errorDetails != null
                                      ? colors.foregroundDisabled
                                      : colors.foregroundSecondary,
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
            size: iconSizes.s,
            color: widget.disabled
                ? colors.foregroundDisabled
                : _isError
                ? colors.foregroundError
                : (widget.leadingIconColor ?? colors.foregroundPrimary),
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.s8,
            children: [
              Text(
                widget.title,
                style: typography.bodyPrimaryBold.copyWith(
                  color:
                      widget.disabled || _isError || widget.errorDetails != null
                      ? colors.foregroundDisabled
                      : colors.foregroundPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.version != null)
                Text(
                  widget.version!,
                  style: typography.bodyTertiary.copyWith(
                    color: widget.disabled || widget.errorDetails != null
                        ? colors.foregroundDisabled
                        : colors.foregroundPrimary,
                  ),
                ),
            ],
          ),
        ),
        // Error variant: retry + delete replace the 3-dot menu.
        if (_isError) ...[
          if (widget.onRetry != null)
            PrimaryIconButton(
              icon: HugeIcons.strokeRoundedReload,
              onPressed: widget.onRetry!,
              size: NasikoButtonSize.small,
            ),
          if (widget.onRetry != null && widget.onDelete != null)
            SizedBox(width: spacing.s8),
          if (widget.onDelete != null)
            DestructiveIconButton(
              icon: HugeIcons.strokeRoundedDelete02,
              onPressed: widget.onDelete!,
              size: NasikoButtonSize.small,
            ),
        ] else if (widget.showMore) ...[
          (_hasMenu && !widget.disabled && widget.errorDetails == null)
              ? Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _isMenuPointerDown = true,
                  onPointerUp: (_) => _isMenuPointerDown = false,
                  onPointerCancel: (_) => _isMenuPointerDown = false,
                  child: _AgentCardMenuButton(
                    actions: widget.menuActions!,
                    onItemSelected: widget.onMenuActionSelected,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(spacing.s2),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMoreVertical,
                    size: iconSizes.m,
                    color: colors.foregroundDisabled,
                  ),
                ),
        ],
      ],
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
        SizedBox(height: spacing.s16),
        if (widget.errorTitle != null)
          Text(
            widget.errorTitle!,
            style: typography.bodySecondaryBold.copyWith(
              color: colors.foregroundError,
            ),
          ),
        SizedBox(height: spacing.s8),
        // API status_message shown in a reserved 2-line area (matches
        // the description slot height in normal cards for visual height parity).
        SizedBox(
          height: descriptionReservedHeight,
          child: widget.errorBody != null
              ? Text(
                  widget.errorBody!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyTertiary,
                )
              : Text(
                  "We couldn't start this agent due to a configuration issue.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyTertiary,
                ),
        ),
        if (widget.errorDetails != null) ...[
          CompositedTransformTarget(
            link: _knowMoreLayerLink,
            child: GestureDetector(
              onTap: _showErrorDetails,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'Know more',
                  style: typography.linkPrimary.copyWith(
                    color: colors.foregroundPrimary,
                    decorationColor: colors.foregroundPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Tags ────────────────────────────────────────────────────────────────────

  /// Measures how many tags from [widget.tags] fit in [availableWidth] as a
  /// single row, accounting for the "+N" overflow chip that must also fit when
  /// not all tags are shown.
  List<String> _fittingTags(double availableWidth) {
    final tags = widget.tags;
    if (tags.isEmpty) return [];

    final style = context.typography.bodyTertiary;
    final gap = context.spacing.s8;
    // Small chip: s8 horizontal padding on each side + 1px border on each side.
    final chipHPad = context.spacing.s8 * 2 + 2.0;

    double textWidth(String text) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width;
    }

    final chipWidths = tags
        .map((t) => chipHPad + textWidth(t.toUpperCase()))
        .toList();

    // Try fitting count tags (most → fewest). When count < total, a "+N" chip
    // must also fit on the same row.
    for (int count = tags.length; count >= 0; count--) {
      double total = chipWidths.take(count).fold(0.0, (a, b) => a + b);
      if (count > 1) total += gap * (count - 1);

      if (count < tags.length) {
        final overflowLabel = '+${tags.length - count}';
        final overflowWidth = chipHPad + textWidth(overflowLabel);
        total += (count > 0 ? gap : 0) + overflowWidth;
      }

      if (total <= availableWidth) return tags.sublist(0, count);
    }

    return [];
  }

  Widget _buildTags(bool accent, bool disabled) {
    final colors = context.colors;
    final spacing = context.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleTags = _fittingTags(constraints.maxWidth);
        final overflowCount = widget.tags.length - visibleTags.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < visibleTags.length; i++) ...[
              if (i > 0) SizedBox(width: spacing.s8),
              NasikoChip(
                label: visibleTags[i].toUpperCase(),
                size: NasikoChipSize.small,
                variant: NasikoChipVariant.base,
                shape: NasikoChipShape.rounded,
                enabled: !disabled,
                borderColor: accent
                    ? colors.borderSecondary
                    : colors.borderPrimary,
              ),
            ],
            if (overflowCount > 0) ...[
              if (visibleTags.isNotEmpty) SizedBox(width: spacing.s8),
              NasikoTooltip(
                message: widget.tags
                    .skip(visibleTags.length)
                    .map((t) => t.toUpperCase())
                    .join(', '),
                preferBelow: false,
                child: NasikoChip(
                  label: '+$overflowCount',
                  size: NasikoChipSize.small,
                  variant: NasikoChipVariant.base,
                  shape: NasikoChipShape.rounded,
                  enabled: !disabled,
                  borderColor: accent
                      ? colors.borderSecondary
                      : colors.borderPrimary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── Menu button ──────────────────────────────────────────────────────────────

/// Three-dot popover trigger rendered at the end of a [NasikoAgentCard]
/// header.
class _AgentCardMenuButton extends StatelessWidget {
  const _AgentCardMenuButton({required this.actions, this.onItemSelected});

  final List<NasikoPopupMenuItemData> actions;
  final ValueChanged<int>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    return NasikoPopupMenu(
      width: 160,
      items: actions,
      onItemSelected: (index) => onItemSelected?.call(index),
      child: TertiaryIconButton(
        icon: HugeIcons.strokeRoundedMoreVertical,
        onPressed: () {},
        size: NasikoButtonSize.small,
      ),
    );
  }
}
