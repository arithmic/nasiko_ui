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
    return Container(
      child: Column(
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
              print('Normal Send: ${_normalController.text}');
            },
            onAttachmentTap: () {
              print('Normal Attachment tapped');
            },
            onChanged: (value) {
              print('Normal Text changed: $value');
            },
          ),

          const SizedBox(height: 48),

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
              print('Orchestrator Send: ${_orchestratorController.text}');
            },
            onAttachmentTap: () {
              print('Orchestrator Attachment tapped');
            },
            onChanged: (value) {
              print('Orchestrator Text changed: $value');
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
        ],
      ),
    );
  }
}
