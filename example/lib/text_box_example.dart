// Example usage of NasikoTextBox component

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

class TextBoxExample extends StatefulWidget {
  const TextBoxExample({super.key});

  @override
  State<TextBoxExample> createState() => _TextBoxExampleState();
}

class _TextBoxExampleState extends State<TextBoxExample> {
  final TextEditingController _normalController = TextEditingController();
  final TextEditingController _orchestratorController = TextEditingController();

  @override
  void dispose() {
    _normalController.dispose();
    _orchestratorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Normal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Normal text box
        NasikoTextBox(
          controller: _normalController,
          hintText: 'Let orchestrator find the best agents for your work...',
          isOrchestrator: false,
          onSend: () {
            debugPrint('Normal Send: ${_normalController.text}');
          },
          onAttachmentTap: () {
            debugPrint('Normal Attachment tapped');
          },
          onChanged: (value) {
            debugPrint('Normal Text changed: $value');
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'Orchestrator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Orchestrator text box (focused state)
        NasikoTextBox(
          controller: _orchestratorController,
          hintText: 'Let orchestrator find the best agents for your work...',
          isOrchestrator: true,
          onSend: () {
            debugPrint('Orchestrator Send: ${_orchestratorController.text}');
          },
          onAttachmentTap: () {
            debugPrint('Orchestrator Attachment tapped');
          },
          onChanged: (value) {
            debugPrint('Orchestrator Text changed: $value');
          },
        ),

        const SizedBox(height: 24),

        // Example without buttons
        const Text(
          'Without Buttons',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        NasikoTextBox(
          hintText: 'Text box without buttons...',
          showAttachmentButton: false,
          showSendButton: false,
        ),
        const SizedBox(height: 24),
        const Text(
          'With Attachments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // With Attachments
        // Normal text box
        NasikoTextBox(
          controller: _normalController,
          hintText: 'Let orchestrator find the best agents for your work...',
          isOrchestrator: false,
          onSend: () {
            debugPrint('Normal Send: ${_normalController.text}');
          },
          onAttachmentTap: () {
            debugPrint('Normal Attachment tapped');
          },
          onChanged: (value) {
            debugPrint('Normal Text changed: $value');
          },
          attachments: ["Attachment1", "Attachment2"],
          estimatedTokens: 273,
          onRemoveAttachment: (index) {
            debugPrint('Deleted $index');
          },
        ),
      ],
    );
  }
}
