// lib/src/components/tabs/nasiko_tab_bar.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// A data class to hold the content for a single [NasikoTabBar] tab.
class NasikoTabItem {
  final String label;

  /// Only Hugeicons library's icon is called
  final HugeIcon? icon;

  /// Disabled tabs render in the disabled foreground color and cannot be
  /// selected (taps revert to the previously selected tab).
  final bool enabled;

  const NasikoTabItem({required this.label, this.icon, this.enabled = true});
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
    this.tabAlignment = TabAlignment.center,
  });

  /// The list of [NasikoTabItem] to display in the bar.
  final List<NasikoTabItem> tabs;

  /// The [TabController] to coordinate with the [TabBarView].
  final TabController? controller;

  /// An optional callback that's called when a tab is tapped.
  final ValueChanged<int>? onTap;

  final TabAlignment? tabAlignment;

  static const double _tabBarHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final borderWidths = context.borderWidth;

    final effectiveController =
        controller ?? DefaultTabController.maybeOf(context);

    return SizedBox(
      height: spacing.s36,
      child: TabBar(
        controller: controller,
        onTap: (index) {
          if (!tabs[index].enabled) {
            // TabBar has already moved the selection; put it back.
            final c = effectiveController;
            if (c != null && c.previousIndex != index) {
              c.index = c.previousIndex;
            }
            return;
          }
          onTap?.call(index);
        },
        isScrollable: true,
        padding: EdgeInsets.zero,
        tabAlignment: tabAlignment,
        labelPadding: EdgeInsets.symmetric(horizontal: spacing.s16),

        // --- Active Tab Styling ---
        labelColor: colors.foregroundBrand,
        labelStyle: typography.bodySecondaryBold,

        // --- Inactive Tab Styling ---
        unselectedLabelColor: colors.foregroundPrimary,
        unselectedLabelStyle: typography.bodySecondaryBold,

        // --- Active Underline (Yellow) ---
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.borderSecondary,
            width: borderWidths.w2,
          ),
          // insets: EdgeInsets.symmetric(horizontal: spacing.s16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,

        // --- Full-Width Underline (Gray) ---
        dividerColor: colors.borderPrimary,
        dividerHeight: borderWidths.w1,

        tabs: tabs.map((item) {
          final icon = item.icon;
          return Tab(
            height: spacing.s36 - borderWidths.w1, // Account for divider
            child: MouseRegion(
              cursor: item.enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    item.enabled
                        ? icon
                        : HugeIcon(
                            icon: icon.icon,
                            size: icon.size,
                            color: colors.foregroundDisabled,
                          ),
                    SizedBox(width: spacing.s8),
                  ],
                  Text(
                    item.label,
                    style: item.enabled
                        ? null
                        : typography.bodySecondaryBold.copyWith(
                            color: colors.foregroundDisabled,
                          ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_tabBarHeight);
}
