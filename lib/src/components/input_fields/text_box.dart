// lib/src/components/input_fields/nasiko_text_box.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import "package:nasiko_ui/nasiko_ui.dart";

/// A multi-line text input component for the Nasiko Design System.
///
/// This component provides a text area with optional attachment and send buttons,
/// and supports an "Orchestrator" mode with distinctive styling.
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
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Text displayed inside the field when it's empty.
  final String hintText;

  /// Whether the text box is in "Orchestrator" mode.
  /// When true, displays a distinctive border color.
  final bool isOrchestrator;

  /// Whether to show the attachment button.
  final bool showAttachmentButton;

  /// Whether to show the send button.
  final bool showSendButton;

  /// Callback when the send button is tapped.
  final VoidCallback? onSend;

  /// Callback when the attachment button is tapped.
  final VoidCallback? onAttachmentTap;

  /// Called when the user initiates a change to the field's value.
  final ValueChanged<String>? onChanged;

  /// The minimum number of lines to display.
  final int minLines;

  /// The maximum number of lines to display.
  final int maxLines;

  /// Whether the text box is enabled.
  final bool enabled;

  /// Attachments shown inside the text box
  final List<String> attachments;

  /// Callback when an attachment is removed
  final void Function(int index)? onRemoveAttachment;

  @override
  State<NasikoTextBox> createState() => _NasikoTextBoxState();
}

class _NasikoTextBoxState extends State<NasikoTextBox> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
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
    final iconSizes = context.iconSize;

    // Determine border color based on mode and focus state
    final Color borderColor = widget.isOrchestrator
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
              ? colors.backgroundGroup
              : colors.backgroundGroup.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(radii.r12),
          border: Border.all(color: borderColor, width: borderWidths.w1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text input field
            if (widget.attachments.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
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
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
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

            // Action buttons row
            if (widget.showAttachmentButton || widget.showSendButton) ...[
              SizedBox(height: spacing.s12),
              Row(
                children: [
                  // Attachment button
                  if (widget.showAttachmentButton)
                    SecondaryIconButton(
                      icon: HugeIcons.strokeRoundedAttachment01,
                      onPressed: widget.enabled ? widget.onAttachmentTap : null,
                      size: NasikoButtonSize.small,
                    ),

                  const Spacer(),

                  // Send button
                  if (widget.showSendButton)
                    PrimaryIconButton(
                      icon: HugeIcons.strokeRoundedSent,
                      onPressed: widget.enabled ? widget.onSend : null,
                      size: NasikoButtonSize.small,
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
