import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

/// All 13 public button widgets in every meaningful state.
///
/// Design rule: buttons rendered together in one group always share a single
/// [NasikoButtonSize] — different sizes live in separately labeled groups.
class ButtonsPage extends StatelessWidget {
  const ButtonsPage({super.key});

  void _noop() {}

  Row _labelRow(NasikoButtonSize size) {
    return Row(
      children: [
        for (final (widget, gap) in [
          (
            PrimaryButton(onPressed: _noop, label: 'Primary', size: size),
            true,
          ),
          (
            SecondaryButton(onPressed: _noop, label: 'Secondary', size: size),
            true,
          ),
          (
            TertiaryButton(onPressed: _noop, label: 'Tertiary', size: size),
            true,
          ),
          (
            DestructiveButton(onPressed: _noop, label: 'Delete', size: size),
            true,
          ),
          (
            DestructiveSecondaryButton(
              onPressed: _noop,
              label: 'Remove',
              size: size,
            ),
            true,
          ),
          (
            DestructiveTextButton(onPressed: _noop, label: 'Text', size: size),
            false,
          ),
        ]) ...[
          widget,
          if (gap) const SizedBox(width: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Buttons',
      description:
          'Label, text, link, and icon buttons. Each group below uses one '
          'NasikoButtonSize; disabled state = onPressed: null; '
          'PrimaryIconButton additionally supports isLoading.',
      children: [
        GallerySection(
          title: 'Label buttons — large',
          child: _labelRow(NasikoButtonSize.large),
        ),
        GallerySection(
          title: 'Label buttons — medium',
          child: _labelRow(NasikoButtonSize.medium),
        ),
        GallerySection(
          title: 'Label buttons — small',
          child: _labelRow(NasikoButtonSize.small),
        ),
        GallerySection(
          title: 'Label buttons — disabled (large)',
          child: Row(
            children: const [
              PrimaryButton(onPressed: null, label: 'Primary'),
              SizedBox(width: 12),
              SecondaryButton(onPressed: null, label: 'Secondary'),
              SizedBox(width: 12),
              TertiaryButton(onPressed: null, label: 'Tertiary'),
              SizedBox(width: 12),
              DestructiveButton(onPressed: null, label: 'Delete'),
              SizedBox(width: 12),
              DestructiveSecondaryButton(onPressed: null, label: 'Remove'),
              SizedBox(width: 12),
              DestructiveTextButton(onPressed: null, label: 'Text'),
            ],
          ),
        ),
        GallerySection(
          title: 'With leading / trailing icons (large)',
          child: Row(
            children: [
              PrimaryButton(
                onPressed: _noop,
                label: 'Create',
                leadingIcon: kIconAdd,
              ),
              const SizedBox(width: 12),
              SecondaryButton(
                onPressed: _noop,
                label: 'Continue',
                trailingIcon: kIconArrowRight,
              ),
              const SizedBox(width: 12),
              DestructiveButton(
                onPressed: _noop,
                label: 'Delete',
                leadingIcon: kIconDelete,
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Text & link buttons',
          description: 'These variants have no size parameter.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'PrimaryTextButton',
                child: PrimaryTextButton(onPressed: _noop, label: 'Primary'),
              ),
              LabeledExample(
                label: 'SecondaryTextButton',
                child: SecondaryTextButton(
                  onPressed: _noop,
                  label: 'Secondary',
                ),
              ),
              LabeledExample(
                label: 'LinkButton',
                child: LinkButton(onPressed: _noop, label: 'Open docs'),
              ),
              const LabeledExample(
                label: 'Disabled',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryTextButton(onPressed: null, label: 'Primary'),
                    SizedBox(width: 12),
                    SecondaryTextButton(onPressed: null, label: 'Secondary'),
                    SizedBox(width: 12),
                    LinkButton(onPressed: null, label: 'Open docs'),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final size in NasikoButtonSize.values)
          GallerySection(
            title: 'Icon buttons — ${size.name}',
            description: 'Enabled, disabled, loading.',
            child: Row(
              children: [
                PrimaryIconButton(onPressed: _noop, icon: kIconAdd, size: size),
                const SizedBox(width: 12),
                SecondaryIconButton(
                  onPressed: _noop,
                  icon: kIconSearch,
                  size: size,
                ),
                const SizedBox(width: 12),
                TertiaryIconButton(
                  onPressed: _noop,
                  icon: kIconMore,
                  size: size,
                ),
                const SizedBox(width: 12),
                DestructiveIconButton(
                  onPressed: _noop,
                  icon: kIconDelete,
                  size: size,
                ),
                const SizedBox(width: 24),
                PrimaryIconButton(onPressed: null, icon: kIconAdd, size: size),
                const SizedBox(width: 12),
                SecondaryIconButton(
                  onPressed: null,
                  icon: kIconSearch,
                  size: size,
                ),
                const SizedBox(width: 24),
                // isLoading exists on PrimaryIconButton only.
                PrimaryIconButton(
                  onPressed: _noop,
                  icon: kIconAdd,
                  size: size,
                  isLoading: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
