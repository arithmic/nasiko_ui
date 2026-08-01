import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Visual state variant of a [NasikoCard].
///
/// Controls the left accent border colour and, for [error], the body layout.
enum NasikoCardVariant {
  /// Default — no left accent border.
  normal,

  /// Agent is being configured / deployed — yellow left accent.
  settingUp,

  /// Agent is live and healthy — green left accent.
  active,

  /// Agent failed to start — red left accent with error-specific body content.
  error,
}

/// A single tag rendered via [NasikoCard.tags] — e.g. a tool count or a
/// connection state — with an optional leading icon.
class NasikoCardTag {
  const NasikoCardTag(this.label, {this.icon});

  /// The tag's label. Rendered uppercase.
  final String label;

  /// Optional leading icon for this tag.
  final HugeIconsType? icon;
}

/// A compact card for displaying an agent or an agent-like entry.
///
/// Distinct from [NasikoCard]: optimised for agent listings with an optional
/// leading badge, a small version suffix next to the title, uppercase tag
/// chips, and a trailing three-dot menu for contextual actions.
///
/// Set [variant] to control the left-accent colour and body layout:
/// - [NasikoCardVariant.normal] — no accent (default).
/// - [NasikoCardVariant.settingUp] — yellow accent.
/// - [NasikoCardVariant.active] — green accent.
/// - [NasikoCardVariant.error] — red accent; supply [errorBody],
///   [errorDetails], [onRetry], and [onDelete].
class NasikoCard extends StatefulWidget {
  const NasikoCard({
    super.key,
    required this.title,
    this.version,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingWidget,
    this.titleBadge,
    this.description,
    this.tags = const [],
    this.maxVisibleTags = 2,
    this.menuActions,
    this.onMenuActionSelected,
    this.showMore = true,
    this.trailingWidget,
    this.disabled = false,
    this.selected = false,
    this.author,
    this.onTap,
    this.maxWidth = double.infinity,
    this.variant = NasikoCardVariant.normal,
    this.errorTitle,
    this.errorBody,
    this.errorDetails,
    this.onRetry,
    this.onDelete,
    this.settingUpTitle,
    this.settingUpBody,
    this.settingUpProgressListenable,
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
  /// Ignored for [NasikoCardVariant.error] (always rendered in error red).
  final Color? leadingIconColor;

  /// Custom widget rendered at the top-left instead of [leadingIcon] — e.g.
  /// a logo image. Takes priority over [leadingIcon] when both are set.
  final Widget? leadingWidget;

  /// Small widget rendered inline right after [title] — e.g. a verified
  /// checkmark icon. Sits before [version] in the header row.
  final Widget? titleBadge;

  /// Short description — clamps to 2 lines with ellipsis.
  final String? description;

  /// Tags rendered as uppercase chips, each with an optional leading icon.
  /// Tags beyond [maxVisibleTags] are collapsed into a single "+N" chip.
  final List<NasikoCardTag> tags;

  /// Maximum number of tag chips rendered before the "+N" overflow chip.
  final int maxVisibleTags;

  /// When non-empty, a three-dot menu appears at the top-right.
  final List<NasikoPopupMenuItemData>? menuActions;

  /// Called with the index of the selected menu item when [menuActions] is set.
  final ValueChanged<int>? onMenuActionSelected;

  /// Custom widget rendered at the top-right instead of the three-dot menu
  /// (or the error retry/delete controls) — e.g. a "connect" button. Takes
  /// priority over [menuActions] and the error/setting-up header actions.
  final Widget? trailingWidget;

  /// Whether to render the three-dot menu slot at all. Ignored when
  /// [variant] is [NasikoCardVariant.error].
  final bool showMore;

  /// When `true`, the card renders in a muted style and interactions are
  /// suppressed.
  final bool disabled;

  /// When `true`, the card shows the selected elevation persistently unless
  /// disabled or rendered as an error card.
  final bool selected;

  /// Optional attribution line rendered below the description.
  final String? author;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Maximum width for the card.
  final double maxWidth;

  /// Card state variant — controls the left accent colour and body layout.
  final NasikoCardVariant variant;

  /// Bold headline shown at the top of the error body.
  /// Only rendered when [variant] is [NasikoCardVariant.error].
  final String? errorTitle;

  /// Status message from the API shown as the error description.
  /// Only rendered when [variant] is [NasikoCardVariant.error].
  final String? errorBody;

  /// Full error detail text shown in the click-triggered overlay when the user
  /// taps "Know more". Only used when [variant] is [NasikoCardVariant.error].
  final String? errorDetails;

  /// Callback for the retry icon button in the error header.
  final VoidCallback? onRetry;

  /// Callback for the delete icon button in the error header.
  final VoidCallback? onDelete;

  /// Bold headline shown at the top of the setting-up body.
  /// Only rendered when [variant] is [NasikoCardVariant.settingUp]
  /// AND any of the setting-up props are provided.
  final String? settingUpTitle;

  /// Status description for the setting-up body.
  final String? settingUpBody;

  /// Drives the determinate progress bar that replaces the description
  /// slot for setting-up cards. When null the bar renders indeterminate.
  final ValueListenable<double>? settingUpProgressListenable;

  @override
  State<NasikoCard> createState() => _NasikoCardState();
}

class _NasikoCardState extends State<NasikoCard> {
  bool _isHovered = false;
  bool _isMenuPointerDown = false;

  OverlayEntry? _errorDetailsOverlay;
  final LayerLink _knowMoreLayerLink = LayerLink();

  // ── Computed state ─────────────────────────────────────────────────────────

  bool get _isError => widget.variant == NasikoCardVariant.error;

  bool get _hasMenu => widget.menuActions?.isNotEmpty == true;

  bool get _hasErrorDetails => widget.errorDetails != null;

  /// Muted appearance: disabled or carrying error-details overlay content.
  bool get _isMuted => widget.disabled || _hasErrorDetails;

  bool get _hasSettingUpBody =>
      widget.variant == NasikoCardVariant.settingUp &&
      (widget.settingUpTitle != null ||
          widget.settingUpBody != null ||
          widget.settingUpProgressListenable != null);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _hideErrorDetails();
    super.dispose();
  }

  // ── Error-details overlay ──────────────────────────────────────────────────

  void _showErrorDetails() {
    if (_errorDetailsOverlay != null || !_hasErrorDetails) return;

    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final typography = context.typography;

    _errorDetailsOverlay = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hideErrorDetails,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
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
                    style: typography.bodyPrimary.copyWith(
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    // Interaction state
    final bool canHover = widget.onTap != null && !widget.disabled && !_isError;
    final bool canSelect = !widget.disabled && !_isError;
    final bool showHover = _isHovered && canHover;
    final bool showSelected = widget.selected && canSelect;
    final bool showElevation = showHover || showSelected;

    // Accent bar colour — null suppresses the bar entirely.
    final Color? accentColor = widget.disabled
        ? null
        : switch (widget.variant) {
            NasikoCardVariant.normal => null,
            NasikoCardVariant.settingUp => colors.backgroundBrand,
            NasikoCardVariant.active => colors.foregroundSuccess,
            NasikoCardVariant.error => colors.foregroundError,
          };

    final borderColor = _isMuted
        ? colors.borderDisabled
        : _hasSettingUpBody
        ? colors.borderPrimary
        : (showHover || showSelected)
        ? colors.borderSecondary
        : colors.borderPrimary;

    final Gradient? settingUpGradient = _hasSettingUpBody
        ? const LinearGradient(
            begin: Alignment(1.00, 0.50),
            end: Alignment(0.00, 0.50),
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F2EC)],
          )
        : null;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: MouseRegion(
        cursor: canHover ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canHover
              ? () {
                  if (!_isMenuPointerDown) widget.onTap!();
                }
              : null,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.all(spacing.s20),
                decoration: BoxDecoration(
                  color: settingUpGradient == null
                      ? colors.backgroundBase
                      : null,
                  gradient: settingUpGradient,
                  borderRadius: BorderRadius.circular(radii.r8),
                  border: Border.all(color: borderColor),
                  boxShadow: showElevation
                      ? const [
                          BoxShadow(
                            color: Color(0x40BB8F06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing.s32, child: _buildHeader(context)),
                    if (_isError)
                      _buildErrorBody(context)
                    else if (_hasSettingUpBody)
                      _buildSettingUpBody(context)
                    else
                      _buildNormalBody(context),
                  ],
                ),
              ),
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leadingWidget != null) ...[
          widget.leadingWidget!,
          SizedBox(width: spacing.s8),
        ] else if (widget.leadingIcon != null) ...[
          HugeIcon(
            icon: widget.leadingIcon!,
            size: iconSizes.s,
            color: widget.disabled
                ? colors.foregroundDisabled
                : _isError
                ? colors.foregroundError
                : _hasSettingUpBody
                ? colors.backgroundBrand
                : (widget.leadingIconColor ?? colors.foregroundPrimary),
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.s12,
            children: [
              Text(
                widget.title,
                style: typography.bodyPrimaryBold.copyWith(
                  color: (_isMuted || _isError)
                      ? colors.foregroundDisabled
                      : colors.foregroundPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.titleBadge != null) widget.titleBadge!,
              if (widget.version != null)
                Text(
                  widget.version!,
                  style: typography.bodyPrimary.copyWith(
                    color: _isMuted
                        ? colors.foregroundDisabled
                        : colors.foregroundPrimary,
                  ),
                ),
            ],
          ),
        ),
        _buildHeaderActions(context),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final iconSizes = context.iconSize;

    if (widget.trailingWidget != null) {
      return widget.trailingWidget!;
    }

    if (_isError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.onRetry != null)
            PrimaryIconButton(
              icon: HugeIcons.strokeRoundedReload,
              onPressed: widget.onRetry!,
              size: NasikoButtonSize.medium,
            ),
          if (widget.onRetry != null && widget.onDelete != null)
            SizedBox(width: spacing.s8),
          if (widget.onDelete != null)
            DestructiveIconButton(
              icon: HugeIcons.strokeRoundedDelete02,
              onPressed: widget.onDelete!,
              size: NasikoButtonSize.medium,
            ),
        ],
      );
    }

    if (!widget.showMore || !_hasMenu || _hasSettingUpBody) {
      return const SizedBox.shrink();
    }

    if (!_isMuted) {
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _isMenuPointerDown = true,
        onPointerUp: (_) => _isMenuPointerDown = false,
        onPointerCancel: (_) => _isMenuPointerDown = false,
        child: _CardMenuButton(
          actions: widget.menuActions!,
          onItemSelected: widget.onMenuActionSelected,
        ),
      );
    }

    return HugeIcon(
      icon: HugeIcons.strokeRoundedMoreVertical,
      size: iconSizes.m,
      color: colors.foregroundDisabled,
    );
  }

  // ── Normal body ────────────────────────────────────────────────────────────

  Widget _buildNormalBody(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    final contentColor = _isMuted
        ? colors.foregroundDisabled
        : colors.foregroundPrimary;
    final subtleColor = _isMuted
        ? colors.foregroundDisabled
        : colors.foregroundSecondary;
    final descriptionStyle = typography.bodySecondary.copyWith(
      color: subtleColor,
    );
    final descriptionHeight =
        (descriptionStyle.height ?? 1.2) * descriptionStyle.fontSize! * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.subtitle?.isNotEmpty == true) ...[
          SizedBox(height: spacing.s16),
          Text(
            widget.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.bodyPrimaryBold.copyWith(color: contentColor),
          ),
        ],
        if (widget.tags.isNotEmpty) ...[
          SizedBox(height: spacing.s16),
          _buildTags(_isMuted),
        ],
        if (widget.description != null) ...[
          SizedBox(height: spacing.s12),
          SizedBox(
            height: descriptionHeight,
            child: Text(
              widget.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: descriptionStyle,
            ),
          ),
        ],
        if (widget.author?.isNotEmpty == true) ...[
          SizedBox(height: spacing.s12),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: typography.bodyPrimary.copyWith(color: subtleColor),
              children: [
                const TextSpan(text: 'Author : '),
                TextSpan(
                  text: widget.author!,
                  style: typography.bodyPrimaryBold.copyWith(
                    color: subtleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Error body ─────────────────────────────────────────────────────────────

  Widget _buildErrorBody(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    final descriptionStyle = typography.bodyPrimary;
    final descriptionHeight =
        (descriptionStyle.height ?? 1.2) * descriptionStyle.fontSize! * 2;

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
        SizedBox(
          height: descriptionHeight,
          child: Text(
            widget.errorBody ??
                "We couldn't start this agent due to a configuration issue.",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
          ),
        ),
        if (_hasErrorDetails)
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
    );
  }

  // ── Setting-up body ────────────────────────────────────────────────────────

  Widget _buildSettingUpBody(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    final descriptionStyle = typography.bodyPrimary.copyWith(
      color: colors.foregroundSecondary,
    );
    final descriptionHeight =
        (descriptionStyle.height ?? 1.2) * descriptionStyle.fontSize! * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.s16),
        if (widget.settingUpTitle != null)
          Text(
            widget.settingUpTitle!,
            style: typography.bodySecondaryBold.copyWith(
              color: colors.backgroundBrand,
            ),
          ),
        SizedBox(height: spacing.s8),
        SizedBox(
          height: descriptionHeight,
          child: widget.settingUpBody != null
              ? Text(
                  widget.settingUpBody!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: descriptionStyle,
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(height: spacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: widget.settingUpProgressListenable == null
              ? LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: colors.foregroundDisabled.withValues(
                    alpha: 0.3,
                  ),
                  color: colors.foregroundPrimary,
                )
              : ValueListenableBuilder<double>(
                  valueListenable: widget.settingUpProgressListenable!,
                  builder: (context, value, _) => LinearProgressIndicator(
                    minHeight: 4,
                    value: value.clamp(0.0, 1.0),
                    backgroundColor: colors.foregroundDisabled.withValues(
                      alpha: 0.3,
                    ),
                    color: colors.foregroundPrimary,
                  ),
                ),
        ),
      ],
    );
  }

  // ── Tags ───────────────────────────────────────────────────────────────────

  List<NasikoCardTag> _fittingTags(double availableWidth) {
    final tags = widget.tags;
    if (tags.isEmpty) return [];

    final style = context.typography.bodyPrimary;
    final gap = context.spacing.s8;
    final chipHPad = context.spacing.s12 * 2 + 2.0;
    final iconWidth = 12 + context.spacing.s4;

    double textWidth(String text) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width;
    }

    final chipWidths = tags
        .map(
          (t) =>
              chipHPad +
              textWidth(t.label.toUpperCase()) +
              (t.icon != null ? iconWidth : 0),
        )
        .toList();

    for (int count = tags.length; count >= 0; count--) {
      double total = chipWidths.take(count).fold(0.0, (a, b) => a + b);
      if (count > 1) total += gap * (count - 1);
      if (count < tags.length) {
        final overflowLabel = '+${tags.length - count}';
        total += (count > 0 ? gap : 0) + chipHPad + textWidth(overflowLabel);
      }
      if (total <= availableWidth) return tags.sublist(0, count);
    }

    return [];
  }

  Widget _buildTags(bool disabled) {
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
                label: visibleTags[i].label.toUpperCase(),
                leadingIcon: visibleTags[i].icon,
                size: NasikoChipSize.small,
                variant: NasikoChipVariant.base,
                shape: NasikoChipShape.rounded,
                enabled: !disabled,
                borderColor: colors.borderPrimary,
              ),
            ],
            if (overflowCount > 0) ...[
              if (visibleTags.isNotEmpty) SizedBox(width: spacing.s8),
              NasikoTooltip(
                message: widget.tags
                    .skip(visibleTags.length)
                    .map((t) => t.label.toUpperCase())
                    .join(', '),
                preferBelow: false,
                child: NasikoChip(
                  label: '+$overflowCount',
                  size: NasikoChipSize.small,
                  variant: NasikoChipVariant.base,
                  shape: NasikoChipShape.rounded,
                  enabled: !disabled,
                  borderColor: colors.borderPrimary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── Menu button ────────────────────────────────────────────────────────────────

/// Three-dot popover trigger rendered at the end of a [NasikoCard] header.
///
/// [NasikoPopupMenu] wraps its child in [AbsorbPointer], which blocks all
/// pointer events from reaching the [TertiaryIconButton]. A [MouseRegion] +
/// [Listener] placed above the [AbsorbPointer] track hover and pressed state
/// and forward them into the button via an external [WidgetStatesController].
class _CardMenuButton extends StatefulWidget {
  const _CardMenuButton({required this.actions, this.onItemSelected});

  final List<NasikoPopupMenuItemData> actions;
  final ValueChanged<int>? onItemSelected;

  @override
  State<_CardMenuButton> createState() => _CardMenuButtonState();
}

class _CardMenuButtonState extends State<_CardMenuButton> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _statesController.update(WidgetState.hovered, true),
      onExit: (_) => _statesController.update(WidgetState.hovered, false),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) =>
            _statesController.update(WidgetState.pressed, true),
        onPointerUp: (_) =>
            _statesController.update(WidgetState.pressed, false),
        onPointerCancel: (_) =>
            _statesController.update(WidgetState.pressed, false),
        child: NasikoPopupMenu(
          width: 160,
          items: widget.actions,
          onItemSelected: (index) => widget.onItemSelected?.call(index),
          child: TertiaryIconButton(
            icon: HugeIcons.strokeRoundedMoreVertical,
            onPressed: () {},
            size: NasikoButtonSize.medium,
            statesController: _statesController,
          ),
        ),
      ),
    );
  }
}
