import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {
  bool _bold = true;
  bool _pinned = false;

  String? _alignment = 'left';
  Set<String> _styles = {'bold'};

  String? _small = 'a';
  String? _medium = 'a';
  String? _large = 'a';

  String? _withDisabledItem;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Toggle & Toggle Group',
      description:
          'Two-state buttons, alone or grouped. Single mode is an optional '
          'radio set (re-pressing clears); multiple mode toggles freely. '
          'Every item in a group shares one size — a design rule the group '
          'API enforces.',
      children: [
        GallerySection(
          title: 'Standalone toggle',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'label',
                child: NasikoToggle(
                  label: 'Bold',
                  value: _bold,
                  onChanged: (v) => setState(() => _bold = v),
                ),
              ),
              LabeledExample(
                label: 'icon + label',
                child: NasikoToggle(
                  icon: kIconTick,
                  label: 'Pinned',
                  value: _pinned,
                  onChanged: (v) => setState(() => _pinned = v),
                ),
              ),
              const LabeledExample(
                label: 'disabled',
                child: NasikoToggle(
                  label: 'Disabled',
                  value: true,
                  onChanged: null,
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Single-selection group',
          description: 'Press the active item again to clear the selection. '
              'Arrow keys rove focus (wrapping); Home/End jump.',
          child: NasikoToggleGroup<String>.single(
            value: _alignment,
            onChanged: (v) => setState(() => _alignment = v),
            items: const [
              NasikoToggleGroupItem(value: 'left', label: 'Left'),
              NasikoToggleGroupItem(value: 'center', label: 'Center'),
              NasikoToggleGroupItem(value: 'right', label: 'Right'),
            ],
          ),
        ),
        GallerySection(
          title: 'Multiple-selection group',
          child: NasikoToggleGroup<String>.multiple(
            values: _styles,
            onValuesChanged: (v) => setState(() => _styles = v),
            items: const [
              NasikoToggleGroupItem(value: 'bold', label: 'Bold'),
              NasikoToggleGroupItem(value: 'italic', label: 'Italic'),
              NasikoToggleGroupItem(value: 'underline', label: 'Underline'),
            ],
          ),
        ),
        GallerySection(
          title: 'Sizes',
          description:
              'One size per group — sizes are never mixed within a group.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'small',
                child: NasikoToggleGroup<String>.single(
                  size: NasikoButtonSize.small,
                  value: _small,
                  onChanged: (v) => setState(() => _small = v),
                  items: const [
                    NasikoToggleGroupItem(value: 'a', label: 'Day'),
                    NasikoToggleGroupItem(value: 'b', label: 'Week'),
                    NasikoToggleGroupItem(value: 'c', label: 'Month'),
                  ],
                ),
              ),
              LabeledExample(
                label: 'medium',
                child: NasikoToggleGroup<String>.single(
                  size: NasikoButtonSize.medium,
                  value: _medium,
                  onChanged: (v) => setState(() => _medium = v),
                  items: const [
                    NasikoToggleGroupItem(value: 'a', label: 'Day'),
                    NasikoToggleGroupItem(value: 'b', label: 'Week'),
                    NasikoToggleGroupItem(value: 'c', label: 'Month'),
                  ],
                ),
              ),
              LabeledExample(
                label: 'large',
                child: NasikoToggleGroup<String>.single(
                  value: _large,
                  onChanged: (v) => setState(() => _large = v),
                  items: const [
                    NasikoToggleGroupItem(value: 'a', label: 'Day'),
                    NasikoToggleGroupItem(value: 'b', label: 'Week'),
                    NasikoToggleGroupItem(value: 'c', label: 'Month'),
                  ],
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Disabled items',
          description: 'Disabled items are skipped by keyboard traversal.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'one item disabled',
                child: NasikoToggleGroup<String>.single(
                  value: _withDisabledItem,
                  onChanged: (v) => setState(() => _withDisabledItem = v),
                  items: const [
                    NasikoToggleGroupItem(value: 'list', label: 'List'),
                    NasikoToggleGroupItem(
                      value: 'board',
                      label: 'Board',
                      enabled: false,
                    ),
                    NasikoToggleGroupItem(value: 'table', label: 'Table'),
                  ],
                ),
              ),
              LabeledExample(
                label: 'whole group disabled',
                child: NasikoToggleGroup<String>.single(
                  enabled: false,
                  value: 'list',
                  onChanged: (_) {},
                  items: const [
                    NasikoToggleGroupItem(value: 'list', label: 'List'),
                    NasikoToggleGroupItem(value: 'board', label: 'Board'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
