import 'package:flutter/material.dart';

import 'better_data_table_column.dart';
import 'better_data_table_group.dart';
import 'better_data_table_row.dart';
import 'better_data_table_theme.dart';

/// A highly customizable and flexible table widget for Flutter.
///
/// `BetterDataTable` renders tabular data using Flutter's [Table] widget as its
/// layout engine. It supports:
///
/// - Flexible, fixed, intrinsic, and fractional column widths
/// - Sortable columns with ascending/descending indicators
/// - Checkbox row selection with select-all support
/// - Expandable rows with custom content builders
/// - Collapsible row groups
/// - Alternating/striped row colors
/// - Column visibility toggling
/// - Loading and empty states with custom builders
/// - Footer rows for summaries/totals
/// - Hover effects and rich row/cell interaction callbacks
/// - Comprehensive per-column, per-row, and theme-level styling
///
/// The table does not manage its own scrolling. Wrap it in a [SingleChildScrollView]
/// or [ListView] when content may overflow.
///
/// ## Basic usage
///
/// ```dart
/// BetterDataTable(
///   columns: [
///     BetterDataTableColumn(header: Text('Name'), width: FlexColumnWidth(2), sortable: true),
///     BetterDataTableColumn(header: Text('Age'), width: FixedColumnWidth(80)),
///   ],
///   rows: [
///     BetterDataTableRow(cells: [Text('Alice'), Text('28')]),
///     BetterDataTableRow(cells: [Text('Bob'), Text('34')]),
///   ],
/// )
/// ```
class BetterDataTable extends StatefulWidget {
  const BetterDataTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.theme,
    // ── Builders ─────────────────────────────────────────────────────────────
    this.headerBuilder,
    this.cellBuilder,
    this.rowBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    // ── Footer ───────────────────────────────────────────────────────────────
    this.footerRows,
    // ── Selection ────────────────────────────────────────────────────────────
    this.showCheckboxes = false,
    this.checkboxBuilder,
    this.onSelectAll,
    this.selectedRows = const {},
    this.onRowSelected,
    // ── Expansion ────────────────────────────────────────────────────────────
    this.expandableRowBuilder,
    this.expandedRows = const {},
    this.onRowExpanded,
    // ── Loading ───────────────────────────────────────────────────────────────
    this.isLoading = false,
    // ── Sorting ───────────────────────────────────────────────────────────────
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending = true,
    // ── Groups ───────────────────────────────────────────────────────────────
    this.groups,
    this.groupHeaderBuilder,
    this.collapsedGroups = const {},
    this.onGroupToggled,
    // ── Callbacks ────────────────────────────────────────────────────────────
    this.onRowTap,
    this.onRowDoubleTap,
    this.onRowLongPress,
    this.onRowSecondaryTap,
    this.onCellTap,
    // ── Styling ───────────────────────────────────────────────────────────────
    this.border,
    this.rowDivider,
  });

  // ── Data ───────────────────────────────────────────────────────────────────

  /// Column definitions. Columns with [BetterDataTableColumn.visible] set to `false`
  /// are excluded from layout and rendering.
  final List<BetterDataTableColumn> columns;

  /// Data rows. Each row's [BetterDataTableRow.cells] list corresponds positionally
  /// to the *visible* columns.
  final List<BetterDataTableRow> rows;

  /// Theme overrides. When `null`, [BetterDataTableTheme.defaultTheme] is used.
  final BetterDataTableTheme? theme;

  // ── Builders ───────────────────────────────────────────────────────────────

  /// Replaces the default header cell rendering for every column.
  ///
  /// Receives the [BuildContext], the [BetterDataTableColumn] (original, including
  /// hidden columns that are filtered before this is called), and its original
  /// index in [columns].
  final Widget Function(
    BuildContext context,
    BetterDataTableColumn column,
    int columnIndex,
  )?
  headerBuilder;

  /// Replaces the default data cell rendering for every cell.
  ///
  /// Receives the original cell [Widget], its [BetterDataTableColumn], the
  /// [BetterDataTableRow], the row index, and the original column index.
  final Widget Function(
    BuildContext context,
    Widget cell,
    BetterDataTableColumn column,
    BetterDataTableRow row,
    int rowIndex,
    int columnIndex,
  )?
  cellBuilder;

  /// Wraps or replaces the rendered [TableRow] for each data row.
  ///
  /// `defaultRow` is the widget produced by the default rendering pipeline.
  final Widget Function(
    BuildContext context,
    BetterDataTableRow row,
    int rowIndex,
    Widget defaultRow,
  )?
  rowBuilder;

  /// Replaces the default empty-state widget shown when [rows] is empty.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Replaces the default loading widget shown when [isLoading] is `true`.
  final Widget Function(BuildContext context)? loadingBuilder;

  // ── Footer ─────────────────────────────────────────────────────────────────

  /// Optional footer rows rendered below data rows (e.g., totals).
  final List<BetterDataTableRow>? footerRows;

  // ── Selection ──────────────────────────────────────────────────────────────

  /// Whether to show a leading checkbox column.
  final bool showCheckboxes;

  /// Replaces the default [Checkbox] widget for both the header (select-all)
  /// and data row checkboxes.
  ///
  /// `value` is `true` (selected), `false` (unselected), or `null` (tristate
  /// indeterminate, header only).
  final Widget Function(
    BuildContext context,
    bool? value,
    ValueChanged<bool?>? onChanged,
  )?
  checkboxBuilder;

  /// Called when the header (select-all) checkbox changes. The argument is
  /// `true` (select all), `false` (deselect all), or `null`.
  final ValueChanged<bool?>? onSelectAll;

  /// Row indices that are currently selected. The widget keeps an internal copy
  /// and re-syncs when this set changes identity.
  final Set<int> selectedRows;

  /// Called with the row index when a checkbox is toggled.
  final ValueChanged<int>? onRowSelected;

  // ── Expansion ──────────────────────────────────────────────────────────────

  /// Returns the widget to display below the row when it is expanded, or
  /// `null` if the row is not expandable.
  ///
  /// **Note:** If rows have [BetterDataTableRow.children], they will automatically
  /// be expandable regardless of this builder. This builder is for custom
  /// expandable content that isn't hierarchical sub-rows.
  final Widget? Function(
    BuildContext context,
    BetterDataTableRow row,
    int rowIndex,
  )?
  expandableRowBuilder;

  /// Row paths that are currently expanded.
  /// For hierarchical rows, use dot-separated paths like "0", "0.1", "0.1.2".
  /// For simple rows without children, use the row index as a string like "0", "1", "2".
  final Set<String> expandedRows;

  /// Called with the row path when the expand/collapse button is tapped.
  /// For hierarchical rows, the path is dot-separated like "0.1.2".
  final ValueChanged<String>? onRowExpanded;

  // ── Loading ─────────────────────────────────────────────────────────────────

  /// When `true`, the table body is replaced by the loading indicator.
  final bool isLoading;

  // ── Sorting ─────────────────────────────────────────────────────────────────

  /// Called with the original column index when a sortable header is tapped.
  final void Function(int columnIndex)? onSort;

  /// Original column index of the currently sorted column. The sort indicator
  /// is shown only when this matches a visible, sortable column.
  final int? sortColumnIndex;

  /// Direction of the current sort. Defaults to `true` (ascending).
  final bool sortAscending;

  // ── Groups ─────────────────────────────────────────────────────────────────

  /// Optional list of [BetterDataTableGroup] definitions. When provided, rows are
  /// rendered in group sections with a spanning header row.
  final List<BetterDataTableGroup>? groups;

  /// Replaces the default group header cell rendering.
  final Widget Function(
    BuildContext context,
    BetterDataTableGroup group,
    int groupIndex,
  )?
  groupHeaderBuilder;

  /// Group indices (position in [groups]) that are currently collapsed.
  final Set<int> collapsedGroups;

  /// Called with the group index when a collapsible group header is tapped.
  final ValueChanged<int>? onGroupToggled;

  // ── Callbacks ──────────────────────────────────────────────────────────────

  /// Called with the row index when a data row is tapped.
  final ValueChanged<int>? onRowTap;

  /// Called with the row index when a data row is double-tapped.
  final ValueChanged<int>? onRowDoubleTap;

  /// Called with the row index when a data row is long-pressed.
  final ValueChanged<int>? onRowLongPress;

  /// Called with the row index when a data row receives a secondary tap
  /// (right-click on desktop, long-press context on some platforms).
  final ValueChanged<int>? onRowSecondaryTap;

  /// Called with (rowIndex, columnIndex) when a data cell is tapped.
  /// Column index is the *original* index in [columns].
  final void Function(int rowIndex, int columnIndex)? onCellTap;

  // ── Styling ─────────────────────────────────────────────────────────────────

  /// Table border overriding [BetterDataTableTheme.border].
  final TableBorder? border;

  /// When set, this [BorderSide] is drawn as the bottom edge of every data row,
  /// creating a visual divider between rows.
  final BorderSide? rowDivider;

  @override
  State<BetterDataTable> createState() => _BetterDataTableState();
}

