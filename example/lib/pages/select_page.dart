import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

const List<String> _people = [
  'Ada Lovelace', 'Alan Turing', 'Annie Easley', 'Barbara Liskov',
  'Donald Knuth', 'Edsger Dijkstra', 'Frances Allen', 'Grace Hopper',
  'Katherine Johnson', 'Ken Thompson', 'Margaret Hamilton', 'Niklaus Wirth',
];

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String? _provider;

  // Combobox state — fake async source.
  List<NasikoSelectItem<String>> _results = const [];
  bool _searching = false;
  String? _picked;
  int _searchStamp = 0;

  Future<void> _search(String query) async {
    final stamp = ++_searchStamp;
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    // Fake async backend: 400ms latency, then substring filter.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || stamp != _searchStamp) return;
    setState(() {
      _searching = false;
      _results = [
        for (final name in _people)
          if (name.toLowerCase().contains(query.toLowerCase()))
            NasikoSelectItem(value: name, label: name),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Select & Combobox',
      description:
          'NasikoSelect: controlled single-value dropdown with full keyboard '
          'support and letter typeahead. NasikoCombobox: controlled async '
          'autocomplete — this demo fakes a backend with 400ms latency.',
      children: [
        GallerySection(
          title: 'Select',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'default',
                child: SizedBox(
                  width: 240,
                  child: NasikoSelect<String>(
                    value: _provider,
                    placeholder: 'Choose a provider',
                    items: [
                      const NasikoSelectItem(
                        value: 'anthropic',
                        label: 'Anthropic',
                      ),
                      const NasikoSelectItem(value: 'openai', label: 'OpenAI'),
                      NasikoSelectItem(
                        value: 'google',
                        label: 'Google',
                        icon: kIconSearch,
                      ),
                      const NasikoSelectItem(
                        value: 'legacy',
                        label: 'Legacy (disabled)',
                        enabled: false,
                      ),
                    ],
                    onChanged: (v) => setState(() => _provider = v),
                  ),
                ),
              ),
              LabeledExample(
                label: 'disabled',
                child: SizedBox(
                  width: 240,
                  child: NasikoSelect<String>(
                    value: _provider,
                    enabled: false,
                    items: const [
                      NasikoSelectItem(value: 'x', label: 'Unavailable'),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ),
              LabeledExample(
                label: 'empty items (auto-disabled)',
                child: SizedBox(
                  width: 240,
                  child: NasikoSelect<String>(
                    items: const [],
                    placeholder: 'Nothing to pick',
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Combobox — async source',
          description:
              'Type a few letters (e.g. "gr"); the spinner row shows while '
              'the fake backend filters. Picked: ${_picked ?? '—'}',
          child: SizedBox(
            width: 320,
            child: NasikoCombobox<String>(
              items: _results,
              isLoading: _searching,
              placeholder: 'Search people…',
              selectedLabel: _picked,
              onQueryChanged: _search,
              onSelected: (item) => setState(() => _picked = item.value),
            ),
          ),
        ),
        GallerySection(
          title: 'Combobox — disabled',
          child: SizedBox(
            width: 320,
            child: NasikoCombobox<String>(
              items: const [],
              enabled: false,
              onQueryChanged: (_) {},
              onSelected: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
