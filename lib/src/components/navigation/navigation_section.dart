class NasikoNavigationSection {
  const NasikoNavigationSection({
    required this.id,
    required this.title,
    this.children = const [],
    this.isCollapsible = true,
  });

  final String id;
  final String title;
  final List<NavigationItem> children;
  final bool isCollapsible;
}

class NavigationItem {
  const NavigationItem({required this.id, required this.label, this.onTap});

  final String id;
  final String label;
  final void Function()? onTap;
}
