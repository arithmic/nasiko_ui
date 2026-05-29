import 'package:nasiko_ui/src/tokens/types.dart';

class NasikoNavigationRailItem {
  const NasikoNavigationRailItem({
    required this.id,
    required this.icon,
    required this.label,
    this.isDisabled = false,
  });

  final String id;
  final HugeIconsType icon;
  final String label;
  final bool isDisabled;
}
