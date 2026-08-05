import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class DividerPage extends StatelessWidget {
  const DividerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = context.typography.bodySecondary.copyWith(
      color: context.colors.foregroundSecondary,
    );
    return GalleryPage(
      title: 'Divider',
      description: 'Hairline separators, horizontal and vertical.',
      children: [
        GallerySection(
          title: 'Horizontal',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Above the line', style: textStyle),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: context.spacing.s12),
                  child: const NasikoDivider(),
                ),
                Text('Below the line', style: textStyle),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Vertical',
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Text('Left', style: textStyle),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: context.spacing.s12),
                  child:
                      const NasikoDivider(axis: NasikoDividerAxis.vertical),
                ),
                Text('Right', style: textStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
