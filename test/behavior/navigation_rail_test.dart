import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('expanding a hovered rail item does not hide a detached portal', (
    tester,
  ) async {
    late StateSetter setExpanded;
    var isExpanded = false;

    await pumpNasiko(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          setExpanded = setState;
          return SizedBox(
            width: 220,
            height: 300,
            child: NasikoNavigationRail(
              items: const [
                NasikoNavigationRailItem(
                  id: 'home',
                  label: 'Home',
                  icon: HugeIcons.strokeRoundedHome01,
                ),
              ],
              selectedId: null,
              onSelect: (_) {},
              isExpanded: isExpanded,
            ),
          );
        },
      ),
    );

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(pointer.removePointer);
    await pointer.addPointer(location: const Offset(1200, 700));
    await pointer.moveTo(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    setExpanded(() => isExpanded = true);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
