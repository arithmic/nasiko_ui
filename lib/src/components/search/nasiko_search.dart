import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A standardized, tokenized search field for the Nasiko Design System.
///
/// Single component for all 5 Figma states across two sizes. `hover` and
/// `focus` are detected at runtime; `loading` ([isLoading]) and disabled
/// (`enabled: false`) are props. Leaner than [NasikoInput] — the component IS
/// the search box (no label/hint wrapper).
///
/// Anatomy: `Row[ leading search icon · value/placeholder · trailing(clear|spinner) ]`.
class NasikoSearch extends StatefulWidget {
  const NasikoSearch({
    super.key,
    this.controller,
    this.size = NasikoSearchSize.medium,
    this.placeholder = 'Search',
    this.leadingIcon = HugeIcons.strokeRoundedSearch01,
    this.trailingIcon = HugeIcons.strokeRoundedCancel01,
    this.isLoading = false,
    this.enabled = true,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController? controller;
  final NasikoSearchSize size;
  final String placeholder;

  /// Leading icon (instance-swap point). Defaults to the search glyph.
  final HugeIconsType leadingIcon;

  /// Trailing clear icon (instance-swap point). Defaults to the cancel `×`.
  final HugeIconsType trailingIcon;

  /// When true, the trailing slot shows a spinner instead of the clear icon.
  final bool isLoading;

  final bool enabled;

  final ValueChanged<String>? onChanged;

  /// Fired when the clear icon is tapped (after the controller is cleared).
  final VoidCallback? onClear;

  @override
  State<NasikoSearch> createState() => _NasikoSearchState();
}

class _NasikoSearchState extends State<NasikoSearch> {
  /// Outset of the focus ring beyond the box edge, matching the Figma −3px
  /// focus-ring offset. Not a spacing token (no 3px tier exists).
  static const double _focusRingOutset = 3;

  late final FocusNode _focusNode;
  TextEditingController? _internalController;
  bool _hovered = false;

  /// Stable identity for the search-box subtree. Gaining focus wraps the box in
  /// the focus-ring Container, re-parenting this subtree; without a stable key
  /// the TextField's element (and its live text-input connection) would be torn
  /// down and rebuilt, dropping the first keystroke after focus.
  final GlobalKey _boxKey = GlobalKey();

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  bool get _focused => _focusNode.hasFocus;
  bool get _hasValue => _controller.text.isNotEmpty;

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
  void didUpdateWidget(NasikoSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent now supplies its own controller, drop the internal one we
    // created so we don't leak it or keep reading a stale value.
    if (widget.controller != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
  }

  /// Resolves the single visual state by precedence.
  NasikoSearchVisualState get _state {
    if (!widget.enabled) return NasikoSearchVisualState.disabled;
    if (widget.isLoading) return NasikoSearchVisualState.loading;
    if (_focused) return NasikoSearchVisualState.focus;
    if (_hovered) return NasikoSearchVisualState.hover;
    return NasikoSearchVisualState.normal;
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {}); // refresh _hasValue so the clear icon hides
  }

  @override
  Widget build(BuildContext context) {
    final layout = searchLayout(context, widget.size);
    final colors = resolveSearchColors(context, _state);
    final typography = context.typography;
    final c = context.colors;

    final valueStyle = (widget.size == NasikoSearchSize.medium
            ? typography.bodySecondary
            : typography.bodyTertiary)
        .copyWith(color: colors.text);
    final placeholderStyle = valueStyle.copyWith(color: c.foregroundSecondary);

    // Trailing slot: spinner while loading; clear icon when has-value + enabled
    // + not loading; otherwise nothing.
    final bool showClear = _hasValue && widget.enabled && !widget.isLoading;

    final box = Container(
      height: layout.height,
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(layout.bodyRadius),
        border: Border.all(color: colors.border, width: context.borderWidth.w1),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: widget.leadingIcon,
            size: layout.iconSize,
            strokeWidth: context.iconStrokeWidth.width,
            color: c.foregroundIconTertiary, // passive
          ),
          SizedBox(width: layout.contentGap),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: (v) {
                setState(() {}); // refresh _hasValue → clear icon visibility
                widget.onChanged?.call(v);
              },
              cursorColor: c.borderSecondary,
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
          if (widget.isLoading) ...[
            SizedBox(width: layout.contentGap),
            _SearchSpinner(size: layout.iconSize),
          ] else if (showClear) ...[
            SizedBox(width: layout.contentGap),
            GestureDetector(
              onTap: _handleClear,
              behavior: HitTestBehavior.opaque,
              child: HugeIcon(
                icon: widget.trailingIcon,
                size: layout.iconSize,
                strokeWidth: context.iconStrokeWidth.width,
                color: c.foregroundIconSecondary, // actionable
              ),
            ),
          ],
        ],
      ),
    );

    final boxWithHover = MouseRegion(
      key: _boxKey,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: box,
    );

    final ring = colors.ring;
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
}

/// Loading spinner for the trailing slot.
///
/// ⚠️ TEMPORARY placeholder. A dedicated Nasiko Loader library is planned; when
/// it lands, swap this for the Loader (`Type=spinner`, neutral arc). Until then
/// this renders a neutral [CircularProgressIndicator] sized to the icon slot.
class _SearchSpinner extends StatelessWidget {
  const _SearchSpinner({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: context.borderWidth.w1,
        color: context.colors.foregroundIconTertiary,
      ),
    );
  }
}
