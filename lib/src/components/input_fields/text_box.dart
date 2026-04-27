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

    final borderColor = widget.isOrchestrator
        ? colors.borderSecondary
        : (_isFocused ? colors.borderSecondary : colors.borderPrimary);

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
          color: widget.enabled
              ? Color.fromRGBO(248, 248, 248, 1)
              : Color.fromRGBO(248, 248, 248, 1).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(color: borderColor, width: borderWidths.w1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.attachments.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: spacing.s16),
                child: Wrap(
                  spacing: spacing.s8,
                  runSpacing: spacing.s8,
                  children: widget.attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return NasikoChip(
                      label: file,
                      onDelete:
                          widget.enabled && widget.onRemoveAttachment != null
                          ? () => widget.onRemoveAttachment!(index)
                          : null,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: spacing.s12),
            ],
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  final isShiftPressed =
                      HardwareKeyboard.instance.logicalKeysPressed.contains(
                        LogicalKeyboardKey.shiftLeft,
                      ) ||
                      HardwareKeyboard.instance.logicalKeysPressed.contains(
                        LogicalKeyboardKey.shiftRight,
                      );

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
            if (widget.showAttachmentButton || widget.showSendButton) ...[
              SizedBox(height: spacing.s12),
              Row(
                children: [
                  if (widget.showAttachmentButton)
                    SecondaryIconButton(
                      icon: HugeIcons.strokeRoundedAttachment01,
                      onPressed: widget.enabled ? widget.onAttachmentTap : null,
                      size: NasikoButtonSize.small,
                    ),
                  const Spacer(),
                  if (widget.showSendButton)
                    PrimaryIconButton(
                      icon: HugeIcons.strokeRoundedSent,
                      onPressed: widget.enabled ? widget.onSend : null,
                      size: NasikoButtonSize.medium,
                      isLoading: widget.isLoading,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
