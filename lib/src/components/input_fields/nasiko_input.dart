import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A standardized, tokenized input field for the Nasiko Design System.
///
/// Single component for all 7 Figma states across two sizes. `hover` and
/// `focus` are detected at runtime; `error` (via [errorText]), `success`
/// ([isSuccess]), `readOnly` and disabled (`enabled: false`) are props.
///
/// Anatomy: `Column[ field-group(label-row, input-box), hint-row ]`.
class NasikoInput extends StatefulWidget {
  const NasikoInput({
    super.key,
    this.controller,
    this.size = NasikoInputSize.medium,
    this.showLabel = true,
    this.label,
    this.required = false,
    this.placeholder,
    this.leadingIcon,
    this.trailingIcon,
    this.showHint = false,
    this.hint,
    this.showCount = false,
    this.maxLength,
    this.isSuccess = false,
    this.readOnly = false,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType,
  })  : assert(
          !showPasswordToggle || obscureText,
          'showPasswordToggle requires obscureText: true',
        );

  final TextEditingController? controller;
  final NasikoInputSize size;

  final bool showLabel;
  final String? label;
  final bool required;

  final String? placeholder;
  final HugeIconsType? leadingIcon;
  final HugeIconsType? trailingIcon;

  final bool showHint;
  final String? hint;
  final bool showCount;

  /// Upper bound shown in the character count as `len/maxLength`.
  ///
  /// Display-only — input is NOT clamped to this length (no
  /// `maxLengthEnforcement`); use [validator] to enforce a hard limit.
  final int? maxLength;

  final bool isSuccess;
  final bool readOnly;
  final bool enabled;

  /// When non-null, the field is in the error state and this drives the hint.
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  /// When true (and [obscureText] is true), renders a tappable show/hide eye
  /// icon in the trailing slot that toggles masking. Takes the trailing slot,
  /// overriding any [trailingIcon].
  final bool showPasswordToggle;

  final TextInputType? keyboardType;

  @override
  State<NasikoInput> createState() => _NasikoInputState();
}

class _NasikoInputState extends State<NasikoInput> {
  /// Outset of the focus ring beyond the input-box edge, matching the Figma
  /// −3px focus-ring offset. Not a spacing token (no 3px tier exists).
  static const double _focusRingOutset = 3;

  late final FocusNode _focusNode;
  TextEditingController? _internalController;
  bool _hovered = false;

  /// Live masking state, only meaningful when [NasikoInput.showPasswordToggle]
  /// is on. Seeded from [NasikoInput.obscureText] and flipped by the eye icon.
  late bool _obscured = widget.obscureText;

  /// Stable identity for the input-box subtree. Gaining focus wraps the box in
  /// the focus-ring Container, which re-parents this subtree; without a stable
  /// key the TextField's element (and its live text-input connection) would be
  /// torn down and rebuilt, dropping the first keystroke after focus.
  final GlobalKey _boxKey = GlobalKey();

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  bool get _focused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NasikoInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent now supplies its own controller, drop the internal one we
    // created so we don't leak it or keep reading a stale value.
    if (widget.controller != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
  }

