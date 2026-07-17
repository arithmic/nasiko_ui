// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:nasiko_ui/nasiko_ui.dart';

// const Color _sidebarBg = Color.fromRGBO(240, 235, 225, 1);
// const Color _contentPanel = Color.fromRGBO(251, 248, 242, 1);

// /// External controller for [NasikoSidebar]. Attach one to drive the sidebar
// /// from outside (e.g. a toggle button in the app header) and listen to its
// /// layout state so the consumer can style adjacent UI accordingly.
// class NasikoSidebarController extends ChangeNotifier {
//   VoidCallback? _toggleHandler;

//   bool _isPanelVisible = false;
//   bool _isInlineCollapsed = false;
//   bool _isRailExpanded = false;

//   /// True when a content panel is currently rendered next to the rail.
//   bool get isPanelVisible => _isPanelVisible;

//   /// True when the user has manually collapsed the inline rail (no-panel
//   /// pages only). Meaningless when [isPanelVisible] is true.
//   bool get isInlineCollapsed => _isInlineCollapsed;

//   /// True while the expanded-rail overlay is shown on top of the layout
//   /// (only meaningful when [isPanelVisible] is true).
//   bool get isRailExpanded => _isRailExpanded;

//   /// Attached by [NasikoSidebar] during its lifecycle — not a user API.
//   void attach(VoidCallback handler) => _toggleHandler = handler;

//   /// Detached by [NasikoSidebar] on dispose — not a user API.
//   void detach() => _toggleHandler = null;

//   /// Pushed by [NasikoSidebar] when any layout-relevant state changes — not a
//   /// user API. Emits a notification when at least one field changes.
//   void updateState({
//     required bool isPanelVisible,
//     required bool isInlineCollapsed,
//     required bool isRailExpanded,
//   }) {
//     if (_isPanelVisible == isPanelVisible &&
//         _isInlineCollapsed == isInlineCollapsed &&
//         _isRailExpanded == isRailExpanded) {
//       return;
//     }
//     _isPanelVisible = isPanelVisible;
//     _isInlineCollapsed = isInlineCollapsed;
//     _isRailExpanded = isRailExpanded;
//     notifyListeners();
//   }

//   /// Toggles the sidebar:
//   /// - If a content panel is visible, shows/hides the expanded-rail overlay.
//   /// - If no panel is visible, toggles the inline rail between 240 and 56 px.
//   void toggle() => _toggleHandler?.call();
// }

// /// A nested sidebar with an icon rail and an optional expandable content panel.
// ///
// /// The rail shows icons only by default. A toggle button expands the rail as an
// /// overlay showing icons + labels. The content panel (right side) displays
// /// [Section] widgets for the selected item and auto-hides when the selected
// /// item has no sections.
// class NasikoSidebar extends StatefulWidget {
//   const NasikoSidebar({
//     super.key,
//     required this.items,
//     this.footerItems = const [],
//     this.selectedItemId,
//     this.onItemSelected,
//     this.avatarImageUrl,
//     this.avatarLabel,
//     this.userName,
//     this.userSubtitle,
//     this.isUserLoading = false,
//     this.onAvatarTap,
//     this.panelWidth = 200,
//     this.panelBuilder,
//     this.showPanel = true,
//     this.controller,
//   });

//   final List<NasikoSidebarItem> items;
//   final List<NasikoSidebarFooterItem> footerItems;
//   final String? selectedItemId;
//   final ValueChanged<String>? onItemSelected;
//   final String? avatarImageUrl;
//   final String? avatarLabel;

//   /// Full username shown beside the avatar in the expanded rail. Falls back to
//   /// [avatarLabel] when null.
//   final String? userName;

//   /// Secondary line under [userName] in the expanded rail (e.g. email, role).
//   /// Hidden when null or empty.
//   final String? userSubtitle;

//   /// When true, the avatar (and the username/subtitle in the expanded rail) is
//   /// replaced with a shimmer placeholder. Use this while the user profile is
//   /// being fetched on initial load.
//   final bool isUserLoading;

//   final VoidCallback? onAvatarTap;
//   final double panelWidth;
//   final Widget Function(NasikoSidebarItem item)? panelBuilder;

