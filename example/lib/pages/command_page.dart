import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  String _lastCommand = 'none yet';

  Future<void> _open() {
    return showNasikoCommandPalette(
      context: context,
      groups: [
        NasikoCommandGroup(
          label: 'Navigation',
          items: [
            NasikoCommandItem(
              label: 'Go to dashboard',
              icon: kIconInbox,
              shortcut: const ['G', 'D'],
              onSelected: () => setState(() => _lastCommand = 'Dashboard'),
            ),
            NasikoCommandItem(
              label: 'Go to agents',
              icon: kIconUser,
              keywords: const ['bots', 'workers'],
              onSelected: () => setState(() => _lastCommand = 'Agents'),
            ),
            NasikoCommandItem(
              label: 'Go to billing',
              icon: kIconCoins,
              keywords: const ['invoices', 'payment'],
              onSelected: () => setState(() => _lastCommand = 'Billing'),
            ),
          ],
        ),
        NasikoCommandGroup(
          label: 'Actions',
          items: [
            NasikoCommandItem(
              label: 'New agent',
              icon: kIconAdd,
              shortcut: const ['⌘', 'N'],
              onSelected: () => setState(() => _lastCommand = 'New agent'),
            ),
            NasikoCommandItem(
              label: 'Search files',
              icon: kIconSearch,
              shortcut: const ['⌘', 'K'],
              onSelected: () => setState(() => _lastCommand = 'Search files'),
            ),
            NasikoCommandItem(
              label: 'Delete workspace',
              icon: kIconDelete,
              keywords: const ['remove', 'destroy'],
              onSelected: () =>
                  setState(() => _lastCommand = 'Delete workspace'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Command Palette',
      description:
          'Top-aligned dialog with live filtering (prefix > word-boundary > '
          'substring/keyword), arrow-key highlight, Enter to run, Escape to '
          'close. Try typing "bill" or the keyword "bots".',
      children: [
        GallerySection(
          title: 'Open it',
          child: Row(
            children: [
              PrimaryButton(
                label: 'Open command palette',
                size: NasikoButtonSize.medium,
                onPressed: _open,
              ),
              SizedBox(width: context.spacing.s16),
              const NasikoKbd(keys: ['⌘', 'K']),
              SizedBox(width: context.spacing.s16),
              Text(
                'Last command: $_lastCommand',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
