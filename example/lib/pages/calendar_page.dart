import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _calendarValue;
  DateTime? _fieldValue;
  DateTime? _pickerResult;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return GalleryPage(
      title: 'Calendar & Date',
      description:
          'NasikoCalendar month grid, NasikoDateField popover input, and the '
          'showNasikoDatePicker dialog. The grid is fully keyboard-driven: '
          'arrows move the focused day, PageUp/PageDown change month, '
          'Enter selects.',
      children: [
        GallerySection(
          title: 'Calendar — default',
          child: SizedBox(
            width: 320,
            child: NasikoCalendar(
              selected: _calendarValue,
              onChanged: (d) => setState(() => _calendarValue = d),
            ),
          ),
        ),
        GallerySection(
          title: 'Calendar — min/max bounds',
          description: 'Only ±7 days around today are selectable.',
          child: SizedBox(
            width: 320,
            child: NasikoCalendar(
              selected: _calendarValue,
              minDate: today.subtract(const Duration(days: 7)),
              maxDate: today.add(const Duration(days: 7)),
              onChanged: (d) => setState(() => _calendarValue = d),
            ),
          ),
        ),
        GallerySection(
          title: 'Date field',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'enabled',
                child: SizedBox(
                  width: 240,
                  child: NasikoDateField(
                    value: _fieldValue,
                    onChanged: (d) => setState(() => _fieldValue = d),
                  ),
                ),
              ),
              LabeledExample(
                label: 'disabled',
                child: SizedBox(
                  width: 240,
                  child: NasikoDateField(
                    value: _fieldValue,
                    enabled: false,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Date picker dialog',
          child: Row(
            children: [
              SecondaryButton(
                label: 'Open date picker',
                size: NasikoButtonSize.medium,
                onPressed: () async {
                  final picked = await showNasikoDatePicker(
                    context: context,
                    initialDate: _pickerResult ?? today,
                  );
                  if (picked != null) {
                    setState(() => _pickerResult = picked);
                  }
                },
              ),
              SizedBox(width: context.spacing.s16),
              Text(
                _pickerResult == null
                    ? 'Nothing picked yet'
                    : 'Picked: ${_pickerResult!.toIso8601String().split('T').first}',
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