//   /// When false, only the rail is shown regardless of selected item.
//   final bool showPanel;

//   /// Optional controller that exposes [toggle] for external callers.
//   final NasikoSidebarController? controller;

//   @override
//   State<NasikoSidebar> createState() => _NasikoSidebarState();
// }

// class _NasikoSidebarState extends State<NasikoSidebar>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _animController;
//   late final Animation<Offset> _slideAnim;
//   OverlayEntry? _overlayEntry;
//   // Tracks whether the OverlayEntry is currently shown (panel-mode toggle).
//   bool _isRailExpanded = false;
//   // Tracks whether the user has manually collapsed the inline rail on a
//   // no-panel page (defaults to expanded).
//   bool _isInlineCollapsed = false;

//   static const double _expandedRailWidth = 240;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _slideAnim = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
//         .animate(
//           CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
//         );
//     widget.controller?.attach(_toggleRail);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _syncControllerState();
//     });
//   }

//   @override
//   void dispose() {
//     widget.controller?.detach();
//     _removeOverlayEntry();
//     _animController.dispose();
//     super.dispose();
//   }

//   void _removeOverlayEntry() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   /// Pushes the sidebar's current layout state into the controller so listeners
//   /// (e.g. the app's content container) can restyle themselves.
//   void _syncControllerState() {
//     widget.controller?.updateState(
//       isPanelVisible: _isPanelVisible,
//       isInlineCollapsed: _isInlineCollapsed,
//       isRailExpanded: _isRailExpanded,
//     );
//   }

//   void _insertOverlayEntry() {
//     // Defensive: remove any existing entry before inserting a new one.
//     _removeOverlayEntry();

//     final renderBox = context.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;
//     final origin = renderBox.localToGlobal(Offset.zero);
//     final height = renderBox.size.height;

//     _overlayEntry = OverlayEntry(
//       builder: (_) => Positioned(
//         left: origin.dx,
//         top: origin.dy,
//         width: _expandedRailWidth,
//         height: height,
//         child: Material(
//           color: Colors.transparent,
//           child: SlideTransition(
//             position: _slideAnim,
//             child: _ExpandedRailOverlay(
//               items: widget.items,
//               footerItems: widget.footerItems,
//               selectedItemId: widget.selectedItemId,
//               onItemSelected: _onItemSelected,
//               avatarImageUrl: widget.avatarImageUrl,
//               avatarLabel: widget.avatarLabel,
//               userName: widget.userName,
//               userSubtitle: widget.userSubtitle,
//               isUserLoading: widget.isUserLoading,
//               onAvatarTap: widget.onAvatarTap,
//               isPanelVisible: widget.showPanel,
//             ),
//           ),
//         ),
//       ),
//     );
//     Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
//   }

//   NasikoSidebarItem? get _selectedItem {
//     if (widget.selectedItemId == null) return null;
//     try {
//       return widget.items.firstWhere((i) => i.id == widget.selectedItemId);
//     } catch (_) {
//       return null;
//     }
//   }

//   bool get _isPanelVisible {
//     if (!widget.showPanel) return false;
//     final item = _selectedItem;
//     if (item == null) return false;
//     return item.hasPanel || widget.panelBuilder != null;
//   }

//   void _expandRail() {
//     if (!_isRailExpanded) {
//       setState(() => _isRailExpanded = true);
//       _syncControllerState();
//       _insertOverlayEntry();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _animController.forward();
//       });
//     }
//   }

//   void _collapseRail() {
//     if (_isRailExpanded) {
//       _animController.reverse().then((_) {
//         _removeOverlayEntry();
//         if (mounted) {
//           setState(() => _isRailExpanded = false);
//           _syncControllerState();
//         }
//       });
//     }
//   }

//   void _toggleRail() {
//     if (_isPanelVisible) {
//       // Panel mode: toggle the ephemeral overlay on top of the main layout.
//       if (_isRailExpanded) {
//         _collapseRail();
//       } else {
//         _expandRail();
//       }
//     } else {
//       // No-panel mode: toggle the inline rail between 240 (labels) and 56 (icons).
//       setState(() => _isInlineCollapsed = !_isInlineCollapsed);
//       _syncControllerState();
//     }
//   }

