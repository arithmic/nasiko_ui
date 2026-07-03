import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Shared wrapper that renders the loading / error / empty states for every
/// Nasiko chart, and delegates to [builder] for the loaded state.
///
/// Each chart widget owns a fixed [height] so all four states occupy the same
/// box and there is no layout jump when the state changes.
class NasikoChartFrame extends StatelessWidget {
  const NasikoChartFrame({
    super.key,
    required this.state,
    required this.height,
    required this.builder,
    this.onRetry,
    this.loadingLabel = 'Loading...',
    this.errorLabel = "Couldn't load chart",
    this.emptyLabel = 'Not enough data to chart yet',
    this.emptyIcon = HugeIcons.strokeRoundedInformationDiamond,
    this.errorIcon = HugeIcons.strokeRoundedAlert02,
  });

  /// Which state to render.
  final NasikoChartState state;

  /// Fixed height for the chart body and all placeholder states.
  final double height;

  /// Builds the loaded chart body.
  final WidgetBuilder builder;

  /// Called when the user taps Retry in the error state. When null, no Retry
  /// button is shown.
  final VoidCallback? onRetry;

  final String loadingLabel;
  final String errorLabel;
  final String emptyLabel;
  final HugeIconsType emptyIcon;
  final HugeIconsType errorIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;

    // The loaded chart body gets full padding; placeholder states use lighter
    // vertical padding so their centred icon + label + action still fit at the
    // chart's height.
    final isLoaded = state == NasikoChartState.loaded;
    final padding = EdgeInsets.symmetric(
      horizontal: spacing.s16,
      vertical: isLoaded ? spacing.s16 : spacing.s8,
    );

    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundGroup,
        borderRadius: BorderRadius.circular(radii.r12),
      ),
      child: switch (state) {
        NasikoChartState.loaded => builder(context),
        NasikoChartState.loading => _buildLoading(context),
        NasikoChartState.error => _buildError(context),
        NasikoChartState.empty => _buildEmpty(context),
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: spacing.s20w,
            height: spacing.s20w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.backgroundBrand,
            ),
          ),
          SizedBox(height: spacing.s12h),
          Text(
            loadingLabel,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: errorIcon,
            size: iconSizes.m,
            color: colors.foregroundError,
          ),
          SizedBox(height: spacing.s12h),
          Text(
            errorLabel,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundPrimary,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: spacing.s12h),
            TertiaryButton(
              label: 'Retry',
              leadingIcon: HugeIcons.strokeRoundedReload,
              size: NasikoButtonSize.small,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSizes = context.iconSize;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: emptyIcon,
            size: iconSizes.m,
            color: colors.foregroundIconTertiary,
          ),
          SizedBox(height: spacing.s12h),
          Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: typography.bodyTertiary.copyWith(
              color: colors.foregroundSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
