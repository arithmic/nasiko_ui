/// The display state of a Nasiko chart.
///
/// Every chart widget accepts a [NasikoChartState] and delegates rendering of
/// the non-loaded states to the shared chart frame, so loading / error / empty
/// behaviour is identical across all chart types.
enum NasikoChartState {
  /// Data is available — the chart body renders.
  loaded,

  /// Data is being fetched — a spinner and label render.
  loading,

  /// The data fetch failed — an error message and optional retry render.
  error,

  /// The fetch succeeded but there isn't enough data to plot.
  empty,
}