//   void _onItemSelected(String id) {
//     widget.onItemSelected?.call(id);
//     if (!_isRailExpanded) return;
//     // If the newly selected item has no panel, the inline expanded rail will
//     // replace the overlay visually — skip the reverse animation to avoid a
//     // flicker where both render momentarily.
//     NasikoSidebarItem? newItem;
//     for (final item in widget.items) {
//       if (item.id == id) {
//         newItem = item;
//         break;
//       }
//     }
//     if (newItem != null && !newItem.hasPanel) {
//       _removeOverlayEntry();
//       _animController.reset();
//       setState(() => _isRailExpanded = false);
//       _syncControllerState();
//     } else {
//       _collapseRail();
//     }
//   }

//   @override
//   void didUpdateWidget(NasikoSidebar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.controller != oldWidget.controller) {
//       oldWidget.controller?.detach();
//       widget.controller?.attach(_toggleRail);
//     }
//     final selectionChanged = widget.selectedItemId != oldWidget.selectedItemId;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       _overlayEntry?.markNeedsBuild();
//       // Panel-visibility may have flipped (e.g. selecting Orchestrator after
//       // Agent Registry) — push the latest state to the controller regardless.
//       _syncControllerState();
//       if (selectionChanged && _isRailExpanded) {
//         if (_isPanelVisible) {
//           _collapseRail();
//         } else {
//           // Inline expanded rail will replace the overlay — dismiss instantly.
//           _removeOverlayEntry();
//           _animController.reset();
//           setState(() => _isRailExpanded = false);
//           _syncControllerState();
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyboardListener(
//       focusNode: FocusNode(),
//       onKeyEvent: (event) {
//         if (event is KeyDownEvent &&
//             event.logicalKey == LogicalKeyboardKey.escape) {
//           _collapseRail();
//         }
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (_isPanelVisible || _isInlineCollapsed)
//             _SidebarRail(
//               items: widget.items,
//               footerItems: widget.footerItems,
//               selectedItemId: widget.selectedItemId,
//               onItemSelected: _onItemSelected,
//               avatarImageUrl: widget.avatarImageUrl,
//               avatarLabel: widget.avatarLabel,
//               isUserLoading: widget.isUserLoading,
//               onAvatarTap: widget.onAvatarTap,
//             )
//           else
//             SizedBox(
//               width: _expandedRailWidth,
//               child: _ExpandedRailOverlay(
//                 items: widget.items,
//                 footerItems: widget.footerItems,
//                 selectedItemId: widget.selectedItemId,
//                 onItemSelected: _onItemSelected,
//                 avatarImageUrl: widget.avatarImageUrl,
//                 avatarLabel: widget.avatarLabel,
//                 userName: widget.userName,
//                 userSubtitle: widget.userSubtitle,
//                 isUserLoading: widget.isUserLoading,
//                 onAvatarTap: widget.onAvatarTap,
//                 showShadow: false,
//                 isPanelVisible: _isPanelVisible,
//               ),
//             ),
//           if (_isPanelVisible) ...[
//             SizedBox(
//               width: widget.panelWidth,
//               child: _SidebarPanel(
//                 item: _selectedItem!,
//                 panelBuilder: widget.panelBuilder,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Sidebar Rail (collapsed, icons only)
// // ─────────────────────────────────────────────────────────────────────────────

// class _SidebarRail extends StatelessWidget {
//   const _SidebarRail({
//     required this.items,
//     required this.footerItems,
//     required this.selectedItemId,
//     required this.onItemSelected,
//     this.avatarImageUrl,
//     this.avatarLabel,
//     this.isUserLoading = false,
//     this.onAvatarTap,
//   });

//   final List<NasikoSidebarItem> items;
//   final List<NasikoSidebarFooterItem> footerItems;
//   final String? selectedItemId;
//   final ValueChanged<String> onItemSelected;
//   final String? avatarImageUrl;
//   final String? avatarLabel;
//   final bool isUserLoading;
//   final VoidCallback? onAvatarTap;

//   @override
//   Widget build(BuildContext context) {
//     final spacing = context.spacing;
//     return Container(
//       width: 56,
//       color: _sidebarBg,
//       padding: EdgeInsets.symmetric(vertical: spacing.s12),
//       child: Column(
//         children: [
//           // Nav items
//           ...items.map(
//             (item) => Padding(
//               padding: EdgeInsets.only(bottom: spacing.s4),
//               child: _RailIconButton(
//                 icon: item.icon,
//                 isSelected: item.id == selectedItemId,
//                 isDisabled: item.isDisabled,
//                 onTap: () => onItemSelected(item.id),
//                 tooltip: item.label,
//               ),
//             ),
//           ),
//           const Spacer(),
//           // Footer items
//           ...footerItems.map(
//             (item) => Padding(
//               padding: EdgeInsets.only(bottom: spacing.s4),
//               child: _RailIconButton(
//                 icon: item.icon,
//                 isSelected: false,
//                 isDisabled: item.isDisabled,
//                 onTap: item.onTap,
//                 tooltip: item.label,
//               ),
//             ),
//           ),
//           SizedBox(height: spacing.s8),
//           // Avatar — shimmer placeholder while user profile is loading.
//           if (isUserLoading)
//             const _ShimmerBlock(width: 36, height: 36, radius: 8)
//           else
//             GestureDetector(
//               onTap: onAvatarTap,
//               child: NasikoAvatar(
//                 size: NasikoAvatarSize.small,
//                 shape: NasikoAvatarShape.square,
//                 imageUrl: avatarImageUrl,
//                 text: avatarLabel,
//                 backgroundColor: context.colors.foregroundConstantBlack,
//                 foregroundColor: context.colors.foregroundConstantWhite,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Rail icon button with hover + selected states
// // ─────────────────────────────────────────────────────────────────────────────

// class _RailIconButton extends StatefulWidget {
//   const _RailIconButton({
//     required this.icon,
//     required this.isSelected,
//     this.isDisabled = false,
//     this.onTap,
//     this.tooltip,
//   });

//   final HugeIconsType icon;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback? onTap;
//   final String? tooltip;

//   @override
//   State<_RailIconButton> createState() => _RailIconButtonState();
// }

// class _RailIconButtonState extends State<_RailIconButton> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final radii = context.radius;
//     final iconSizes = context.iconSize;
//     final borderWidths = context.borderWidth;

//     Color bgColor = Colors.transparent;
//     Color borderColor = Colors.transparent;
//     Color iconColor = colors.foregroundIconPrimary;

//     if (widget.isDisabled) {
//       iconColor = colors.foregroundDisabled;
//     } else if (widget.isSelected) {
//       bgColor = colors.backgroundBase;
//       borderColor = colors.borderSecondary;
//       iconColor = colors.foregroundIconPrimary;
//     } else if (_isHovered) {
//       borderColor = colors.borderSecondary;
//       iconColor = colors.foregroundIconPrimary;
//     }

//     final button = MouseRegion(
//       cursor: widget.isDisabled
//           ? SystemMouseCursors.basic
//           : SystemMouseCursors.click,
//       onEnter: widget.isDisabled
//           ? null
//           : (_) => setState(() => _isHovered = true),
//       onExit: widget.isDisabled
//           ? null
//           : (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTap: widget.isDisabled ? null : widget.onTap,
//         child: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(radii.r8),
//             border: Border.all(color: borderColor, width: borderWidths.w1),
//           ),
//           child: Center(
//             child: HugeIcon(
//               icon: widget.icon,
//               size: iconSizes.s,
//               color: iconColor,
//             ),
//           ),
//         ),
//       ),
//     );

//     if (widget.tooltip != null) {
//       return Tooltip(message: widget.tooltip!, child: button);
//     }
//     return button;
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Sidebar Panel (content area)
// // ─────────────────────────────────────────────────────────────────────────────

// class _SidebarPanel extends StatelessWidget {
//   const _SidebarPanel({required this.item, this.panelBuilder});

//   final NasikoSidebarItem item;
//   final Widget Function(NasikoSidebarItem item)? panelBuilder;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final spacing = context.spacing;
//     final typography = context.typography;
//     final borderWidths = context.borderWidth;
//     final radii = context.radius;

//     if (panelBuilder != null) {
//       return Container(color: _sidebarBg, child: panelBuilder!(item));
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: _contentPanel,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(radii.r8),
//           bottomLeft: Radius.circular(radii.r8),
//         ),
//         border: Border.all(color: colors.borderPrimary, width: borderWidths.w1),
//       ),
//       padding: EdgeInsets.symmetric(vertical: spacing.s12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Panel title
//           Padding(
//             padding: EdgeInsets.symmetric(
//               vertical: spacing.s8,
//               horizontal: spacing.s16,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     item.label,
//                     style: typography.bodyPrimaryBold.copyWith(
//                       color: colors.foregroundPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: spacing.s4),
//           // Sections as simple headers + text lists, separated by dividers
//           Expanded(child: ListView(children: _buildSectionList(item.sections))),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildSectionList(List<NasikoSidebarSection>? sections) {
//     if (sections == null || sections.isEmpty) return [];
//     final List<Widget> widgets = [];
//     for (int i = 0; i < sections.length; i++) {
//       if (i >= 0) {
//         widgets.add(
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 4),
//             child: NasikoDivider(),
//           ),
//         );
//       }
//       widgets.add(_PanelSection(section: sections[i]));
//     }
//     return widgets;
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Panel section: uppercase header + plain text items
// // ─────────────────────────────────────────────────────────────────────────────

