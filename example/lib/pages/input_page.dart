import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  bool _textBoxLoading = false;
  List<String> _attachments = ['spec.pdf', 'tokens.json'];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Input & Text Box',
      description:
          'NasikoInputField (single-line form input) and NasikoTextBox '
          '(multi-line composer with attachments, send button, and token '
          'estimate).',
      children: [
        GallerySection(
          title: 'Input field',
          child: SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NasikoInputField(
                  label: 'Name',
                  hintText: 'Jane Doe',
                  helperText: 'As it appears on your profile.',
                ),
                SizedBox(height: context.spacing.s16),
                NasikoInputField(
                  label: 'Search',
                  hintText: 'Search agents…',
                  leadingIcon: kIconSearch,
                  labelInfoIcon: kIconInfo,
                  isRequired: true,
                ),
                SizedBox(height: context.spacing.s16),
                const NasikoInputField(
                  label: 'Password',
                  hintText: '••••••••',
                  obscureText: true,
                ),
                SizedBox(height: context.spacing.s16),
                const NasikoInputField(
                  label: 'Read-only',
                  hintText: 'nasiko.app/workspace',
                  isReadOnly: true,
                ),
                SizedBox(height: context.spacing.s16),
                const NasikoInputField(
                  label: 'Multi-line',
                  hintText: 'Describe the agent…',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Text box — default',
          child: SizedBox(
            width: 520,
            child: NasikoTextBox(
              hintText: 'Ask anything…',
              isLoading: _textBoxLoading,
              estimatedTokens: 1240,
              onSend: () {
                setState(() => _textBoxLoading = true);
                Future<void>.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _textBoxLoading = false);
                });
              },
              onAttachmentTap: () =>
                  NasikoToastService.showInfo(context, 'Attachment tapped'),
            ),
          ),
        ),
        GallerySection(
          title: 'Text box — attachments',
          child: SizedBox(
            width: 520,
            child: NasikoTextBox(
              hintText: 'Message with attachments…',
              attachments: _attachments,
              onRemoveAttachment: (index) => setState(() {
                _attachments = List.of(_attachments)..removeAt(index);
              }),
              onSend: () {},
              onAttachmentTap: () => setState(() {
                _attachments = List.of(_attachments)
                  ..add('file-${_attachments.length + 1}.txt');
              }),
            ),
          ),
        ),
        GallerySection(
          title: 'Text box — disabled',
          child: SizedBox(
            width: 520,
            child: const NasikoTextBox(enabled: false),
          ),
        ),
      ],
    );
  }
}
