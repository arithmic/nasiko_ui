import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import 'pages/accordion_page.dart';
import 'pages/alert_page.dart';
import 'pages/avatar_page.dart';
import 'pages/badge_page.dart';
import 'pages/banner_page.dart';
import 'pages/breadcrumb_page.dart';
import 'pages/buttons_page.dart';
import 'pages/calendar_page.dart';
import 'pages/card_page.dart';
import 'pages/checkbox_page.dart';
import 'pages/chips_page.dart';
import 'pages/command_page.dart';
import 'pages/context_menu_page.dart';
import 'pages/data_table_page.dart';
import 'pages/divider_page.dart';
import 'pages/empty_page.dart';
import 'pages/field_page.dart';
import 'pages/hover_card_page.dart';
import 'pages/input_otp_page.dart';
import 'pages/input_page.dart';
import 'pages/kbd_page.dart';
import 'pages/list_page.dart';
import 'pages/menu_page.dart';
import 'pages/modal_page.dart';
import 'pages/motion_page.dart';
import 'pages/navigation_page.dart';
import 'pages/popover_page.dart';
import 'pages/progress_page.dart';
import 'pages/radio_page.dart';
import 'pages/resizable_page.dart';
import 'pages/select_page.dart';
import 'pages/skeleton_page.dart';
import 'pages/slider_page.dart';
import 'pages/spinner_page.dart';
import 'pages/switch_page.dart';
import 'pages/table_page.dart';
import 'pages/tabs_page.dart';
import 'pages/time_picker_page.dart';
import 'pages/toast_page.dart';
import 'pages/toggle_page.dart';
import 'pages/tooltip_page.dart';

class _GalleryEntry {
  const _GalleryEntry(this.title, this.builder);

  final String title;
  final WidgetBuilder builder;
}

final List<_GalleryEntry> _entries = [
  _GalleryEntry('Accordion & Section', (_) => const AccordionPage()),
  _GalleryEntry('Alert', (_) => const AlertPage()),
  _GalleryEntry('Avatar', (_) => const AvatarPage()),
  _GalleryEntry('Badge', (_) => const BadgePage()),
  _GalleryEntry('Banner', (_) => const BannerPage()),
  _GalleryEntry('Breadcrumb', (_) => const BreadcrumbPage()),
  _GalleryEntry('Buttons', (_) => const ButtonsPage()),
  _GalleryEntry('Calendar & Date', (_) => const CalendarPage()),
  _GalleryEntry('Card', (_) => const CardPage()),
  _GalleryEntry('Checkbox', (_) => const CheckboxPage()),
  _GalleryEntry('Chips', (_) => const ChipsPage()),
  _GalleryEntry('Command Palette', (_) => const CommandPage()),
  _GalleryEntry('Context Menu', (_) => const ContextMenuPage()),
  _GalleryEntry('Data Table', (_) => const DataTablePage()),
  _GalleryEntry('Divider', (_) => const DividerPage()),
  _GalleryEntry('Empty', (_) => const EmptyPage()),
  _GalleryEntry('Field & Form Field', (_) => const FieldPage()),
  _GalleryEntry('Hover Card', (_) => const HoverCardPage()),
  _GalleryEntry('Input & Text Box', (_) => const InputPage()),
  _GalleryEntry('Input OTP', (_) => const InputOtpPage()),
  _GalleryEntry('Kbd', (_) => const KbdPage()),
  _GalleryEntry('List', (_) => const ListPage()),
  _GalleryEntry('Menu', (_) => const MenuPage()),
  _GalleryEntry('Modal, Confirm & Sheet', (_) => const ModalPage()),
  _GalleryEntry('Motion', (_) => const MotionPage()),
  _GalleryEntry('Navigation', (_) => const NavigationPage()),
  _GalleryEntry('Popover', (_) => const PopoverPage()),
  _GalleryEntry('Progress', (_) => const ProgressPage()),
  _GalleryEntry('Radio', (_) => const RadioPage()),
  _GalleryEntry('Resizable', (_) => const ResizablePage()),
  _GalleryEntry('Select & Combobox', (_) => const SelectPage()),
  _GalleryEntry('Skeleton', (_) => const SkeletonPage()),
  _GalleryEntry('Slider', (_) => const SliderPage()),
  _GalleryEntry('Spinner', (_) => const SpinnerPage()),
  _GalleryEntry('Switch', (_) => const SwitchPage()),
  _GalleryEntry('Table vs Data Table', (_) => const TablePage()),
  _GalleryEntry('Tabs', (_) => const TabsPage()),
  _GalleryEntry('Time Picker', (_) => const TimePickerPage()),
  _GalleryEntry('Toast', (_) => const ToastPage()),
  _GalleryEntry('Toggle & Toggle Group', (_) => const TogglePage()),
  _GalleryEntry('Tooltip', (_) => const TooltipPage()),
];

/// App shell: toolbar (theme mode + palette), left nav, content area.
class GalleryScaffold extends StatefulWidget {
  const GalleryScaffold({
    super.key,
    required this.themeMode,
    required this.palette,
    required this.onThemeModeChanged,
    required this.onPaletteChanged,
  });

  final ThemeMode themeMode;
  final NasikoColorPalette palette;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<NasikoColorPalette> onPaletteChanged;

  @override
  State<GalleryScaffold> createState() => _GalleryScaffoldState();
}

class _GalleryScaffoldState extends State<GalleryScaffold> {
  int _selectedIndex = 6; // Buttons — the densest page — as landing.

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Scaffold(
      body: Column(
        children: [
          // ── Toolbar ────────────────────────────────────────────────
          Container(
            color: colors.backgroundSurface,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s8,
            ),
            child: Row(
              children: [
                Text(
                  'Nasiko UI Gallery',
                  style: typography.titleSecondary.copyWith(
                    color: colors.foregroundPrimary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  child: NasikoSelect<ThemeMode>(
                    value: widget.themeMode,
                    placeholder: 'Theme',
                    items: const [
                      NasikoSelectItem(value: ThemeMode.light, label: 'Light'),
                      NasikoSelectItem(value: ThemeMode.dark, label: 'Dark'),
                      NasikoSelectItem(
                        value: ThemeMode.system,
                        label: 'System',
                      ),
                    ],
                    onChanged: widget.onThemeModeChanged,
                  ),
                ),
                SizedBox(width: spacing.s12),
                SizedBox(
                  width: 160,
                  child: NasikoSelect<NasikoColorPalette>(
                    value: widget.palette,
                    placeholder: 'Palette',
                    items: [
                      for (final palette in NasikoColorPalette.values)
                        NasikoSelectItem(
                          value: palette,
                          label: palette.name[0].toUpperCase() +
                              palette.name.substring(1),
                        ),
                    ],
                    onChanged: widget.onPaletteChanged,
                  ),
                ),
              ],
            ),
          ),
          const NasikoDivider(),
          // ── Nav + content ──────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 232,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: spacing.s8),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) => NasikoListItem(
                      title: _entries[index].title,
                      isSelected: index == _selectedIndex,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  ),
                ),
                const NasikoDivider(axis: NasikoDividerAxis.vertical),
                Expanded(
                  // Keyed so switching pages resets their local demo state.
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIndex),
                    child: _entries[_selectedIndex].builder(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