// =============================================================================

class _BetterDataTableState extends State<BetterDataTable> {
  late Set<int> _selectedRows;
  late Set<String> _expandedRows;
  late Set<int> _collapsedGroups;
  final Map<String, bool> _hoveredRows = {};

  @override
  void initState() {
    super.initState();
    _selectedRows = Set.from(widget.selectedRows);
    _expandedRows = Set.from(widget.expandedRows);
    _collapsedGroups = Set.from(widget.collapsedGroups);
  }

  @override
  void didUpdateWidget(BetterDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRows != oldWidget.selectedRows) {
      _selectedRows = Set.from(widget.selectedRows);
    }
    if (widget.expandedRows != oldWidget.expandedRows) {
      _expandedRows = Set.from(widget.expandedRows);
    }
    if (widget.collapsedGroups != oldWidget.collapsedGroups) {
      _collapsedGroups = Set.from(widget.collapsedGroups);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns (originalIndex, column) pairs for all visible columns.
  List<(int, BetterDataTableColumn)> get _visibleColumns {
    final result = <(int, BetterDataTableColumn)>[];
    for (var i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].visible) result.add((i, widget.columns[i]));
    }
    return result;
  }

  int get _totalColumnCount {
    final hasExpandColumn = widget.expandableRowBuilder != null ||
        _anyRowHasChildren(widget.rows);
    return _visibleColumns.length +
        (widget.showCheckboxes ? 1 : 0) +
        (hasExpandColumn ? 1 : 0);
  }

  bool _anyRowHasChildren(List<BetterDataTableRow> rows) {
    for (final row in rows) {
      if (row.children != null && row.children!.isNotEmpty) {
        return true;
      }
      if (row.children != null && _anyRowHasChildren(row.children!)) {
        return true;
      }
    }
    return false;
  }

  BoxDecoration? _rowDecoration(
    BetterDataTableTheme theme,
    int rowIndex, {
    required bool isSelected,
    required bool isHovered,
    BoxDecoration? customDecoration,
  }) {
    BoxDecoration? base;
    if (customDecoration != null) {
      base = customDecoration;
    } else if (isSelected) {
      base = theme.selectedRowDecoration;
    } else if (isHovered) {
      base = theme.hoveredRowDecoration;
    } else if (theme.alternateRowDecoration != null && rowIndex.isOdd) {
      base = theme.alternateRowDecoration;
    } else {
      base = theme.rowDecoration;
    }

    if (widget.rowDivider != null) {
      final border = Border(bottom: widget.rowDivider!);
      if (base != null) {
        return base.copyWith(
          border: base.border != null
              ? (base.border as Border?)?.add(border) ?? border
              : border,
        );
      }
      return BoxDecoration(border: border);
    }

    return base;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? BetterDataTableTheme.defaultTheme(context);

    if (widget.isLoading) {
      return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading();
    }

    if (widget.rows.isEmpty && widget.groups == null) {
      return widget.emptyBuilder?.call(context) ?? _buildDefaultEmpty(theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildTable(context, theme)],
    );
  }

  Widget _buildTable(BuildContext context, BetterDataTableTheme theme) {
    return Table(
      border: widget.border ?? theme.border,
      columnWidths: _buildColumnWidths(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildHeaderRow(context, theme),
        if (widget.groups != null)
          ..._buildGroupedRows(context, theme)
        else
          ..._buildDataRows(context, theme),
        if (widget.footerRows != null) ..._buildFooterRows(context, theme),
      ],
    );
  }

  // ── Column widths ──────────────────────────────────────────────────────────

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final widths = <int, TableColumnWidth>{};
    int offset = 0;

    if (widget.showCheckboxes) {
      widths[0] = const FixedColumnWidth(48);
      offset = 1;
    }

    final visible = _visibleColumns;
    for (var vi = 0; vi < visible.length; vi++) {
      final column = visible[vi].$2;
      TableColumnWidth w = column.width ?? const FlexColumnWidth(1);
      if (column.minWidth != null) {
        w = MaxColumnWidth(FixedColumnWidth(column.minWidth!), w);
      }
      if (column.maxWidth != null) {
        w = MinColumnWidth(FixedColumnWidth(column.maxWidth!), w);
      }
      widths[vi + offset] = w;
    }

    final hasExpandColumn = widget.expandableRowBuilder != null ||
        _anyRowHasChildren(widget.rows);
    if (hasExpandColumn) {
      widths[visible.length + offset] = const FixedColumnWidth(48);
    }

    return widths;
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  TableRow _buildHeaderRow(BuildContext context, BetterDataTableTheme theme) {
    final cells = <Widget>[];

    if (widget.showCheckboxes) {
      cells.add(_buildSelectAllCheckbox(context, theme));
    }

    for (final (originalIndex, column) in _visibleColumns) {
      cells.add(_buildHeaderCell(context, column, originalIndex, theme));
    }

    final hasExpandColumn = widget.expandableRowBuilder != null ||
        _anyRowHasChildren(widget.rows);
    if (hasExpandColumn) {
      cells.add(const SizedBox(width: 48));
    }

    return TableRow(decoration: theme.headerDecoration, children: cells);
  }

  Widget _buildSelectAllCheckbox(
    BuildContext context,
    BetterDataTableTheme theme,
  ) {
    final allSelected =
        widget.rows.isNotEmpty &&
        _selectedRows.length == widget.rows.length;
    final someSelected =
        _selectedRows.isNotEmpty &&
        _selectedRows.length < widget.rows.length;
    final value = allSelected ? true : (someSelected ? null : false);

    void onChanged(bool? v) {
      setState(() {
        if (v == true) {
          _selectedRows = Set.from(
            List.generate(widget.rows.length, (i) => i),
          );
        } else {
          _selectedRows.clear();
        }
      });
      widget.onSelectAll?.call(v);
    }

    return Container(
      padding: theme.headerCellPadding,
      alignment: Alignment.center,
      child:
          widget.checkboxBuilder?.call(context, value, onChanged) ??
          Checkbox(
            value: value,
            tristate: true,
            onChanged: onChanged,
          ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    BetterDataTableColumn column,
    int originalIndex,
    BetterDataTableTheme theme,
  ) {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(context, column, originalIndex);
    }

    Widget content = column.header;

    if (column.sortable && widget.sortColumnIndex == originalIndex) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: content),
          const SizedBox(width: 4),
          Icon(
            widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: theme.sortIconColor,
          ),
        ],
      );
    }

    final cell = Container(
      padding: column.headerPadding ?? theme.headerCellPadding,
      alignment: column.headerAlignment ?? theme.headerCellAlignment,
      child: DefaultTextStyle(
        style:
            theme.headerTextStyle ??
            const TextStyle(fontWeight: FontWeight.bold),
        child: content,
      ),
    );

    final tappable = InkWell(
      onTap: column.sortable && widget.onSort != null
          ? () => widget.onSort!(originalIndex)
          : column.onTap,
      child: cell,
    );

    if (column.tooltip != null) {
      return Tooltip(message: column.tooltip!, child: tappable);
    }

    return tappable;
  }

  // ── Data rows ──────────────────────────────────────────────────────────────

  List<TableRow> _buildDataRows(
    BuildContext context,
    BetterDataTableTheme theme,
  ) {
    final rows = <TableRow>[];
    for (var i = 0; i < widget.rows.length; i++) {
      _buildDataRowRecursive(
        context,
        widget.rows[i],
        i,
        '$i',
        0,
        theme,
        rows,
      );
    }
    return rows;
  }

  void _buildDataRowRecursive(
    BuildContext context,
    BetterDataTableRow row,
    int rowIndex,
    String rowPath,
    int nestingLevel,
    BetterDataTableTheme theme,
    List<TableRow> rows,
  ) {
    // Add the current row
    rows.add(_buildDataRow(context, row, rowIndex, rowPath, nestingLevel, theme));

    // Check if we should show custom expanded content
    final isExpanded = _expandedRows.contains(rowPath);
    if (isExpanded && widget.expandableRowBuilder != null) {
      rows.add(_buildExpandedRow(context, row, rowIndex, rowPath, theme));
    }

    // Recursively add child rows if expanded
    if (isExpanded && row.children != null && row.children!.isNotEmpty) {
      for (var i = 0; i < row.children!.length; i++) {
        _buildDataRowRecursive(
          context,
          row.children![i],
          i,
          '$rowPath.$i',
          nestingLevel + 1,
          theme,
          rows,
        );
      }
    }
  }

  TableRow _buildDataRow(
    BuildContext context,
    BetterDataTableRow row,
    int rowIndex,
    String rowPath,
    int nestingLevel,
    BetterDataTableTheme theme,
  ) {
    final cells = <Widget>[];
    final isHovered = _hoveredRows[rowPath] ?? false;
    final isSelected = _selectedRows.contains(rowIndex);

    // Checkbox
    if (widget.showCheckboxes) {
      cells.add(_buildRowCheckbox(context, rowIndex, isSelected, theme));
    }

    // Data cells with indentation for first column
    final visible = _visibleColumns;
    for (var vi = 0; vi < visible.length; vi++) {
      final (originalIndex, column) = visible[vi];
      if (originalIndex >= row.cells.length) {
        cells.add(const SizedBox.shrink());
        continue;
      }

      // Add indentation to the first visible column based on nesting level
      final isFirstColumn = vi == 0;
      cells.add(
        _buildDataCell(
          context,
          row.cells[originalIndex],
          column,
          row,
          rowIndex,
          originalIndex,
          theme,
          nestingLevel: isFirstColumn ? nestingLevel : 0,
        ),
      );
    }

    // Expand toggle column – always add when the column exists to keep all rows
    // the same width. The toggle renders empty for non-expandable rows.
    final hasExpandColumn = widget.expandableRowBuilder != null ||
        _anyRowHasChildren(widget.rows);
    if (hasExpandColumn) {
      final hasChildren = row.children != null && row.children!.isNotEmpty;
      final hasExpandableContent = widget.expandableRowBuilder != null;
      cells.add(_buildExpandToggle(context, row, rowPath, hasChildren, hasExpandableContent, theme));
    }

    final decoration = _rowDecoration(
      theme,
      rowIndex,
      isSelected: isSelected,
      isHovered: isHovered,
      customDecoration: row.decoration,
    );

    final hasTap =
        widget.onRowTap != null ||
        widget.onRowDoubleTap != null ||
        widget.onRowLongPress != null ||
        widget.onRowSecondaryTap != null ||
        row.onTap != null;

    final needsMouseRegion = theme.enableHoverEffect || hasTap;

    if (!needsMouseRegion) {
      return TableRow(decoration: decoration, children: cells);
    }

    final wrappedCells = cells.map((cell) {
      Widget child = cell;

      if (hasTap) {
        child = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onRowTap?.call(rowIndex);
            row.onTap?.call();
          },
          onDoubleTap: widget.onRowDoubleTap != null
              ? () => widget.onRowDoubleTap!(rowIndex)
              : null,
          onLongPress: widget.onRowLongPress != null
              ? () => widget.onRowLongPress!(rowIndex)
              : null,
          onSecondaryTap: widget.onRowSecondaryTap != null
              ? () => widget.onRowSecondaryTap!(rowIndex)
              : null,
          child: child,
        );
      }

      if (theme.enableHoverEffect) {
        child = MouseRegion(
          onEnter: (_) => setState(() => _hoveredRows[rowPath] = true),
          onExit: (_) => setState(() => _hoveredRows[rowPath] = false),
          child: child,
        );
      }

      if (row.tooltip != null) {
        child = Tooltip(message: row.tooltip!, child: child);
      }

      return child;
    }).toList();

    return TableRow(decoration: decoration, children: wrappedCells);
  }

  Widget _buildRowCheckbox(
    BuildContext context,
    int rowIndex,
    bool isSelected,
    BetterDataTableTheme theme,
  ) {
    void onChanged(bool? v) {
      setState(() {
        if (v == true) {
          _selectedRows.add(rowIndex);
        } else {
          _selectedRows.remove(rowIndex);
        }
      });
      widget.onRowSelected?.call(rowIndex);
    }

    return Container(
      padding: theme.cellPadding,
      alignment: Alignment.center,
      child:
          widget.checkboxBuilder?.call(context, isSelected, onChanged) ??
          Checkbox(value: isSelected, onChanged: onChanged),
    );
  }

  Widget _buildDataCell(
    BuildContext context,
    Widget cell,
    BetterDataTableColumn column,
    BetterDataTableRow row,
    int rowIndex,
    int originalColumnIndex,
    BetterDataTableTheme theme, {
    int nestingLevel = 0,
  }) {
    if (widget.cellBuilder != null) {
      return widget.cellBuilder!(
        context,
        cell,
        column,
        row,
        rowIndex,
        originalColumnIndex,
      );
    }

    // Add indentation for nested rows
    Widget cellContent = cell;
    if (nestingLevel > 0) {
      cellContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: nestingLevel * 24.0), // 24px per level
          Expanded(child: cell),
        ],
      );
    }

    return InkWell(
      onTap: widget.onCellTap != null
          ? () => widget.onCellTap!(rowIndex, originalColumnIndex)
          : null,
      child: Container(
        padding: column.cellPadding ?? row.cellPadding ?? theme.cellPadding,
        alignment:
            column.cellAlignment ?? row.cellAlignment ?? theme.cellAlignment,
        constraints: column.constraints,
        child: DefaultTextStyle.merge(
          style: theme.cellTextStyle ?? const TextStyle(),
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildExpandToggle(
    BuildContext context,
    BetterDataTableRow row,
    String rowPath,
    bool hasChildren,
    bool hasExpandableContent,
    BetterDataTableTheme theme,
  ) {
    // Check if custom expandable content exists
    final hasCustomContent = hasExpandableContent &&
        widget.expandableRowBuilder!(context, row, int.parse(rowPath.split('.').first)) != null;

    // Only show toggle if there's something to expand
    final isExpandable = hasChildren || hasCustomContent;

    return Container(
      padding: theme.cellPadding,
      alignment: Alignment.center,
      child: isExpandable
          ? InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (_expandedRows.contains(rowPath)) {
                    _expandedRows.remove(rowPath);
                  } else {
                    _expandedRows.add(rowPath);
                  }
                });
                widget.onRowExpanded?.call(rowPath);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  _expandedRows.contains(rowPath)
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 20,
                ),
              ),
            )
          : null,
    );
  }

  // ── Expanded row ──────────────────────────────────────────────────────────

  TableRow _buildExpandedRow(
    BuildContext context,
    BetterDataTableRow row,
    int rowIndex,
    String rowPath,
    BetterDataTableTheme theme,
  ) {
    final content = widget.expandableRowBuilder!(context, row, rowIndex);
    if (content == null) {
      return TableRow(
        children: List.generate(_totalColumnCount, (_) => const SizedBox.shrink()),
      );
    }

    return TableRow(
      decoration: theme.expandedRowDecoration,
      children: [
        Container(
          padding: theme.expandedRowPadding ?? theme.cellPadding,
          child: content,
        ),
        ...List.generate(
          _totalColumnCount - 1,
          (_) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Groups ─────────────────────────────────────────────────────────────────

  List<TableRow> _buildGroupedRows(
    BuildContext context,
    BetterDataTableTheme theme,
  ) {
    final rows = <TableRow>[];
    final groups = widget.groups!;

    for (var gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      final isCollapsed = _collapsedGroups.contains(gi);

      rows.add(_buildGroupHeader(context, group, gi, isCollapsed, theme));

      if (!isCollapsed) {
        for (
          var ri = group.startIndex;
          ri <= group.endIndex && ri < widget.rows.length;
          ri++
        ) {
          _buildDataRowRecursive(
            context,
            widget.rows[ri],
            ri,
            '$ri',
            0,
            theme,
            rows,
          );
        }
      }
    }

    return rows;
  }

  TableRow _buildGroupHeader(
    BuildContext context,
    BetterDataTableGroup group,
    int groupIndex,
    bool isCollapsed,
    BetterDataTableTheme theme,
  ) {
    Widget content;

    if (widget.groupHeaderBuilder != null) {
      content = widget.groupHeaderBuilder!(context, group, groupIndex);
    } else {
      Widget headerContent = group.header;

      if (group.collapsible) {
        headerContent = Row(
          children: [
            Expanded(child: headerContent),
            Icon(
              isCollapsed ? Icons.chevron_right : Icons.expand_more,
              size: 20,
            ),
          ],
        );
      }

      content = Container(
        padding: theme.groupHeaderPadding ?? theme.cellPadding,
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style:
              theme.groupHeaderTextStyle ??
              const TextStyle(fontWeight: FontWeight.bold),
          child: headerContent,
        ),
      );
    }

    if (group.collapsible) {
      content = InkWell(
        onTap: () {
          setState(() {
            if (_collapsedGroups.contains(groupIndex)) {
              _collapsedGroups.remove(groupIndex);
            } else {
              _collapsedGroups.add(groupIndex);
            }
          });
          widget.onGroupToggled?.call(groupIndex);
        },
        child: content,
      );
    }

    return TableRow(
      decoration: theme.groupHeaderDecoration ?? theme.headerDecoration,
      children: [
        content,
        ...List.generate(_totalColumnCount - 1, (_) => const SizedBox.shrink()),
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  List<TableRow> _buildFooterRows(
    BuildContext context,
    BetterDataTableTheme theme,
  ) {
    return widget.footerRows!.map((row) {
      final cells = <Widget>[];

      if (widget.showCheckboxes) {
        cells.add(const SizedBox.shrink());
      }

      final visible = _visibleColumns;
      for (var vi = 0; vi < visible.length; vi++) {
        final (originalIndex, column) = visible[vi];
        if (originalIndex >= row.cells.length) {
          cells.add(const SizedBox.shrink());
          continue;
        }

        cells.add(
          Container(
            padding:
                column.cellPadding ??
                row.cellPadding ??
                theme.footerCellPadding ??
                theme.cellPadding,
            alignment:
                column.cellAlignment ??
                row.cellAlignment ??
                theme.footerCellAlignment ??
                theme.cellAlignment,
            child: DefaultTextStyle(
              style:
                  theme.footerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
              child: row.cells[originalIndex],
            ),
          ),
        );
      }

      final hasExpandColumn = widget.expandableRowBuilder != null ||
          _anyRowHasChildren(widget.rows);
      if (hasExpandColumn) {
        cells.add(const SizedBox.shrink());
      }

      return TableRow(
        decoration: row.decoration ?? theme.footerDecoration,
        children: cells,
      );
    }).toList();
  }

  // ── Empty / loading ────────────────────────────────────────────────────────

  Widget _buildDefaultLoading() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultEmpty(BetterDataTableTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'No data available',
          style: theme.emptyTextStyle ?? TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
