import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

/// Shared overlay-tooltip plumbing for chart [State]s. Owns a [LayerLink] and a
/// single [OverlayEntry] that renders a [NasikoChartTooltip] anchored to the
/// chart's plot area.
///
/// Usage from a chart's [State]:
/// - wrap the plot widget with [composeTooltipTarget];
/// - call [showChartTooltip] from the touch callback, passing the touched
///   pointer's local position as `anchor`;
/// - call [hideChartTooltip] when the touch leaves / nothing is selected.
///
/// Title, rows, and anchor are stored in fields that the [OverlayEntry] builder
/// reads, so repeated [showChartTooltip] calls during a continuous hover update
/// the tooltip's content and position in place.
mixin ChartTooltipOverlay<T extends StatefulWidget> on State<T> {
  final LayerLink _tooltipLink = LayerLink();
  OverlayEntry? _tooltipEntry;
  Offset _tooltipAnchor = Offset.zero;
  String _tooltipTitle = '';
  List<NasikoChartTooltipRow> _tooltipRows = const [];

  /// Wraps [child] (the chart's plot widget) so the overlay can anchor to it.
  Widget composeTooltipTarget(Widget child) =>
      CompositedTransformTarget(link: _tooltipLink, child: child);

  /// Shows or updates the tooltip. An empty [rows] list hides it.
  void showChartTooltip({
    required Offset anchor,
    required String title,
    required List<NasikoChartTooltipRow> rows,
  }) {
    if (rows.isEmpty) {
      hideChartTooltip();
      return;
    }
    _tooltipAnchor = anchor;
    _tooltipTitle = title;
    _tooltipRows = rows;
    if (_tooltipEntry == null) {
      _tooltipEntry = OverlayEntry(builder: (_) => _buildOverlay());
      Overlay.of(context).insert(_tooltipEntry!);
    } else {
      _tooltipEntry!.markNeedsBuild();
    }
  }

  /// Removes the tooltip overlay if present.
  void hideChartTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry?.dispose();
    _tooltipEntry = null;
  }

  Widget _buildOverlay() => Positioned(
    width: 260,
    child: CompositedTransformFollower(
      link: _tooltipLink,
      // Hide (rather than mis-position) if the target is briefly unlinked.
      showWhenUnlinked: false,
      // _tooltipAnchor is relative to the chart's plot area (the link target);
      // nudge right/up so the card clears the touched point/indicator.
      offset: Offset(_tooltipAnchor.dx + 12, _tooltipAnchor.dy - 16),
      child: Material(
        type: MaterialType.transparency,
        child: NasikoChartTooltip(title: _tooltipTitle, rows: _tooltipRows),
      ),
    ),
  );

  @override
  void dispose() {
    hideChartTooltip();
    super.dispose();
  }
}