  /// Resolves the single visual state by precedence.
  NasikoInputVisualState get _state {
    if (!widget.enabled) return NasikoInputVisualState.disabled;
    if (widget.readOnly) return NasikoInputVisualState.readOnly;
    if (widget.errorText != null) return NasikoInputVisualState.error;
    if (widget.isSuccess) return NasikoInputVisualState.success;
    if (_focused) return NasikoInputVisualState.focus;
    if (_hovered) return NasikoInputVisualState.hover;
    return NasikoInputVisualState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final layout = inputLayout(context, widget.size);
    final colors = resolveInputColors(context, _state);
    final typography = context.typography;
    final c = context.colors;

    final valueStyle = (widget.size == NasikoInputSize.medium
            ? typography.bodySecondary
            : typography.bodyTertiary)
        .copyWith(color: colors.text);
    final placeholderStyle = valueStyle.copyWith(color: c.foregroundSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel && widget.label != null) ...[
          _buildLabelRow(context),
          SizedBox(height: layout.labelGap),
        ],
        _buildInputBox(context, layout, colors, valueStyle, placeholderStyle),
        if (widget.showHint) ...[
          SizedBox(height: layout.hintGap),
          _buildHintRow(context, colors),
        ],
      ],
    );
  }

  Widget _buildLabelRow(BuildContext context) {
    final typography = context.typography;
    final c = context.colors;
    final labelStyle =
        typography.bodySecondary.copyWith(color: c.foregroundPrimary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.required)
          Text('*', style: labelStyle.copyWith(color: c.foregroundError)),
        Text(widget.label!, style: labelStyle),
      ],
    );
  }

  Widget _buildInputBox(
    BuildContext context,
    NasikoInputLayout layout,
    NasikoInputColors colors,
    TextStyle valueStyle,
    TextStyle placeholderStyle,
  ) {
    final borderWidths = context.borderWidth;
    final box = Container(
      height: layout.height,
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(layout.bodyRadius),
        border: Border.all(color: colors.border, width: borderWidths.w1),
      ),
      child: Row(
        children: [
          if (widget.leadingIcon != null) ...[
            HugeIcon(
              icon: widget.leadingIcon!,
              size: layout.iconSize,
              strokeWidth: context.iconStrokeWidth.width,
              color: context.colors.foregroundIconTertiary, // passive
            ),
            SizedBox(width: layout.contentGap),
          ],
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText:
                  widget.showPasswordToggle ? _obscured : widget.obscureText,
              keyboardType: widget.keyboardType,
              onChanged: (v) {
                if (widget.showCount) setState(() {});
                widget.onChanged?.call(v);
              },
              validator: widget.validator,
              cursorColor: context.colors.borderSecondary,
              style: valueStyle,
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: placeholderStyle,
              ),
            ),
          ),
          if (widget.showPasswordToggle) ...[
            SizedBox(width: layout.contentGap),
            _buildPasswordToggle(context, layout, colors),
          ] else if (widget.trailingIcon != null) ...[
            SizedBox(width: layout.contentGap),
            HugeIcon(
              icon: widget.trailingIcon!,
              size: layout.iconSize,
              strokeWidth: context.iconStrokeWidth.width,
              color: context.colors.foregroundIconSecondary, // actionable
            ),
          ],
        ],
      ),
    );

    final ring = colors.ring;
    final boxWithHover = MouseRegion(
      key: _boxKey,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: box,
    );

    if (ring == null) return boxWithHover;
    return Container(
      padding: const EdgeInsets.all(_focusRingOutset),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.focusRadius),
        border: Border.all(color: ring, width: context.borderWidth.w2),
      ),
      child: boxWithHover,
    );
  }

  /// Tappable show/hide eye icon for the trailing slot. Non-interactive and
  /// dimmed when the field is disabled or read-only.
  Widget _buildPasswordToggle(
    BuildContext context,
    NasikoInputLayout layout,
    NasikoInputColors colors,
  ) {
    final c = context.colors;
    final interactive = widget.enabled && !widget.readOnly;
    final icon = HugeIcon(
      icon: _obscured
          ? HugeIcons.strokeRoundedViewOff
          : HugeIcons.strokeRoundedView,
      size: layout.iconSize,
      strokeWidth: context.iconStrokeWidth.width,
      color: interactive
          ? c.foregroundIconSecondary // actionable
          : c.foregroundDisabled,
    );

    if (!interactive) return icon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _obscured = !_obscured),
      child: icon,
    );
  }

  Widget _buildHintRow(BuildContext context, NasikoInputColors colors) {
    final typography = context.typography;
    final c = context.colors;
    final hintStyle = typography.bodyTertiary.copyWith(color: colors.hint);
    final countStyle =
        typography.bodyTertiary.copyWith(color: c.foregroundSecondary);

    final hintText = widget.errorText ?? widget.hint;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(hintText ?? '', style: hintStyle),
        ),
        if (widget.showCount) Text(_countLabel(), style: countStyle),
      ],
    );
  }

  String _countLabel() {
    final len = _controller.text.characters.length;
    return widget.maxLength != null ? '$len/${widget.maxLength}' : '$len';
  }
}
