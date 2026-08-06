import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class ResizablePage extends StatelessWidget {
  const ResizablePage({super.key});

  Widget _panel(BuildContext context, String label) {
    final colors = context.colors;
    return Container(
      color: colors.backgroundSurface,
      alignment: Alignment.center,
      child: Text(
        label,
        style: context.typography.bodySecondary.copyWith(
          color: colors.foregroundSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return GalleryPage(
      title: 'Resizable',
      description:
          'Panel groups with draggable dividers. Double-tap a divider to '
          'reset the adjacent pair to its default sizes.',
      children: [
        GallerySection(
          title: 'Horizontal, two panels',
          child: SizedBox(
            height: 160,
            child: NasikoResizablePanelGroup(
              panels: [
                NasikoResizablePanel(
                  defaultFlex: 1,
                  child: _panel(context, 'One'),
                ),
                NasikoResizablePanel(
                  defaultFlex: 2,
                  child: _panel(context, 'Two'),
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Horizontal, three panels with min / max',
          description:
              'The sidebar is clamped between 240 and 480 of a 1000-unit '
              'layout; overflow cascades to the next panel.',
          child: SizedBox(
            height: 160,
            child: NasikoResizablePanelGroup(
              panels: [
                NasikoResizablePanel(
                  defaultFlex: 340,
                  minFlex: 240,
                  maxFlex: 480,
                  child: _panel(context, 'Sidebar (min 240 / max 480)'),
                ),
                NasikoResizablePanel(
                  defaultFlex: 460,
                  child: _panel(context, 'Content'),
                ),
                NasikoResizablePanel(
                  defaultFlex: 200,
                  minFlex: 120,
                  child: _panel(context, 'Inspector (min 120)'),
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Vertical',
          child: SizedBox(
            height: 280,
            child: NasikoResizablePanelGroup(
              axis: Axis.vertical,
              panels: [
                NasikoResizablePanel(
                  defaultFlex: 1,
                  child: _panel(context, 'Top'),
                ),
                NasikoResizablePanel(
                  defaultFlex: 1,
                  child: _panel(context, 'Bottom'),
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Keyboard',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NasikoKbd(keys: ['←', '→']),
              SizedBox(width: spacing.s8),
              Text(
                'resize a focused divider by 2% per press (↑/↓ when vertical)',
                style: typography.bodyTertiary.copyWith(
                  color: colors.foregroundSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
