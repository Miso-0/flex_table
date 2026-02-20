import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_data_table/flexible_data_table.dart';

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

/// Returns a minimal two-column [FlexibleDataTable].
FlexibleDataTable _basicTable({List<FlexibleDataTableRow> rows = const []}) {
  return FlexibleDataTable(
    columns: const [
      FlexibleDataTableColumn(header: Text('Name')),
      FlexibleDataTableColumn(header: Text('Age')),
    ],
    rows: rows,
  );
}

// =============================================================================
// FlexibleDataTableColumn
// =============================================================================

void main() {
  group('FlexibleDataTableColumn', () {
    test('defaults', () {
      const col = FlexibleDataTableColumn(header: Text('X'));
      expect(col.visible, isTrue);
      expect(col.sortable, isFalse);
      expect(col.tooltip, isNull);
      expect(col.width, isNull);
      expect(col.minWidth, isNull);
      expect(col.maxWidth, isNull);
    });

    test('copyWith changes requested fields', () {
      const original = FlexibleDataTableColumn(
        header: Text('Original'),
        sortable: false,
        visible: true,
      );
      final copy = original.copyWith(sortable: true, visible: false);

      expect(copy.sortable, isTrue);
      expect(copy.visible, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const original = FlexibleDataTableColumn(
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
  // FlexibleDataTableRow
  // ==========================================================================

  group('FlexibleDataTableRow', () {
    test('stores cells', () {
      const row = FlexibleDataTableRow(cells: [Text('a'), Text('b')]);
      expect(row.cells.length, 2);
    });

    test('copyWith changes cells', () {
      const original = FlexibleDataTableRow(cells: [Text('old')]);
      final copy = original.copyWith(cells: [const Text('new')]);
      expect((copy.cells.first as Text).data, 'new');
    });

    test('copyWith preserves decoration and tooltip', () {
      final decoration = BoxDecoration(color: Colors.red);
      const original = FlexibleDataTableRow(cells: [], tooltip: 'tip');
      final copy = original.copyWith(decoration: decoration);
      expect(copy.tooltip, 'tip');
      expect(copy.decoration, decoration);
    });
  });

  // ==========================================================================
  // FlexibleDataTableGroup
  // ==========================================================================

  group('FlexibleDataTableGroup', () {
    test('defaults', () {
      const g = FlexibleDataTableGroup(
        header: Text('G'),
        startIndex: 0,
        endIndex: 2,
      );
      expect(g.collapsible, isFalse);
    });

    test('copyWith changes collapsible', () {
      const g = FlexibleDataTableGroup(
        header: Text('G'),
        startIndex: 0,
        endIndex: 1,
      );
      final copy = g.copyWith(collapsible: true, endIndex: 5);
      expect(copy.collapsible, isTrue);
      expect(copy.endIndex, 5);
    });

    test('copyWith preserves unchanged fields', () {
      const g = FlexibleDataTableGroup(
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
  // FlexibleDataTableTheme
  // ==========================================================================

  group('FlexibleDataTableTheme', () {
    test('minimal disables hover and has no decorations', () {
      final t = FlexibleDataTableTheme.minimal();
      expect(t.enableHoverEffect, isFalse);
      expect(t.headerDecoration, isNull);
      expect(t.rowDecoration, isNull);
    });

    test('copyWith changes requested fields', () {
      final t = FlexibleDataTableTheme.minimal().copyWith(
        enableHoverEffect: true,
        cellPadding: const EdgeInsets.all(4),
      );
      expect(t.enableHoverEffect, isTrue);
      expect(t.cellPadding, const EdgeInsets.all(4));
    });

    test('copyWith preserves unchanged fields', () {
      const original = FlexibleDataTableTheme(
        headerCellPadding: EdgeInsets.all(8),
        enableHoverEffect: false,
      );
      final copy = original.copyWith(cellPadding: const EdgeInsets.all(2));
      expect(copy.headerCellPadding, const EdgeInsets.all(8));
      expect(copy.enableHoverEffect, isFalse);
    });

    testWidgets('defaultTheme has row and header decorations', (tester) async {
      late FlexibleDataTableTheme theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              theme = FlexibleDataTableTheme.defaultTheme(context);
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
      late FlexibleDataTableTheme theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              theme = FlexibleDataTableTheme.striped(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.alternateRowDecoration, isNotNull);
    });
  });

  // ==========================================================================
  // FlexibleDataTable – loading & empty states
  // ==========================================================================

  group('FlexibleDataTable – loading & empty states', () {
    testWidgets('shows CircularProgressIndicator when isLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('A'))],
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('A'))],
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('A'))],
            emptyBuilder: (_) => const Text('nothing here'),
          ),
        ),
      );
      expect(find.text('nothing here'), findsOneWidget);
    });
  });

  // ==========================================================================
  // FlexibleDataTable – rendering
  // ==========================================================================

  group('FlexibleDataTable – rendering', () {
    testWidgets('renders header text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _basicTable(
            rows: [
              const FlexibleDataTableRow(cells: [Text('Alice'), Text('28')]),
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
              const FlexibleDataTableRow(cells: [Text('Bob'), Text('42')]),
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
              const FlexibleDataTableRow(cells: [Text('Alice'), Text('28')]),
              const FlexibleDataTableRow(cells: [Text('Bob'), Text('34')]),
              const FlexibleDataTableRow(cells: [Text('Carol'), Text('25')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Visible')),
              FlexibleDataTableColumn(header: Text('Hidden'), visible: false),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('v'), Text('h')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('A')),
              FlexibleDataTableColumn(header: Text('B'), visible: false),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('shown'), Text('hidden-cell')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Item')),
              FlexibleDataTableColumn(header: Text('Total')),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Widget'), Text('5')]),
            ],
            footerRows: const [
              FlexibleDataTableRow(cells: [Text('Sum'), Text('5')]),
            ],
          ),
        ),
      );
      expect(find.text('Sum'), findsOneWidget);
    });

    testWidgets('group header text is rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
              FlexibleDataTableRow(cells: [Text('Bob')]),
            ],
            groups: const [
              FlexibleDataTableGroup(
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Original'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('x')]),
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
  // FlexibleDataTable – sorting
  // ==========================================================================

  group('FlexibleDataTable – sorting', () {
    testWidgets('arrow_upward shown for ascending sort', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Name'), sortable: true),
              FlexibleDataTableColumn(header: Text('Age'), sortable: true),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice'), Text('28')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Name'), sortable: true),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Name'), sortable: true),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('Name'), sortable: true),
              FlexibleDataTableColumn(header: Text('Age'), sortable: true),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice'), Text('28')]),
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
  // FlexibleDataTable – selection
  // ==========================================================================

  group('FlexibleDataTable – selection', () {
    testWidgets('checkboxes shown when showCheckboxes is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            showCheckboxes: true,
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            showCheckboxes: true,
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            showCheckboxes: true,
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
              FlexibleDataTableRow(cells: [Text('Bob')]),
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
          FlexibleDataTable(
            showCheckboxes: true,
            selectedRows: const {0},
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
          ),
        ),
      );
      final cb = tester.widget<Checkbox>(find.byType(Checkbox).at(1));
      expect(cb.value, isTrue);
    });
  });

  // ==========================================================================
  // FlexibleDataTable – expansion
  // ==========================================================================

  group('FlexibleDataTable – expansion', () {
    testWidgets('expand_more icon shown for expandable rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
            expandableRowBuilder: (_, _, _) => null,
          ),
        ),
      );
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });

  // ==========================================================================
  // FlexibleDataTable – groups
  // ==========================================================================

  group('FlexibleDataTable – groups', () {
    testWidgets('collapsible group shows expand_more initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              FlexibleDataTableGroup(
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              FlexibleDataTableGroup(
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              FlexibleDataTableGroup(
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
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
            ],
            groups: const [
              FlexibleDataTableGroup(
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
  // FlexibleDataTable – row callbacks
  // ==========================================================================

  group('FlexibleDataTable – row callbacks', () {
    testWidgets('onRowTap fires with row index', (tester) async {
      int? tappedRow;
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: const [
              FlexibleDataTableRow(cells: [Text('Alice')]),
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
          FlexibleDataTable(
            columns: const [
              FlexibleDataTableColumn(header: Text('A')),
              FlexibleDataTableColumn(header: Text('B')),
            ],
            rows: const [
              FlexibleDataTableRow(cells: [Text('cell-a'), Text('cell-b')]),
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

    testWidgets('FlexibleDataTableRow.onTap fires when row tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          FlexibleDataTable(
            columns: const [FlexibleDataTableColumn(header: Text('Name'))],
            rows: [
              FlexibleDataTableRow(
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
