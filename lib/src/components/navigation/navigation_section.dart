class NasikoNavigationSection {
  const NasikoNavigationSection({
    required this.id,
    required this.title,
    this.children = const [],
    this.isCollapsible = true,
  });

  final String id;
  final String title;
  final List<NasikoNavigationItem> children;
  final bool isCollapsible;
}

class NasikoNavigationItem {
  const NasikoNavigationItem({
    required this.id,
    required this.label,
    this.onTap,
  });

  final String id;
  final String label;
  final void Function()? onTap;
}
