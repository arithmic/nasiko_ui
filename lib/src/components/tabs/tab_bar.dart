// lib/src/components/tabs/nasiko_tab_bar.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A data class to hold the content for a single [NasikoTabBar] tab.
class NasikoTabItem {
  final String label;
  final IconData icon;

  const NasikoTabItem({required this.label, required this.icon});
}

/// A horizontal, scrollable tab bar for the Nasiko Design System.
///
/// This widget must be used with a [TabController]. It is recommended
/// to wrap this component in a [DefaultTabController] in your screen.
class NasikoTabBar extends StatelessWidget implements PreferredSizeWidget {
  const NasikoTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
  });

  /// The list of [NasikoTabItem] to display in the bar.
  final List<NasikoTabItem> tabs;

  /// The [TabController] to coordinate with the [TabBarView].
  final TabController? controller;

  /// An optional callback that's called when a tab is tapped.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final borderWidths = context.borderWidth;
    final iconSizes = context.iconSize;

    return TabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: true, // Allows horizontal scrolling
      padding: EdgeInsets.zero,

      // *** FIX: Set tabAlignment to prevent automatic scrollbar ***
      tabAlignment: TabAlignment.start,

      // Padding for each individual tab
      labelPadding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s12,
      ),

      // --- Active Tab Styling ---
      labelColor: colors.foregroundBrand, // yellow/600
      labelStyle: typography.bodySecondaryBold,

      // --- Inactive Tab Styling ---
      unselectedLabelColor: colors.foregroundSecondary, // neutral/500
      unselectedLabelStyle: typography.bodySecondaryBold,

      // --- Active Underline (Yellow) ---
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: colors.borderSecondary, // yellow/600
          width: borderWidths.w2, // 2px
        ),
      ),
      indicatorSize: TabBarIndicatorSize.label, // Confines line to the label
      // --- Full-Width Underline (Gray) ---
      dividerColor: colors.borderPrimary, // neutral/300
      dividerHeight: borderWidths.w1, // 1px
      // Build the list of Tab widgets
      tabs: tabs.map((item) {
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: iconSizes.s, // 20px
              ),
              SizedBox(width: spacing.s8),
              Text(item.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
