import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

/// Demos the NasikoMotionTheme tokens (`context.motion`) — the package-side
/// mirror of the app's AppMotion scale.
class MotionPage extends StatefulWidget {
  const MotionPage({super.key});

  @override
  State<MotionPage> createState() => _MotionPageState();
}

class _MotionPageState extends State<MotionPage> {
  int _replay = 0;
  bool _loaded = false;

  void _replayAll() {
    setState(() {
      _replay++;
      _loaded = false;
    });
    // Skeleton → content swap after a beat, so the shimmer is visible first.
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    final typography = context.typography;
    final colors = context.colors;

    return GalleryPage(
      title: 'Motion',
      description:
          'Subtle & fast: entrances decelerate, exits accelerate. Tokens: '
          'pressed 100 · hover 120 · fast 150 · base 200 · panel 250 · '
          'page 300 (ms). Press Replay to re-run the entrances below.',
      children: [
        GallerySection(
          title: 'Replay',
          child: PrimaryButton(
            label: 'Replay entrances',
            size: NasikoButtonSize.medium,
            leadingIcon: kIconReload,
            onPressed: _replayAll,
          ),
        ),
        GallerySection(
          title: 'Skeleton → content swap',
          description:
              'Cross-fades at motion.page with the enter curve once the '
              'fake load resolves.',
          child: SizedBox(
            width: 380,
            height: 72,
            child: AnimatedSwitcher(
              duration: motion.resolve(context, motion.page),
              switchInCurve: motion.enter,
              switchOutCurve: motion.exit,
              child: _loaded
                  ? Row(
                      key: ValueKey('content-$_replay'),
                      children: [
                        const NasikoAvatar(text: 'IP'),
                        SizedBox(width: context.spacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Invoice parser',
                                style: typography.bodyPrimaryBold.copyWith(
                                  color: colors.foregroundPrimary,
                                ),
                              ),
                              Text(
                                'Loaded after 1.2s of skeleton',
                                style: typography.bodyTertiary.copyWith(
                                  color: colors.foregroundSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : NasikoSkeletonScope(
                      key: ValueKey('skeleton-$_replay'),
                      child: Row(
                        children: [
                          NasikoSkeletonBlock(
                            width: 40,
                            height: 40,
                            radius:
                                BorderRadius.circular(context.radius.r40),
                          ),
                          SizedBox(width: context.spacing.s12),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NasikoSkeletonBlock(width: 160, height: 14),
                                SizedBox(height: 8),
                                NasikoSkeletonBlock(width: 220, height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        GallerySection(
          title: 'Built-in entrance reveals',
          description:
              'Banner and Empty carry their own one-shot reveal; re-keying '
              'them replays it.',
          child: KeyedSubtree(
            key: ValueKey('reveals-$_replay'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 520,
                  child: NasikoBanner(
                    title: 'Entrance reveal',
                    content: 'Fades and slides in at motion.base.',
                    bannerIconData: kIconInfo,
                    action: SecondaryButton(
                      label: 'Action',
                      size: NasikoButtonSize.medium,
                      onPressed: () {},
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.s16),
                NasikoEmpty(
                  icon: kIconInbox,
                  title: 'Fade + rise entrance',
                  description: 'NasikoEmpty enters at motion.base.',
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Determinate progress sweep',
          description: 'Value animates 0 → 80% at motion.base / motion.move.',
          child: SizedBox(
            width: 380,
            child: KeyedSubtree(
              key: ValueKey('progress-$_replay'),
              child: const NasikoProgress(value: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
