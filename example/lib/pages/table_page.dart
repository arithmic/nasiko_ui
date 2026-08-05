import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_section.dart';

class TablePage extends StatelessWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('sk-prod-01', 'Production', 'Active'),
      ('sk-stage-02', 'Staging', 'Active'),
      ('sk-dev-03', 'Development', 'Revoked'),
      ('sk-test-04', 'Testing', 'Active'),
    ];

    return GalleryPage(
      title: 'Table vs Data Table',
      description:
          'NasikoTable takes widget rows directly (untyped, no built-in '
          'sorting/selection); NasikoDataTable is the typed, feature-ful '
          'sibling. Same visual language — compare side by side.',
      children: [
        GallerySection(
          title: 'NasikoTable (widget rows)',
          child: NasikoTable(
            columns: const [
              NasikoTableColumn(title: 'Key', flex: 2),
              NasikoTableColumn(title: 'Environment'),
              NasikoTableColumn(title: 'Status'),
              NasikoTableColumn(title: 'Copy'),
            ],
            data: [
              for (final (key, env, status) in rows)
                [
                  NasikoTableTextCell(key),
                  NasikoTableTextCell(env),
                  NasikoBadge(
                    label: status,
                    intent: status == 'Active'
                        ? NasikoBadgeIntent.success
                        : NasikoBadgeIntent.error,
                  ),
                  NasikoTableCopyCell(
                    onCopy: () =>
                        NasikoToastService.showInfo(context, 'Copied $key'),
                  ),
                ],
            ],
          ),
        ),
        GallerySection(
          title: 'NasikoDataTable (typed rows, sortable)',
          child: NasikoDataTable<(String, String, String)>(
            columns: [
              NasikoDataColumn(
                label: 'Key',
                flex: 2,
                sortable: true,
                comparator: (a, b) => a.$1.compareTo(b.$1),
                cellBuilder: (context, row) => Text(
                  row.$1,
                  style: context.typography.code.copyWith(
                    color: context.colors.foregroundPrimary,
                  ),
                ),
              ),
              NasikoDataColumn(
                label: 'Environment',
                cellBuilder: (context, row) => Text(
                  row.$2,
                  style: context.typography.bodySecondary.copyWith(
                    color: context.colors.foregroundSecondary,
                  ),
                ),
              ),
              NasikoDataColumn(
                label: 'Status',
                cellBuilder: (context, row) => NasikoBadge(
                  label: row.$3,
                  intent: row.$3 == 'Active'
                      ? NasikoBadgeIntent.success
                      : NasikoBadgeIntent.error,
                ),
              ),
            ],
            rows: rows,
          ),
        ),
        const GallerySection(
          title: 'NasikoTableCellItem (legacy fixture)',
          description:
              'A public kitchen-sink cell kept for legacy table demos — '
              'shown here for coverage; prefer composing real cells.',
          child: NasikoTableCellItem(showCheckbox: true, showSwitch: true),
        ),
      ],
    );
  }
}