// class _PanelSection extends StatefulWidget {
//   const _PanelSection({required this.section});

//   final NasikoSidebarSection section;

//   @override
//   State<_PanelSection> createState() => _PanelSectionState();
// }

// class _PanelSectionState extends State<_PanelSection> {
//   bool _isExpanded = true;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final spacing = context.spacing;
//     final typography = context.typography;
//     final iconSizes = context.iconSize;

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: spacing.s16,
//         left: spacing.s16,
//         right: spacing.s16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section header row
//           GestureDetector(
//             onTap: widget.section.isCollapsible
//                 ? () => setState(() => _isExpanded = !_isExpanded)
//                 : null,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: spacing.s4),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.section.title.toUpperCase(),
//                       style: typography.bodyTertiaryBold,
//                     ),
//                   ),
//                   if (widget.section.trailingIcon != null)
//                     GestureDetector(
//                       onTap: widget.section.onTrailingIconTap,
//                       child: HugeIcon(
//                         icon: widget.section.trailingIcon!,
//                         size: iconSizes.xs,
//                         color: colors.foregroundIconPrimary,
//                       ),
//                     ),
//                   if (widget.section.isCollapsible)
//                     AnimatedRotation(
//                       turns: _isExpanded ? 0.5 : 0,
//                       duration: const Duration(milliseconds: 200),
//                       child: Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         size: iconSizes.xs,
//                         color: colors.foregroundIconPrimary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           // Items
//           if (_isExpanded) ...[
//             SizedBox(height: spacing.s4),
//             if (widget.section.isLoading)
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: spacing.s8),
//                 child: Text(
//                   'Loading...',
//                   style: typography.bodySecondary.copyWith(
//                     color: colors.foregroundPrimary,
//                   ),
//                 ),
//               )
//             else if (widget.section.children == null ||
//                 widget.section.children!.isEmpty)
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: spacing.s8),
//                 child: Text(
//                   widget.section.emptyMessage ?? '',
//                   style: typography.bodySecondary.copyWith(
//                     color: colors.foregroundPrimary,
//                   ),
//                 ),
//               )
//             else
//               ...widget.section.children!.map((child) {
//                 final isSelected =
//                     (child.id ?? child.label) == widget.section.selectedChildId;
//                 return Padding(
//                   padding: EdgeInsets.only(bottom: spacing.s4),
//                   child: _PanelItem(
//                     item: child,
//                     isSelected: isSelected,
//                     onTap: () {
//                       child.onTap?.call();
//                       widget.section.onChildTap?.call(child.id ?? child.label);
//                     },
//                   ),
//                 );
//               }),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Panel item: simple text row with hover/selected state
// // ─────────────────────────────────────────────────────────────────────────────

