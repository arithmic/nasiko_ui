import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class InputOtpPage extends StatefulWidget {
  const InputOtpPage({super.key});

  @override
  State<InputOtpPage> createState() => _InputOtpPageState();
}

class _InputOtpPageState extends State<InputOtpPage> {
  bool _hasError = true;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Input OTP',
      description:
          'One-time-code entry as character slots. Tap anywhere to focus; '
          'typing fills left to right, backspace steps back, and pasting '
          'distributes across the slots.',
      children: [
        GallerySection(
          title: 'Six digits, grouped [3, 3]',
          description: 'Completing the code shows a toast (onCompleted).',
          child: NasikoInputOtp(
            length: 6,
            groups: const [3, 3],
            onCompleted: (code) =>
                NasikoToastService.showSuccess(context, 'Code $code entered.'),
          ),
        ),
        const GallerySection(
          title: 'Single group',
          child: NasikoInputOtp(length: 4),
        ),
        const GallerySection(
          title: 'Alphanumeric',
          description: 'alphanumeric: true widens the filter to A-Z and 0-9.',
          child: NasikoInputOtp(length: 6, alphanumeric: true),
        ),
        GallerySection(
          title: 'Error state',
          description: 'hasError swaps every slot border to the error color.',
          child: Row(
            children: [
              NasikoInputOtp(
                length: 6,
                groups: const [3, 3],
                hasError: _hasError,
              ),
              SizedBox(width: context.spacing.s16),
              NasikoSwitch(
                value: _hasError,
                onChanged: (v) => setState(() => _hasError = v),
              ),
            ],
          ),
        ),
        const GallerySection(
          title: 'Disabled',
          child: NasikoInputOtp(length: 6, enabled: false),
        ),
      ],
    );
  }
}
