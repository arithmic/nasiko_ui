import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class HoverCardPage extends StatelessWidget {
  const HoverCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return GalleryPage(
      title: 'Hover Card',
      description:
          'A rich, non-modal card that opens after the pointer rests on the '
          'trigger (700ms) and closes 300ms after it leaves both trigger and '
          'card — moving onto the card keeps it open. Mouse-only by design; '
          'keep the information reachable another way for touch/keyboard.',
      children: [
        GallerySection(
          title: 'Profile preview',
          description: 'Rest the pointer on the mention below.',
          child: NasikoHoverCard(
            width: 280,
            contentBuilder: (context) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NasikoAvatar(text: 'SD'),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Satyajit D.',
                        style: typography.bodyPrimaryBold.copyWith(
                          color: colors.foregroundPrimary,
                        ),
                      ),
                      SizedBox(height: spacing.s2),
                      Text(
                        '@satya — lead frontend',
                        style: typography.bodyTertiary.copyWith(
                          color: colors.foregroundSecondary,
                        ),
                      ),
                      SizedBox(height: spacing.s8),
                      const NasikoBadge(
                        label: 'Online',
                        intent: NasikoBadgeIntent.success,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            child: Text(
              '@satya',
              style: typography.bodyPrimaryBold.copyWith(
                color: colors.foregroundInformation,
              ),
            ),
          ),
        ),
        GallerySection(
          title: 'Preferred side',
          description: 'Opens to the right; flips when it does not fit.',
          child: NasikoHoverCard(
            side: NasikoHoverCardSide.right,
            width: 220,
            contentBuilder: (context) => Text(
              'Cards can open on any side of the trigger and auto-flip on '
              'overflow.',
              style: typography.bodySecondary.copyWith(
                color: colors.foregroundPrimary,
              ),
            ),
            child: Text(
              'Hover me (opens right)',
              style: typography.bodySecondary.copyWith(
                color: colors.foregroundPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
