// lib/src/components/tabs/nasiko_tab_bar.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A data class to hold the content for a single [NasikoTabBar] tab.
class NasikoTabItem {
  final String label;

  /// Only Hugeicons library's icon is called
  final HugeIcon icon;

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

  static const double _tabBarHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final borderWidths = context.borderWidth;

    return SizedBox(
      height: _tabBarHeight,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: true,
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,

        labelPadding: EdgeInsets.symmetric(horizontal: spacing.s16),

        // --- Active Tab Styling ---
        labelColor: colors.foregroundBrand,
        labelStyle: typography.bodySecondaryBold,

        // --- Inactive Tab Styling ---
        unselectedLabelColor: colors.foregroundSecondary,
        unselectedLabelStyle: typography.bodySecondaryBold,

        // --- Active Underline (Yellow) ---
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w2,
          ),
          insets: EdgeInsets.symmetric(horizontal: spacing.s16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,

        // --- Full-Width Underline (Gray) ---
        dividerColor: colors.borderPrimary,
        dividerHeight: borderWidths.w1,

        tabs: tabs.map((item) {
          return Tab(
            height: _tabBarHeight - borderWidths.w1, // Account for divider
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                item.icon,
                SizedBox(width: spacing.s8),
                Text(item.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_tabBarHeight);
}
