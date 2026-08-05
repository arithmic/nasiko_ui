import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class FieldPage extends StatefulWidget {
  const FieldPage({super.key});

  @override
  State<FieldPage> createState() => _FieldPageState();
}

class _FieldPageState extends State<FieldPage> {
  final _formKey = GlobalKey<FormState>();
  String? _fieldError;
  String _fieldText = '';
  String _formValue = '';

  void _validateField() {
    setState(() {
      _fieldError = _fieldText.trim().isEmpty
          ? 'Workspace name is required.'
          : (_fieldText.trim().length < 3
              ? 'Use at least 3 characters.'
              : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Field & Form Field',
      description:
          'NasikoField wraps any control with label / description / error '
          '(error swaps in with an animated fade + slide). NasikoFormField '
          'plugs the same chrome into Flutter Form validation.',
      children: [
        GallerySection(
          title: 'NasikoField with manual validation',
          description: 'Press Validate to trigger the error animation.',
          child: SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NasikoField(
                  label: 'Workspace name',
                  isRequired: true,
                  description: 'Shown to everyone in your org.',
                  errorText: _fieldError,
                  child: NasikoInputField(
                    hintText: 'e.g. nasiko-core',
                    onChanged: (v) => _fieldText = v,
                  ),
                ),
                SizedBox(height: context.spacing.s12),
                Row(
                  children: [
                    PrimaryButton(
                      label: 'Validate',
                      size: NasikoButtonSize.small,
                      onPressed: _validateField,
                    ),
                    SizedBox(width: context.spacing.s8),
                    SecondaryButton(
                      label: 'Clear error',
                      size: NasikoButtonSize.small,
                      onPressed: () => setState(() => _fieldError = null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Disabled field',
          child: SizedBox(
            width: 380,
            child: NasikoField(
              label: 'Region',
              description: 'Contact an admin to change this.',
              enabled: false,
              child: const NasikoInputField(
                hintText: 'eu-west-1',
                isReadOnly: true,
              ),
            ),
          ),
        ),
        GallerySection(
          title: 'NasikoFormField in a Form',
          child: SizedBox(
            width: 380,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NasikoFormField<String>(
                    label: 'API key name',
                    isRequired: true,
                    description: 'Lowercase letters and dashes only.',
                    initialValue: '',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'A name is required.';
                      }
                      if (!RegExp(r'^[a-z-]+$').hasMatch(v.trim())) {
                        return 'Only lowercase letters and dashes.';
                      }
                      return null;
                    },
                    builder: (state) => NasikoInputField(
                      hintText: 'prod-router-key',
                      onChanged: (v) {
                        _formValue = v;
                        state.didChange(v);
                      },
                    ),
                  ),
                  SizedBox(height: context.spacing.s12),
                  PrimaryButton(
                    label: 'Submit form',
                    size: NasikoButtonSize.small,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        NasikoToastService.showSuccess(
                          context,
                          'Valid: $_formValue',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
