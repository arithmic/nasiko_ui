import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GalleryPage(
      title: 'Skeleton',
      description:
          'NasikoSkeletonScope drives one shared shimmer sweep across all '
          'blocks below it; blocks outside a scope render static. '
          'Reduced-motion stops the sweep.',
      children: [
        GallerySection(
          title: 'Card-shaped skeleton (in a scope)',
          child: SizedBox(
            width: 380,
            child: NasikoSkeletonScope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NasikoSkeletonBlock(
                        width: 40,
                        height: 40,
                        radius: BorderRadius.circular(context.radius.r40),
                      ),
                      SizedBox(width: spacing.s12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NasikoSkeletonBlock(width: 140, height: 14),
                            SizedBox(height: 6),
                            NasikoSkeletonBlock(width: 90, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.s16),
                  const NasikoSkeletonBlock(height: 12),
                  SizedBox(height: spacing.s8),
                  const NasikoSkeletonBlock(height: 12),
                  SizedBox(height: spacing.s8),
                  const NasikoSkeletonBlock(width: 220, height: 12),
                ],
              ),
            ),
          ),
        ),
        const GallerySection(
          title: 'Standalone block (no scope)',
          description: 'Static surface-colored block, no shimmer.',
          child: NasikoSkeletonBlock(width: 240, height: 16),
        ),
      ],
    );
  }
}
