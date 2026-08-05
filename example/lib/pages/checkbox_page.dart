import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  bool _raw = true;
  bool _tileA = true;
  bool _tileB = false;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Checkbox',
      description:
          'Raw NasikoCheckbox and the labeled NasikoCheckboxTile. Disabled = '
          'onChanged: null.',
      children: [
        GallerySection(
          title: 'Checkbox',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'interactive',
                child: NasikoCheckbox(
                  isChecked: _raw,
                  onChanged: (v) => setState(() => _raw = v ?? false),
                ),
              ),
              const LabeledExample(
                label: 'disabled unchecked',
                child: NasikoCheckbox(isChecked: false, onChanged: null),
              ),
              const LabeledExample(
                label: 'disabled checked',
                child: NasikoCheckbox(isChecked: true, onChanged: null),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Checkbox tile',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NasikoCheckboxTile(
                label: 'Email me about product updates',
                isChecked: _tileA,
                onChanged: (v) => setState(() => _tileA = v ?? false),
              ),
              NasikoCheckboxTile(
                label: 'With a leading icon',
                icon: Icons.notifications_outlined,
                isChecked: _tileB,
                onChanged: (v) => setState(() => _tileB = v ?? false),
              ),
              const NasikoCheckboxTile(
                label: 'Disabled tile',
                isChecked: true,
                onChanged: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
