import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_data_table/better_data_table.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [child] in a [MaterialApp] with Material 3 so widgets that depend on
/// [Theme] work correctly.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: Scaffold(body: child),
  );
}

/// Returns a minimal two-column [BetterDataTable].
BetterDataTable _basicTable({List<BetterDataTableRow> rows = const []}) {
  return BetterDataTable(
    columns: const [
      BetterDataTableColumn(header: Text('Name')),
      BetterDataTableColumn(header: Text('Age')),
    ],
    rows: rows,
  );
}

// =============================================================================
// BetterDataTableColumn
// =============================================================================

void main() {
  group('BetterDataTableColumn', () {
    test('defaults', () {
      const col = BetterDataTableColumn(header: Text('X'));
      expect(col.visible, isTrue);
      expect(col.sortable, isFalse);
      expect(col.tooltip, isNull);
      expect(col.width, isNull);
      expect(col.minWidth, isNull);
      expect(col.maxWidth, isNull);
    });

    test('copyWith changes requested fields', () {
      const original = BetterDataTableColumn(
        header: Text('Original'),
        sortable: false,
        visible: true,
      );
      final copy = original.copyWith(sortable: true, visible: false);

      expect(copy.sortable, isTrue);
      expect(copy.visible, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const original = BetterDataTableColumn(
        header: Text('Keep'),
        minWidth: 60,
        maxWidth: 200,
        tooltip: 'hint',
      );
      final copy = original.copyWith(sortable: true);

      expect(copy.minWidth, 60);
      expect(copy.maxWidth, 200);
      expect(copy.tooltip, 'hint');
    });
  });

  // ==========================================================================
  // BetterDataTableRow
  // ==========================================================================

  group('BetterDataTableRow', () {
    test('stores cells', () {
      const row = BetterDataTableRow(cells: [Text('a'), Text('b')]);
      expect(row.cells.length, 2);
    });

    test('copyWith changes cells', () {
      const original = BetterDataTableRow(cells: [Text('old')]);
      final copy = original.copyWith(cells: [const Text('new')]);
      expect((copy.cells.first as Text).data, 'new');
    });

    test('copyWith preserves decoration and tooltip', () {
      final decoration = BoxDecoration(color: Colors.red);
      const original = BetterDataTableRow(cells: [], tooltip: 'tip');
      final copy = original.copyWith(decoration: decoration);
      expect(copy.tooltip, 'tip');
      expect(copy.decoration, decoration);
    });
  });

  // ==========================================================================
  // BetterDataTableGroup
  // ==========================================================================

  group('BetterDataTableGroup', () {
    test('defaults', () {
      const g = BetterDataTableGroup(
        header: Text('G'),
        startIndex: 0,
        endIndex: 2,
      );
      expect(g.collapsible, isFalse);
    });

    test('copyWith changes collapsible', () {
      const g = BetterDataTableGroup(
        header: Text('G'),
        startIndex: 0,
        endIndex: 1,
      );
      final copy = g.copyWith(collapsible: true, endIndex: 5);
      expect(copy.collapsible, isTrue);
      expect(copy.endIndex, 5);
    });

    test('copyWith preserves unchanged fields', () {
      const g = BetterDataTableGroup(
        header: Text('Section'),
        startIndex: 2,
        endIndex: 4,
        collapsible: true,
      );
      final copy = g.copyWith(startIndex: 0);
      expect(copy.endIndex, 4);
      expect(copy.collapsible, isTrue);
    });
  });

  // ==========================================================================
  // BetterDataTableTheme
  // ==========================================================================

  group('BetterDataTableTheme', () {
    test('minimal disables hover and has no decorations', () {
      final t = BetterDataTableTheme.minimal();
      expect(t.enableHoverEffect, isFalse);
      expect(t.headerDecoration, isNull);
      expect(t.rowDecoration, isNull);
    });

    test('copyWith changes requested fields', () {
      final t = BetterDataTableTheme.minimal().copyWith(
        enableHoverEffect: true,
        cellPadding: const EdgeInsets.all(4),
      );
      expect(t.enableHoverEffect, isTrue);
      expect(t.cellPadding, const EdgeInsets.all(4));
    });

    test('copyWith preserves unchanged fields', () {
      const original = BetterDataTableTheme(
        headerCellPadding: EdgeInsets.all(8),
        enableHoverEffect: false,
      );
      final copy = original.copyWith(cellPadding: const EdgeInsets.all(2));
      expect(copy.headerCellPadding, const EdgeInsets.all(8));
      expect(copy.enableHoverEffect, isFalse);
    });

    testWidgets('defaultTheme has row and header decorations', (tester) async {
      late BetterDataTableTheme theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              theme = BetterDataTableTheme.defaultTheme(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.rowDecoration, isNotNull);
      expect(theme.headerDecoration, isNotNull);
      expect(theme.enableHoverEffect, isTrue);
    });

    testWidgets('striped theme sets alternateRowDecoration', (tester) async {
      late BetterDataTableTheme theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              theme = BetterDataTableTheme.striped(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.alternateRowDecoration, isNotNull);
    });
  });

  // ==========================================================================
  // BetterDataTable – loading & empty states
  // ==========================================================================

  group('BetterDataTable – loading & empty states', () {
    testWidgets('shows CircularProgressIndicator when isLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('A'))],
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows default empty message when rows is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_basicTable()));
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('custom loading builder is used', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('A'))],
            isLoading: true,
            loadingBuilder: (_) => const Text('custom loading'),
          ),
        ),
      );
      expect(find.text('custom loading'), findsOneWidget);
    });

    testWidgets('custom empty builder is used', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('A'))],
            emptyBuilder: (_) => const Text('nothing here'),
          ),
        ),
      );
      expect(find.text('nothing here'), findsOneWidget);
    });
  });

  // ==========================================================================
  // BetterDataTable – rendering
  // ==========================================================================

  group('BetterDataTable – rendering', () {
    testWidgets('renders header text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _basicTable(
            rows: [
              const BetterDataTableRow(cells: [Text('Alice'), Text('28')]),
            ],
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('renders data cell text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _basicTable(
            rows: [
              const BetterDataTableRow(cells: [Text('Bob'), Text('42')]),
            ],
          ),
        ),
      );
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders multiple rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _basicTable(
            rows: [
              const BetterDataTableRow(cells: [Text('Alice'), Text('28')]),
              const BetterDataTableRow(cells: [Text('Bob'), Text('34')]),
              const BetterDataTableRow(cells: [Text('Carol'), Text('25')]),
            ],
          ),
        ),
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('hidden column header is not rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Visible')),
              BetterDataTableColumn(header: Text('Hidden'), visible: false),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('v'), Text('h')]),
            ],
          ),
        ),
      );
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('hidden column cell data is not rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('A')),
              BetterDataTableColumn(header: Text('B'), visible: false),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('shown'), Text('hidden-cell')]),
            ],
          ),
        ),
      );
      expect(find.text('shown'), findsOneWidget);
      expect(find.text('hidden-cell'), findsNothing);
    });

    testWidgets('footer rows are rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Item')),
              BetterDataTableColumn(header: Text('Total')),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('Widget'), Text('5')]),
            ],
            footerRows: const [
              BetterDataTableRow(cells: [Text('Sum'), Text('5')]),
            ],
          ),
        ),
      );
      expect(find.text('Sum'), findsOneWidget);
    });

    testWidgets('group header text is rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
              BetterDataTableRow(cells: [Text('Bob')]),
            ],
            groups: const [
              BetterDataTableGroup(
                header: Text('Group A'),
                startIndex: 0,
                endIndex: 1,
              ),
            ],
          ),
        ),
      );
      expect(find.text('Group A'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('custom header builder replaces default header', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Original'))],
            rows: const [
              BetterDataTableRow(cells: [Text('x')]),
            ],
            headerBuilder: (_, _, _) => const Text('Custom Header'),
          ),
        ),
      );
      expect(find.text('Custom Header'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
    });
  });

  // ==========================================================================
  // BetterDataTable – sorting
  // ==========================================================================

  group('BetterDataTable – sorting', () {
    testWidgets('arrow_upward shown for ascending sort', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Name'), sortable: true),
              BetterDataTableColumn(header: Text('Age'), sortable: true),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice'), Text('28')]),
            ],
            sortColumnIndex: 0,
            sortAscending: true,
            onSort: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('arrow_downward shown for descending sort', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Name'), sortable: true),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            sortColumnIndex: 0,
            sortAscending: false,
            onSort: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('onSort fires with original column index', (tester) async {
      int? sortedIndex;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Name'), sortable: true),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            onSort: (i) => sortedIndex = i,
          ),
        ),
      );

      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(sortedIndex, 0);
    });

    testWidgets('sort icon not shown when column index does not match', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('Name'), sortable: true),
              BetterDataTableColumn(header: Text('Age'), sortable: true),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice'), Text('28')]),
            ],
            sortColumnIndex: 1,
            onSort: (_) {},
          ),
        ),
      );
      // Only one sort icon shown (for Age column)
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });
  });

  // ==========================================================================
  // BetterDataTable – selection
  // ==========================================================================

  group('BetterDataTable – selection', () {
    testWidgets('checkboxes shown when showCheckboxes is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            showCheckboxes: true,
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
          ),
        ),
      );
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('onRowSelected fires when row checkbox tapped', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            showCheckboxes: true,
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            onRowSelected: (i) => selected = i,
          ),
        ),
      );

      // Index 0 = header (select-all), index 1 = first row
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      expect(selected, 0);
    });

    testWidgets('onSelectAll fires when header checkbox tapped', (
      tester,
    ) async {
      bool? selectAllValue;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            showCheckboxes: true,
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
              BetterDataTableRow(cells: [Text('Bob')]),
            ],
            onSelectAll: (v) => selectAllValue = v,
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(selectAllValue, isNotNull);
    });

    testWidgets('pre-selected row checkbox shows checked', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            showCheckboxes: true,
            selectedRows: const {0},
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
          ),
        ),
      );
      final cb = tester.widget<Checkbox>(find.byType(Checkbox).at(1));
      expect(cb.value, isTrue);
    });
  });

  // ==========================================================================
  // BetterDataTable – expansion
  // ==========================================================================

  group('BetterDataTable – expansion', () {
    testWidgets('expand_more icon shown for expandable rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => const Text('Details'),
          ),
        ),
      );
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('tapping expand icon shows expanded content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => const Text('Expanded content'),
          ),
        ),
      );

      expect(find.text('Expanded content'), findsNothing);
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      expect(find.text('Expanded content'), findsOneWidget);
    });

    testWidgets('tapping again collapses the expanded row', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => const Text('Details'),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pump();
      expect(find.text('Details'), findsNothing);
    });

    testWidgets('onRowExpanded fires with row index', (tester) async {
      String? expandedIndex;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => const Text('details'),
            onRowExpanded: (i) => expandedIndex = i,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      expect(expandedIndex, '0');
    });

    testWidgets('null-returning builder hides expand icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => null,
          ),
        ),
      );
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });

  // ==========================================================================
  // BetterDataTable – groups
  // ==========================================================================

  group('BetterDataTable – groups', () {
    testWidgets('collapsible group shows expand_more initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              BetterDataTableGroup(
                header: Text('Section'),
                startIndex: 0,
                endIndex: 0,
                collapsible: true,
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('tapping collapsible group hides its rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              BetterDataTableGroup(
                header: Text('Section'),
                startIndex: 0,
                endIndex: 0,
                collapsible: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('collapsed group can be expanded again', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              BetterDataTableGroup(
                header: Text('Section'),
                startIndex: 0,
                endIndex: 0,
                collapsible: true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(find.text('Alice'), findsNothing);

      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('onGroupToggled fires with group index', (tester) async {
      int? toggledGroup;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              BetterDataTableGroup(
                header: Text('Section'),
                startIndex: 0,
                endIndex: 0,
                collapsible: true,
              ),
            ],
            onGroupToggled: (i) => toggledGroup = i,
          ),
        ),
      );

      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(toggledGroup, 0);
    });
  });

  // ==========================================================================
  // BetterDataTable – row callbacks
  // ==========================================================================

  group('BetterDataTable – row callbacks', () {
    testWidgets('onRowTap fires with row index', (tester) async {
      int? tappedRow;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: const [
              BetterDataTableRow(cells: [Text('Alice')]),
            ],
            onRowTap: (i) => tappedRow = i,
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.pump();
      expect(tappedRow, 0);
    });

    testWidgets('onCellTap fires with correct row and column indices', (
      tester,
    ) async {
      int? tapRow;
      int? tapCol;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [
              BetterDataTableColumn(header: Text('A')),
              BetterDataTableColumn(header: Text('B')),
            ],
            rows: const [
              BetterDataTableRow(cells: [Text('cell-a'), Text('cell-b')]),
            ],
            onCellTap: (r, c) {
              tapRow = r;
              tapCol = c;
            },
          ),
        ),
      );

      await tester.tap(find.text('cell-b'));
      await tester.pump();
      expect(tapRow, 0);
      expect(tapCol, 1);
    });

    testWidgets('BetterDataTableRow.onTap fires when row tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          BetterDataTable(
            columns: const [BetterDataTableColumn(header: Text('Name'))],
            rows: [
              BetterDataTableRow(
                cells: const [Text('Alice')],
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
