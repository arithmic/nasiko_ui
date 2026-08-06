import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class TimePickerPage extends StatefulWidget {
  const TimePickerPage({super.key});

  @override
  State<TimePickerPage> createState() => _TimePickerPageState();
}

class _TimePickerPageState extends State<TimePickerPage> {
  NasikoTimeOfDay? _h24 = const NasikoTimeOfDay(hour: 13, minute: 30);
  NasikoTimeOfDay? _amPm;
  NasikoTimeOfDay? _seconds;
  NasikoTimeOfDay? _clamped = const NasikoTimeOfDay(hour: 9, minute: 0);
  NasikoTimeOfDay? _fieldValue;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Time Picker',
      description:
          'Segmented time entry: digits type with auto-advance, Up/Down '
          'arrows step with wrap-around, Left/Right move between segments. '
          'NasikoTimeField wraps the picker in a popover.',
      children: [
        GallerySection(
          title: '24-hour',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: _h24 == null ? 'no value' : _h24!.format24(),
                child: NasikoTimePicker(
                  value: _h24,
                  onChanged: (v) => setState(() => _h24 = v),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'AM / PM',
          description: 'A or P set the period; Space/Enter/arrows toggle it.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: _amPm == null ? 'no value' : _amPm!.format12(),
                child: NasikoTimePicker(
                  mode: NasikoTimePickerMode.amPm,
                  value: _amPm,
                  onChanged: (v) => setState(() => _amPm = v),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'With seconds',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: _seconds == null
                    ? 'no value'
                    : _seconds!.format24(withSeconds: true),
                child: NasikoTimePicker(
                  showSeconds: true,
                  value: _seconds,
                  onChanged: (v) => setState(() => _seconds = v),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Min / max clamped',
          description: 'Completed values outside 09:00–17:00 snap to the '
              'nearest bound.',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: _clamped == null ? 'no value' : _clamped!.format24(),
                child: NasikoTimePicker(
                  value: _clamped,
                  minTime: const NasikoTimeOfDay(hour: 9, minute: 0),
                  maxTime: const NasikoTimeOfDay(hour: 17, minute: 0),
                  onChanged: (v) => setState(() => _clamped = v),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Disabled',
          child: ExampleWrap(
            children: [
              LabeledExample(
                label: 'enabled: false',
                child: NasikoTimePicker(
                  value: const NasikoTimeOfDay(hour: 10, minute: 15),
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'NasikoTimeField',
          description:
              'Read-only field opening the picker in a popover. Enter, '
              'Space, or Arrow-Down open it from the keyboard.',
          child: SizedBox(
            width: 240,
            child: NasikoTimeField(
              value: _fieldValue,
              mode: NasikoTimePickerMode.amPm,
              onChanged: (v) => setState(() => _fieldValue = v),
            ),
          ),
        ),
      ],
    );
  }
}
