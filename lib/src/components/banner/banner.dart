// lib/src/components/banner/nasiko_banner.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart'; // Import your main barrel file

import '../internal/overlay_reveal.dart';

/// Defines the layout orientation of the NasikoBanner.
enum NasikoBannerType {
  /// A wide, horizontal layout for larger spaces.
  horizontal,

  /// A compact, vertical layout for smaller spaces.
  vertical,
}

/// A banner component to display prominent messages and actions.
class NasikoBanner extends StatelessWidget {
  const NasikoBanner({
    super.key,
    required this.title,
    required this.content,
    required this.action,
    this.bannerIconImage,
    this.bannerIconData,
    this.bannerType = NasikoBannerType.horizontal,
    this.onClose,
  }) : assert(
         bannerIconImage == null || bannerIconData == null,
         'Provide either bannerIconImage or bannerIconData, not both.',
       );

  /// The main title of the banner.
  final String title;

  /// The icon to display next to the title (use AssetImage or NetworkImage).
  final ImageProvider? bannerIconImage;

  /// The HugeIcon to display next to the title. Takes precedence over [bannerIconImage].
  final HugeIconsType? bannerIconData;

  /// The descriptive text.
  final String content;

  /// The primary action widget (e.g., a NasikoButton).
  final Widget action;

  /// The layout type, horizontal (default) or vertical.
  final NasikoBannerType bannerType;

  /// An optional callback to show a close button.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    // One-shot entrance (fade + slight slide) so appearing banners don't
    // pop in. Paint-only: layout is identical once settled.
    return NasikoOverlayReveal(
      duration: context.motion.base,
      // Select the correct build method based on the type
      child: switch (bannerType) {
        NasikoBannerType.horizontal => _buildHorizontalLayout(context),
        NasikoBannerType.vertical => _buildVerticalLayout(context),
      },
    );
  }

  // --- Horizontal Layout Builder ---
  Widget _buildHorizontalLayout(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        color: colors.backgroundBase, // White
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(
          color: colors.borderPrimary, // neutral/300
        ),
        boxShadow: context.elevation.low,
      ),
      child: Row(
        children: [
          // 1. Content Area (Icon, Title, Description)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    if (bannerIconImage != null || bannerIconData != null) ...[
                      _buildIcon(context, 24),
                      SizedBox(width: spacing.s12),
                    ],
                    // Title & Description
                    _buildTitle(context),
                  ],
                ),
                SizedBox(height: spacing.s8),
                // Description
                Text(
                  content,
                  style: context.typography.bodySecondary.copyWith(
                    color: context.colors.foregroundSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 2. Action Area
          SizedBox(width: spacing.s16),
          Row(
            children: [
              action,
              SizedBox(width: spacing.s8),
              // Close Button
              if (onClose != null)
                TertiaryIconButton(
                  size: NasikoButtonSize.small,
                  onPressed: onClose,
                  icon: HugeIcons.strokeRoundedCancel01,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Vertical Layout Builder ---
  Widget _buildVerticalLayout(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
      width: 280, // A fixed width for the compact vertical view
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        color: colors.backgroundBase, // White
        borderRadius: BorderRadius.circular(radii.r8),
        border: Border.all(
          color: colors.borderPrimary, // neutral/300
          width: borderWidths.w1,
        ),
        boxShadow: context.elevation.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              if (bannerIconImage != null || bannerIconData != null) ...[
                _buildIcon(context, 24),
                SizedBox(width: spacing.s12),
              ],
              // Title
              Expanded(child: _buildTitle(context)),
            ],
          ),
          SizedBox(height: spacing.s12),

          // 2. Content
          Text(
            content,
            style: context.typography.bodySecondary.copyWith(
              color: context.colors.foregroundSecondary,
            ),
          ),
          SizedBox(height: spacing.s16),

          // 3. Action
          // Use an Align to make the button take its natural size
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, double size) {
    if (bannerIconData != null) {
      return HugeIcon(
        icon: bannerIconData!,
        size: size,
        color: context.colors.foregroundPrimary,
      );
    }
    return Image(image: bannerIconImage!, width: size, height: size);
  }

  // --- Shared Title Widget ---
  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: context.typography.bodyPrimaryBold.copyWith(
        color: context.colors.foregroundPrimary,
      ),
    );
  }
}
