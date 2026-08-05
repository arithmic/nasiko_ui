import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class _Agent {
  const _Agent(this.id, this.name, this.owner, this.runs, this.status);

  final int id;
  final String name;
  final String owner;
  final int runs;
  final String status;
}

final List<_Agent> _agents = List.generate(30, (i) {
  const names = ['Parser', 'Triager', 'Router', 'Scraper', 'Summarizer'];
  const owners = ['Satya', 'Mira', 'Jon', 'Priya', 'Alex', 'Chen'];
  const statuses = ['Active', 'Paused', 'Failed'];
  return _Agent(
    i + 1,
    '${names[i % names.length]} #${i + 1}',
    owners[i % owners.length],
    (i * 37) % 500,
    statuses[i % statuses.length],
  );
});

List<NasikoDataColumn<_Agent>> _columns(BuildContext context) => [
      NasikoDataColumn(
        label: 'Agent',
        flex: 2,
        sortable: true,
        comparator: (a, b) => a.name.compareTo(b.name),
        cellBuilder: (context, row) => Text(
          row.name,
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundPrimary,
          ),
        ),
      ),
      NasikoDataColumn(
        label: 'Owner',
        cellBuilder: (context, row) => Text(
          row.owner,
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundSecondary,
          ),
        ),
      ),
      NasikoDataColumn(
        label: 'Runs',
        sortable: true,
        comparator: (a, b) => a.runs.compareTo(b.runs),
        alignment: Alignment.centerRight,
        cellBuilder: (context, row) => Text(
          '${row.runs}',
          style: context.typography.code.copyWith(
            color: context.colors.foregroundPrimary,
          ),
        ),
      ),
      NasikoDataColumn(
        label: 'Status',
        cellBuilder: (context, row) => NasikoBadge(
          label: row.status,
          intent: switch (row.status) {
            'Active' => NasikoBadgeIntent.success,
            'Paused' => NasikoBadgeIntent.warning,
            _ => NasikoBadgeIntent.error,
          },
        ),
      ),
    ];

class DataTablePage extends StatefulWidget {
  const DataTablePage({super.key});

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  Set<Object> _selected = {};
  int _paginationPage = 5;

  // Server-mode state.
  static const int _serverPageSize = 6;
  int _serverPage = 0;
  bool _serverLoading = false;
  List<_Agent> _serverRows =
      _agents.take(_serverPageSize).toList(growable: false);

  Future<void> _loadServerPage(int page) async {
    setState(() {
      _serverPage = page;
      _serverLoading = true;
    });
    // Fake latency, then slice like a backend would.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _serverRows = _agents
          .skip(page * _serverPageSize)
          .take(_serverPageSize)
          .toList(growable: false);
      _serverLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Data Table',
      description:
          'Typed rows with sortable headers (click cycles asc → desc → '
          'clear), row selection with a mixed-state header checkbox, and '
          'pagination — client-side and server-side.',
      children: [
        GallerySection(
          title: 'Client-side: sortable + selectable + paginated',
          description:
              '30 rows, pageSize 8. Selected: ${_selected.length} row(s).',
          child: NasikoDataTable<_Agent>(
            columns: _columns(context),
            rows: _agents,
            rowKey: (row) => row.id,
            selectable: true,
            selected: _selected,
            onSelectionChanged: (next) => setState(() => _selected = next),
            pageSize: 8,
            onRowTap: (row) =>
                NasikoToastService.showInfo(context, 'Tapped ${row.name}'),
          ),
        ),
        GallerySection(
          title: 'Server-side pagination',
          description:
              'Pre-sliced rows + totalRows; page changes show the skeleton '
              'loading state for ~450ms of fake latency.',
          child: NasikoDataTable<_Agent>(
            columns: _columns(context),
            rows: _serverRows,
            rowKey: (row) => row.id,
            isLoading: _serverLoading,
            skeletonRowCount: _serverPageSize,
            pageSize: _serverPageSize,
            page: _serverPage,
            totalRows: _agents.length,
            onPageChanged: _loadServerPage,
          ),
        ),
        GallerySection(
          title: 'Empty state',
          child: NasikoDataTable<_Agent>(
            columns: _columns(context),
            rows: const [],
            emptyState: const NasikoEmpty(
              title: 'No agents yet',
              description: 'Rows you add will show up here.',
            ),
          ),
        ),
        GallerySection(
          title: 'Standalone NasikoPagination',
          description:
              'The windowed page switcher the table embeds — usable on its '
              'own. 20 pages, ellipses collapse the middle.',
          child: NasikoPagination(
            page: _paginationPage,
            pageCount: 20,
            onPageChanged: (p) => setState(() => _paginationPage = p),
          ),
        ),
      ],
    );
  }
}
