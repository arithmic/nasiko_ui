// lib/src/components/banner/nasiko_banner.dart

import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart'; // Import your main barrel file

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
    this.bannerIcon,
    this.bannerType = NasikoBannerType.horizontal,
    this.onClose,
  });

  /// The main title of the banner.
  final String title;

  /// The icon to display next to the title (use AssetImage or NetworkImage).
  final ImageProvider? bannerIcon;

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
    // Select the correct build method based on the type
    return switch (bannerType) {
      NasikoBannerType.horizontal => _buildHorizontalLayout(context),
      NasikoBannerType.vertical => _buildVerticalLayout(context),
    };
  }

  // --- Horizontal Layout Builder ---
  Widget _buildHorizontalLayout(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final borderWidths = context.borderWidth;

    return Container(
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        color: colors.backgroundBase, // White
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(
          color: colors.borderPrimary, // neutral/300
          width: borderWidths.w1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Content Area (Icon, Title, Description)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                if (bannerIcon != null) ...[
                  Image(
                    image: bannerIcon!,
                    width: 32, // Fixed size
                    height: 32,
                  ),
                  SizedBox(width: spacing.s12),
                ],
                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildTitle(context),
                      SizedBox(height: spacing.s4),
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
              ],
            ),
          ),

          // 2. Action Area
          SizedBox(width: spacing.s16),
          action,
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
        borderRadius: BorderRadius.circular(radii.r12),
        border: Border.all(
          color: colors.borderPrimary, // neutral/300
          width: borderWidths.w1,
        ),
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
              if (bannerIcon != null) ...[
                Image(image: bannerIcon!, width: 32, height: 32),
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

  // --- Shared Title Widget ---
  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Text
        Expanded(
          child: Text(
            title,
            style: context.typography.bodyPrimaryBold.copyWith(
              color: context.colors.foregroundPrimary,
            ),
          ),
        ),
        // Close Button
        if (onClose != null)
          InkWell(
            onTap: onClose,
            child: Icon(
              Icons.close,
              size: context.iconSize.s, // 20px
              color: context.colors.foregroundSecondary,
            ),
          ),
      ],
    );
  }
}
