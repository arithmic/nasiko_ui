import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A multi-line text input component for the Nasiko Design System.
class NasikoTextBox extends StatefulWidget {
  const NasikoTextBox({
    super.key,
    this.controller,
    this.hintText = 'Let orchestrator find the best agents for your work...',
    this.isOrchestrator = false,
    this.showAttachmentButton = true,
    this.showSendButton = true,
    this.onSend,
    this.onAttachmentTap,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 10,
    this.enabled = true,
    this.attachments = const [],
    this.onRemoveAttachment,
    this.isLoading = false,
    this.focusNode,
    this.estimatedTokens,
    this.estimatedTokensTooltip = 'Estimated tokens usage',
  });

  final TextEditingController? controller;
  final String hintText;
  final bool isOrchestrator;
  final bool showAttachmentButton;
  final bool showSendButton;
  final VoidCallback? onSend;
  final VoidCallback? onAttachmentTap;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final List<String> attachments;
  final void Function(int index)? onRemoveAttachment;
  final bool isLoading;
  final FocusNode? focusNode;
  final int? estimatedTokens;
  final String estimatedTokensTooltip;

  @override
  State<NasikoTextBox> createState() => _NasikoTextBoxState();
}

class _NasikoTextBoxState extends State<NasikoTextBox> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _bindFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant NasikoTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    _unbindController();
    super.dispose();
  }

  void _bindController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
  }

  void _unbindController() {
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _bindFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode();
    _isFocused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  void _unbindFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    final borderColor = _isFocused
        ? colors.borderSecondary
        : colors.borderPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.enabled) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(color: borderColor, width: borderWidths.w1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        final isShiftPressed =
                            HardwareKeyboard.instance.logicalKeysPressed
                                .contains(LogicalKeyboardKey.shiftLeft) ||
                            HardwareKeyboard.instance.logicalKeysPressed
                                .contains(LogicalKeyboardKey.shiftRight);

                        if (isShiftPressed) {
                          return KeyEventResult.ignored;
                        }

                        widget.onSend?.call();
                        return KeyEventResult.handled;
                      }

                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: widget.minLines,
                      maxLines: widget.maxLines,
                      textInputAction: TextInputAction.newline,
                      enabled: widget.enabled,
                      style: typography.bodyPrimary.copyWith(
                        color: colors.foregroundPrimary,
                      ),
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: typography.bodyPrimary.copyWith(
                          color: colors.foregroundSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                if (widget.estimatedTokens != null) ...[
                  SizedBox(width: spacing.s12),
                  _EstimatedTokensPill(
                    tokens: widget.estimatedTokens!,
                    tooltip: widget.estimatedTokensTooltip,
                  ),
                ],
              ],
            ),
            if (widget.showAttachmentButton ||
                widget.attachments.isNotEmpty ||
                widget.showSendButton) ...[
              SizedBox(height: spacing.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: spacing.s8,
                      runSpacing: spacing.s8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.showAttachmentButton)
                          SecondaryIconButton(
                            icon: HugeIcons.strokeRoundedAttachment01,
                            onPressed: widget.enabled
                                ? widget.onAttachmentTap
                                : null,
                            size: NasikoButtonSize.small,
                          ),
                        ...widget.attachments.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return _TextBoxAttachmentChip(
                            label: file,
                            leadingIcon: _attachmentIconFor(file),
                            onDelete:
                                widget.enabled &&
                                    widget.onRemoveAttachment != null
                                ? () => widget.onRemoveAttachment!(index)
                                : null,
                          );
                        }),
                      ],
                    ),
                  ),
                  if (widget.showSendButton) ...[
                    SizedBox(width: spacing.s12),
                    PrimaryIconButton(
                      icon: HugeIcons.strokeRoundedSent,
                      onPressed: widget.enabled ? widget.onSend : null,
                      size: NasikoButtonSize.medium,
                      isLoading: widget.isLoading,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  HugeIconsType _attachmentIconFor(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.pdf')) {
      return HugeIcons.strokeRoundedPdf02;
    }

    if (lowerFileName.endsWith('.jpg') ||
        lowerFileName.endsWith('.jpeg') ||
        lowerFileName.endsWith('.png') ||
        lowerFileName.endsWith('.gif') ||
        lowerFileName.endsWith('.webp')) {
      return HugeIcons.strokeRoundedImage02;
    }

    return HugeIcons.strokeRoundedFile02;
  }
}

class _EstimatedTokensPill extends StatelessWidget {
  const _EstimatedTokensPill({required this.tokens, required this.tooltip});

  final int tokens;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return NasikoTooltip(
      message: tooltip,
      preferBelow: false,
      child: NasikoChip(
        enabled: true,
        shape: NasikoChipShape.rounded,
        size: NasikoChipSize.small,
        label: '$tokens',
        leadingIcon: HugeIcons.strokeRoundedCoins02,
      ),
    );
  }
}

class _TextBoxAttachmentChip extends StatelessWidget {
  const _TextBoxAttachmentChip({
    required this.label,
    required this.leadingIcon,
    this.onDelete,
  });

  final String label;
  final HugeIconsType leadingIcon;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s12,
          vertical: spacing.s8,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(radii.r8),
          border: Border.all(
            color: colors.borderPrimary,
            width: borderWidths.w1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: leadingIcon,
              size: iconSizes.s,
              color: colors.foregroundIconPrimary,
            ),
            SizedBox(width: spacing.s2),
            Flexible(
              child: Text(
                label.length > 20 ? '${label.substring(0, 20)}...' : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.buttonSecondary.copyWith(
                  color: colors.foregroundPrimary,
                ),
              ),
            ),
            if (onDelete != null) ...[
              SizedBox(width: spacing.s8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: iconSizes.s,
                  color: colors.foregroundIconPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
