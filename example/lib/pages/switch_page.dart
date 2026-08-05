import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool _large = true;
  bool _small = false;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Switch',
      description: 'Two sizes; disabled = onChanged: null.',
      children: [
        GallerySection(
          title: 'Sizes',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'large',
                child: NasikoSwitch(
                  value: _large,
                  onChanged: (v) => setState(() => _large = v),
                ),
              ),
              LabeledExample(
                label: 'small',
                child: NasikoSwitch(
                  value: _small,
                  size: NasikoSwitchSize.small,
                  onChanged: (v) => setState(() => _small = v),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Disabled',
          child: ExampleWrap(
            children: const [
              LabeledExample(
                label: 'off',
                child: NasikoSwitch(value: false, onChanged: null),
              ),
              LabeledExample(
                label: 'on',
                child: NasikoSwitch(value: true, onChanged: null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
