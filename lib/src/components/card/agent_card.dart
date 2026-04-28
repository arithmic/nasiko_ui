import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A compact card for displaying an agent or an agent-like entry.
///
/// Distinct from [NasikoCard]: optimised for agent listings with an optional
/// leading badge, a small version suffix next to the title, uppercase tag
/// chips, and a trailing three-dot menu for contextual actions.
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
  });

  /// The agent's name.
  final String title;

  /// Optional small text shown after the title (e.g. "v1.1.0").
  final String? version;

  /// Optional supporting line shown directly below the title.
  final String? subtitle;

  /// Optional icon at the top-left — useful for a verification/status badge.
  final HugeIconsType? leadingIcon;

  /// Colour of [leadingIcon]. Defaults to the theme's success foreground when
  /// unset (assuming a "verified" semantic). Override for other badges.
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

  /// Whether to render the three-dot menu slot at all. When `false`, the
  /// header has no menu button or disabled placeholder — useful on screens
  /// where no card actions exist (e.g. the add-agent picker).
  final bool showMore;

  /// When `true`, the card renders in a muted visual style, hover effects
  /// are suppressed, `onTap` is ignored, and the menu button (if any) is
  /// replaced by a non-interactive disabled three-dot icon.
  final bool disabled;

  /// When `true`, the card renders with a persistent "active" treatment —
  /// tinted background, accent border, and soft glow. Use in list+detail
  /// layouts to indicate which card is currently shown in the detail pane.
  final bool selected;

  /// Optional attribution line rendered below the description, e.g.
  /// "Author: DigitalOcean". Hidden when null or empty.
  final String? author;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Maximum width for the card.
  final double maxWidth;

  @override
  State<NasikoAgentCard> createState() => _NasikoAgentCardState();
}

class _NasikoAgentCardState extends State<NasikoAgentCard> {
  bool _isHovered = false;

  /// Guards against the row's onTap firing when the user clicks the popup
  /// menu trigger — pointer-down on the menu button precedes the tap event.
  bool _isMenuPointerDown = false;

  bool get _hasMenu =>
      widget.menuActions != null && widget.menuActions!.isNotEmpty;

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
    final showSelected = widget.selected && !widget.disabled;
    final accent = showSelected || showHover;

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
    final subtitleLeftIndent =
        widget.leadingIcon != null ? iconSizes.m + spacing.s8 : 0.0;

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
          child: Container(
            padding: EdgeInsets.all(spacing.s16),
            decoration: BoxDecoration(
              color: widget.disabled
                  ? Color.fromRGBO(248, 248, 248, 1)
                  : (accent ? colors.backgroundBase : Color.fromRGBO(248, 248, 248, 1)),
              borderRadius: BorderRadius.circular(radii.r4),
              border: Border.all(
                color: widget.disabled
                    ? colors.borderDisabled
                    : (accent
                        ? colors.borderSecondary
                        : colors.borderPrimary),
                width: borderWidths.w1,
              ),
              boxShadow: accent
                  ? [
                      BoxShadow(
                        color: Color.fromRGBO(251, 240, 206, 1),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28,child: _buildHeader(colors, spacing, typography, iconSizes)),
                SizedBox(
                  height: subtitleReservedHeight,
                  child: Padding(
                    padding: EdgeInsets.only(left: subtitleLeftIndent),
                    child:
                        (widget.subtitle != null && widget.subtitle!.isNotEmpty)
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
                    accent,
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
                if (widget.author != null && widget.author!.isNotEmpty) ...[
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        if (widget.showMore)
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
    );
  }

  Widget _buildTags(
    List<String> visibleTags,
    int overflowCount,
    bool accent,
    bool disabled,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

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
          Tooltip(
            message: widget.tags
                .skip(widget.maxVisibleTags)
                .map((t) => t.toUpperCase())
                .join(', '),
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 200),
            textStyle: typography.caption.copyWith(
              color: colors.foregroundConstantWhite,
              fontStyle: FontStyle.normal,
            ),
            decoration: BoxDecoration(
              color: colors.backgroundOverlay,
              borderRadius: BorderRadius.circular(radii.r8),

            ),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s8,
              vertical: spacing.s4,
            ),
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
