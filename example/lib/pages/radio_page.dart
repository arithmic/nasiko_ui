import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  String _plan = 'pro';
  String _tilePick = 'daily';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Radio',
      description:
          'Raw NasikoRadio and labeled NasikoRadioTile. Disabled = '
          'onChanged: null.',
      children: [
        GallerySection(
          title: 'Radio group',
          child: Row(
            children: [
              for (final plan in ['free', 'pro', 'team']) ...[
                NasikoRadio<String>(
                  value: plan,
                  groupValue: _plan,
                  onChanged: (v) => setState(() => _plan = v ?? _plan),
                ),
                SizedBox(width: context.spacing.s4),
                Text(
                  plan,
                  style: context.typography.bodySecondary.copyWith(
                    color: context.colors.foregroundPrimary,
                  ),
                ),
                SizedBox(width: context.spacing.s16),
              ],
            ],
          ),
        ),
        const GallerySection(
          title: 'Disabled',
          child: Row(
            children: [
              NasikoRadio<String>(
                value: 'a',
                groupValue: 'a',
                onChanged: null,
              ),
              SizedBox(width: 16),
              NasikoRadio<String>(
                value: 'b',
                groupValue: 'a',
                onChanged: null,
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Radio tiles',
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NasikoRadioTile<String>(
                  value: 'daily',
                  groupValue: _tilePick,
                  label: 'Daily digest',
                  onChanged: (v) =>
                      setState(() => _tilePick = v ?? _tilePick),
                ),
                NasikoRadioTile<String>(
                  value: 'weekly',
                  groupValue: _tilePick,
                  label: 'Weekly digest',
                  icon: kIconInbox,
                  onChanged: (v) =>
                      setState(() => _tilePick = v ?? _tilePick),
                ),
                const NasikoRadioTile<String>(
                  value: 'never',
                  groupValue: 'daily',
                  label: 'Disabled option',
                  onChanged: null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
