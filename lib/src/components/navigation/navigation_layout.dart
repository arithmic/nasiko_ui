import 'package:flutter/material.dart';

class NasikoNavigationLayout extends StatelessWidget {
  const NasikoNavigationLayout({super.key, required this.rail, this.panel});

  final Widget rail;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    return Row(children: [rail, if (panel != null) panel!]);
  }
}