// class _PanelItem extends StatefulWidget {
//   const _PanelItem({
//     required this.item,
//     required this.isSelected,
//     required this.onTap,
//   });
//   final SectionItem item;
//   final bool isSelected;
//   final VoidCallback onTap;

//   @override
//   State<_PanelItem> createState() => _PanelItemState();
// }

// class _PanelItemState extends State<_PanelItem> {
//   bool _isHovered = false;
//   // Guards against the row's onTap firing when the user clicks the popup menu
//   // trigger — pointer-down on the menu button precedes the row's tap event.
//   bool _isMenuPointerDown = false;

//   bool get _hasMenu =>
//       widget.item.menuActions != null && widget.item.menuActions!.isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final spacing = context.spacing;
//     final radii = context.radius;
//     final typography = context.typography;
//     final borderWidths = context.borderWidth;

//     Color bgColor = Colors.transparent;
//     Color borderColor = Colors.transparent;

//     if (widget.isSelected) {
//       bgColor = colors.backgroundBase;
//       borderColor = colors.borderSecondary;
//     } else if (_isHovered) {
//       borderColor = colors.borderSecondary;
//     }

//     final showMenu = _hasMenu && (_isHovered || widget.isSelected);

//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () {
//           if (_isMenuPointerDown) return;
//           widget.onTap();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: spacing.s8,
//             vertical: spacing.s8,
//           ),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(radii.r8),
//             border: Border.all(color: borderColor, width: borderWidths.w1),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   widget.item.label,
//                   maxLines: widget.item.maxLines,
//                   overflow: widget.item.maxLines != null
//                       ? TextOverflow.ellipsis
//                       : null,
//                   style: typography.bodySecondary.copyWith(
//                     color: colors.foregroundPrimary,
//                     fontWeight: widget.isSelected
//                         ? FontWeight(500)
//                         : FontWeight(400),
//                   ),
//                 ),
//               ),
//               if (showMenu)
//                 Listener(
//                   behavior: HitTestBehavior.opaque,
//                   onPointerDown: (_) => _isMenuPointerDown = true,
//                   onPointerUp: (_) => _isMenuPointerDown = false,
//                   onPointerCancel: (_) => _isMenuPointerDown = false,
//                   child: _PanelItemMenuButton(
//                     actions: widget.item.menuActions!,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Three-dot popup menu rendered at the end of a [_PanelItem] when it has
// /// [SectionItem.menuActions] and is hovered or selected.
// class _PanelItemMenuButton extends StatelessWidget {
//   const _PanelItemMenuButton({required this.actions});

