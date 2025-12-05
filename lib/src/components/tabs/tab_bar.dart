// lib/src/components/tabs/nasiko_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/src/tokens/tokens.dart';

/// A data class to hold the content for a single [NasikoTabBar] tab.
class NasikoTabItem {
  final String label;

  /// Only Hugeicons library's icon is used
  final HugeIcon icon;

  const NasikoTabItem({required this.label, required this.icon});
}

/// A horizontal, scrollable tab bar for the Nasiko Design System.
///
/// This widget implements [PreferredSizeWidget] so it can be measured by parent widgets.
class NasikoTabBar extends StatelessWidget implements PreferredSizeWidget {
  const NasikoTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
  });

  final List<NasikoTabItem> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final borderWidths = context.borderWidth;

    // Wrap TabBar in Center to horizontally center the scrollable group
    return Center(
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: true,
        padding: EdgeInsets.zero,

        // Center the whole scrollable tab group
        tabAlignment: TabAlignment.center,

        // Padding for each individual tab
        labelPadding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),

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
        ),
        indicatorSize: TabBarIndicatorSize.label,

        // --- Full-Width Underline (Gray) ---
        dividerColor: colors.borderPrimary,
        dividerHeight: borderWidths.w1,

        tabs: tabs.map((item) {
          return Tab(
            child: Row(
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

  // Provide preferredSize so parents can measure height of this widget.
  // kTextTabBarHeight is Flutter's default TabBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