//   final List<SectionItemAction> actions;

//   void _openMenu(BuildContext context) {
//     NasikoPopover.show(
//       context: context,
//       anchorContext: context,
//       items: [
//         for (final action in actions)
//           NasikoPopupMenuItemData(
//             label: action.label,
//             icon: action.icon,
//             isDestructive: action.isDestructive,
//           ),
//       ],
//       onSelect: (index) => actions[index].onTap(),
//       width: 160,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final spacing = context.spacing;
//     final iconSizes = context.iconSize;

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () => _openMenu(context),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Padding(
//           padding: EdgeInsets.only(left: spacing.s4),
//           child: HugeIcon(
//             icon: HugeIcons.strokeRoundedMoreHorizontal,
//             size: iconSizes.s - 2,
//             color: colors.foregroundSecondary,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Expanded rail overlay (icons + labels)
// // ─────────────────────────────────────────────────────────────────────────────

// class _ExpandedRailOverlay extends StatelessWidget {
//   const _ExpandedRailOverlay({
//     required this.items,
//     required this.footerItems,
//     required this.selectedItemId,
//     required this.onItemSelected,
//     this.avatarImageUrl,
//     this.avatarLabel,
//     this.userName,
//     this.userSubtitle,
//     this.isUserLoading = false,
//     this.onAvatarTap,
//     this.showShadow = true,
//     required this.isPanelVisible,
//   });

//   final List<NasikoSidebarItem> items;
//   final List<NasikoSidebarFooterItem> footerItems;
//   final String? selectedItemId;
//   final ValueChanged<String> onItemSelected;
//   final String? avatarImageUrl;
//   final String? avatarLabel;
//   final String? userName;
//   final String? userSubtitle;
//   final bool isUserLoading;
//   final VoidCallback? onAvatarTap;
//   final bool showShadow;
//   final bool isPanelVisible;

//   @override
//   Widget build(BuildContext context) {
//     final spacing = context.spacing;
//     final colors = context.colors;
//     final typography = context.typography;
//     final borderWidths = context.borderWidth;
//     final content = Container(
//       decoration: BoxDecoration(
//         color: _sidebarBg,
//         // Only draw the internal rail/panel divider when panel is visible.
//         // The outer boundary between sidebar and app content is owned by the
//         // consumer (via NasikoSidebarController state).
//         border: isPanelVisible
//             ? Border(
//                 right: BorderSide(
//                   color: colors.borderPrimary,
//                   width: borderWidths.w1,
//                 ),
//               )
//             : null,
//       ),
//       padding: EdgeInsets.symmetric(
//         vertical: spacing.s12,
//         horizontal: spacing.s12,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Nav items with labels
//           ...items.map(
//             (item) => Padding(
//               padding: EdgeInsets.only(bottom: spacing.s4),
//               child: _ExpandedRailItem(
//                 icon: item.icon,
//                 label: item.label,
//                 isSelected: item.id == selectedItemId,
//                 isDisabled: item.isDisabled,
//                 onTap: () => onItemSelected(item.id),
//               ),
//             ),
//           ),
//           const Spacer(),
//           // Footer items with labels
//           ...footerItems.map(
//             (item) => Padding(
//               padding: EdgeInsets.only(bottom: spacing.s4),
//               child: _ExpandedRailItem(
//                 icon: item.icon,
//                 label: item.label,
//                 isSelected: false,
//                 isDisabled: item.isDisabled,
//                 onTap: item.onTap,
//               ),
//             ),
//           ),
//           SizedBox(height: spacing.s8),
//           // Avatar row — shimmer placeholder while loading, otherwise the
//           // username (with optional subtitle like email/role) next to the avatar.
//           if (isUserLoading)
//             Row(
//               children: [
//                 const _ShimmerBlock(width: 36, height: 36, radius: 8),
//                 SizedBox(width: spacing.s8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const _ShimmerBlock(width: 110, height: 12),
//                       SizedBox(height: spacing.s4),
//                       const _ShimmerBlock(width: 150, height: 10),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           else
//             GestureDetector(
//               onTap: onAvatarTap,
//               child: Row(
//                 children: [
//                   NasikoAvatar(
//                     size: NasikoAvatarSize.small,
//                     shape: NasikoAvatarShape.square,
//                     imageUrl: avatarImageUrl,
//                     text: avatarLabel,
//                     backgroundColor: context.colors.foregroundConstantBlack,
//                     foregroundColor: context.colors.foregroundConstantWhite,
//                   ),
//                   if (userName != null || avatarLabel != null) ...[
//                     SizedBox(width: spacing.s8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             userName ?? avatarLabel!,
//                             style: typography.bodySecondary.copyWith(
//                               color: colors.foregroundPrimary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           if (userSubtitle != null &&
//                               userSubtitle!.isNotEmpty) ...[
//                             SizedBox(height: spacing.s2),
//                             Text(
//                               userSubtitle!,
//                               style: typography.bodyTertiary.copyWith(
//                                 color: colors.foregroundSecondary,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );

//     if (!showShadow) return content;

//     return DecoratedBox(
//       decoration: const BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromRGBO(51, 65, 85, 0.12),
//             offset: Offset(4, 0),
//             blurRadius: 15.8,
//           ),
//         ],
//       ),
//       child: content,
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Expanded rail item (icon + label row with hover/selected states)
// // ─────────────────────────────────────────────────────────────────────────────

// class _ExpandedRailItem extends StatefulWidget {
//   const _ExpandedRailItem({
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     this.isDisabled = false,
//     this.onTap,
//   });

//   final HugeIconsType icon;
//   final String label;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback? onTap;

//   @override
//   State<_ExpandedRailItem> createState() => _ExpandedRailItemState();
// }

// class _ExpandedRailItemState extends State<_ExpandedRailItem> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final spacing = context.spacing;
//     final radii = context.radius;
//     final typography = context.typography;
//     final iconSizes = context.iconSize;
//     final borderWidths = context.borderWidth;

//     Color bgColor = Colors.transparent;
//     Color borderColor = Colors.transparent;
//     Color iconColor = colors.foregroundIconPrimary;
//     Color textColor = colors.foregroundPrimary;

//     if (widget.isDisabled) {
//       iconColor = colors.foregroundDisabled;
//       textColor = colors.foregroundDisabled;
//     } else if (widget.isSelected) {
//       bgColor = colors.backgroundBase;
//       borderColor = colors.borderSecondary;
//       iconColor = colors.foregroundIconPrimary;
//       textColor = colors.foregroundPrimary;
//     } else if (_isHovered) {
//       borderColor = colors.borderSecondary;
//       iconColor = colors.foregroundIconPrimary;
//       textColor = colors.foregroundPrimary;
//     }

//     return MouseRegion(
//       cursor: widget.isDisabled
//           ? SystemMouseCursors.basic
//           : SystemMouseCursors.click,
//       onEnter: widget.isDisabled
//           ? null
//           : (_) => setState(() => _isHovered = true),
//       onExit: widget.isDisabled
//           ? null
//           : (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTap: widget.isDisabled ? null : widget.onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: spacing.s8,
//             vertical: spacing.s8,
//           ),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(radii.r8),
//             border: Border.all(color: borderColor, width: borderWidths.w1),
//           ),
//           child: Row(
//             children: [
//               HugeIcon(icon: widget.icon, size: iconSizes.s, color: iconColor),
//               SizedBox(width: spacing.s8),
//               Expanded(
//                 child: Text(
//                   widget.label,
//                   style: typography.bodySecondary.copyWith(
//                     color: textColor,
//                     fontWeight: widget.isSelected
//                         ? FontWeight(500)
//                         : FontWeight(400),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Shimmer placeholder used by the user/avatar area while the profile loads.
// // ─────────────────────────────────────────────────────────────────────────────

// class _ShimmerBlock extends StatefulWidget {
//   const _ShimmerBlock({
//     required this.width,
//     required this.height,
//     this.radius,
//   });

//   final double width;
//   final double height;

//   /// Corner radius. Defaults to a pill (height / 2) — pass an explicit value
//   /// to match a non-pill shape (e.g. a rounded-square avatar).
//   final double? radius;

//   @override
//   State<_ShimmerBlock> createState() => _ShimmerBlockState();
// }

// class _ShimmerBlockState extends State<_ShimmerBlock>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1300),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tonal pair tuned to read against the beige sidebar background.
//     const baseColor = Color.fromRGBO(225, 220, 210, 1);
//     const highlightColor = Color.fromRGBO(245, 240, 232, 1);
//     final radius = BorderRadius.circular(widget.radius ?? widget.height / 2);
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, _) {
//         return ShaderMask(
//           blendMode: BlendMode.srcATop,
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               colors: const [
//                 baseColor,
//                 baseColor,
//                 highlightColor,
//                 baseColor,
//                 baseColor,
//               ],
//               stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               transform: _SlidingGradientTransform(_controller.value),
//             ).createShader(bounds);
//           },
//           child: Container(
//             width: widget.width,
//             height: widget.height,
//             decoration: BoxDecoration(color: baseColor, borderRadius: radius),
//           ),
//         );
//       },
//     );
//   }
// }

// class _SlidingGradientTransform extends GradientTransform {
//   const _SlidingGradientTransform(this.progress);

//   final double progress;

//   @override
//   Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
//     final dx = bounds.width * (progress * 2.8 - 1.4);
//     return Matrix4.translationValues(dx, 0, 0);
//   }
// }
