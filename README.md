# flexible_data_table

A highly customizable Flutter table widget built on top of Flutter's native
`Table`. It covers the common table patterns you reach for in data-heavy apps —
without locking you into a rigid design.

## Features

- **Flexible column widths** — `FlexColumnWidth`, `FixedColumnWidth`,
  `IntrinsicColumnWidth`, `FractionColumnWidth`, or mix `minWidth`/`maxWidth`
  constraints
- **Sortable columns** — built-in ascending/descending arrow icons,
  `onSort` callback
- **Row selection** — leading checkbox column, select-all tristate, custom
  checkbox builder
- **Hierarchical / nested rows** — add `children` to any `FlexibleDataTableRow` for
  infinitely deep sub-rows, indented automatically per level (like ClickUp tasks)
- **Expandable rows** — tap an indicator to reveal arbitrary content below a row
- **Collapsible groups** — named sections that users can collapse to hide rows
- **Column visibility** — hide/show columns at runtime with `visible: false`
- **Striped / alternating rows** — `FlexibleDataTableTheme.striped(context)`
- **Footer rows** — for totals, averages, or any summary data
- **Loading & empty states** — sensible defaults with custom builder overrides
- **Hover effects** — mouse-region highlighting (disable for touch-only targets)
- **Row & cell interactions** — `onRowTap`, `onRowDoubleTap`, `onRowLongPress`,
  `onRowSecondaryTap`, `onCellTap`
- **Per-row dividers** — `rowDivider: BorderSide(...)` paints a full-width line
  between rows
- **Column tooltips** — `FlexibleDataTableColumn(tooltip: 'hint')`
- **Row tooltips** — `FlexibleDataTableRow(tooltip: 'hint')`
- **Comprehensive theming** — override every decoration, padding, alignment, and
  text style via `FlexibleDataTableTheme` and its `copyWith`
- **`copyWith` everywhere** — `FlexibleDataTableColumn`, `FlexibleDataTableRow`,
  `FlexibleDataTableGroup`, and `FlexibleDataTableTheme` all support immutable updates

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flexible_data_table: ^0.1.0
```

Then import it:

```dart
import 'package:flexible_data_table/flexible_data_table.dart';
```

## Usage

### Basic table

```dart
FlexibleDataTable(
  columns: [
    FlexibleDataTableColumn(header: Text('Name'), width: FlexColumnWidth(2)),
    FlexibleDataTableColumn(header: Text('Age'),  width: FixedColumnWidth(80)),
    FlexibleDataTableColumn(header: Text('City'), width: FlexColumnWidth(1)),
  ],
  rows: [
    FlexibleDataTableRow(cells: [Text('Alice'), Text('28'), Text('New York')]),
    FlexibleDataTableRow(cells: [Text('Bob'),   Text('34'), Text('Berlin')]),
  ],
)
```

### Sortable columns

```dart
FlexibleDataTable(
  sortColumnIndex: _sortIndex,
  sortAscending: _ascending,
  onSort: (index) {
    setState(() {
      if (_sortIndex == index) {
        _ascending = !_ascending;
      } else {
        _sortIndex = index;
        _ascending = true;
      }
      // sort your data list here
    });
  },
  columns: [
    FlexibleDataTableColumn(header: Text('Name'), sortable: true),
    FlexibleDataTableColumn(header: Text('Age'),  sortable: true),
  ],
  rows: _people.map((p) =>
    FlexibleDataTableRow(cells: [Text(p.name), Text('${p.age}')])).toList(),
)
```

### Row selection with checkboxes

```dart
FlexibleDataTable(
  showCheckboxes: true,
  selectedRows: _selected,
  onRowSelected: (index) => setState(() {
    _selected.contains(index)
        ? _selected.remove(index)
        : _selected.add(index);
  }),
  onSelectAll: (value) => setState(() {
    _selected = value == true
        ? Set.from(List.generate(_rows.length, (i) => i))
        : {};
  }),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Hierarchical / nested rows

Add `children` to any `FlexibleDataTableRow` to create an infinitely deep tree of
sub-rows. The expand/collapse toggle appears automatically, and each level is
indented by 24 px. Expand state is tracked by a dot-separated path string
(`"0"`, `"0.1"`, `"0.1.2"`, …).

```dart
// State: Set<String> _expanded = {};

FlexibleDataTable(
  expandedRows: _expanded,
  onRowExpanded: (path) => setState(() {
    _expanded.contains(path)
        ? _expanded.remove(path)
        : _expanded.add(path);
  }),
  columns: [
    FlexibleDataTableColumn(header: Text('Task'),     width: FlexColumnWidth(3)),
    FlexibleDataTableColumn(header: Text('Status'),   width: FlexColumnWidth(1)),
    FlexibleDataTableColumn(header: Text('Priority'), width: FixedColumnWidth(100)),
  ],
  rows: [
    FlexibleDataTableRow(
      cells: [Text('Project Alpha'), Text('In Progress'), Text('High')],
      children: [
        FlexibleDataTableRow(
          cells: [Text('Phase 1'), Text('Completed'), Text('High')],
          children: [
            FlexibleDataTableRow(
              cells: [Text('Research'), Text('Done'), Text('Medium')],
            ),
            FlexibleDataTableRow(
              cells: [Text('Define requirements'), Text('Done'), Text('High')],
              // nest deeper — no limit
              children: [
                FlexibleDataTableRow(
                  cells: [Text('Write specs'), Text('Done'), Text('High')],
                ),
              ],
            ),
          ],
        ),
        FlexibleDataTableRow(
          cells: [Text('Phase 2'), Text('In Progress'), Text('High')],
        ),
      ],
    ),
    FlexibleDataTableRow(
      cells: [Text('Standalone task'), Text('Completed'), Text('Low')],
    ),
  ],
)
```

### Expandable rows (custom content)

Use `expandableRowBuilder` when you want to show arbitrary content below a row
rather than sub-rows. The builder returns `null` to suppress the toggle on
specific rows.

```dart
// State: Set<String> _expanded = {};

FlexibleDataTable(
  expandedRows: _expanded,
  onRowExpanded: (path) => setState(() {
    _expanded.contains(path)
        ? _expanded.remove(path)
        : _expanded.add(path);
  }),
  expandableRowBuilder: (context, row, index) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Details for row $index'),
  ),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Collapsible groups

```dart
FlexibleDataTable(
  collapsedGroups: _collapsed,
  onGroupToggled: (index) => setState(() {
    _collapsed.contains(index)
        ? _collapsed.remove(index)
        : _collapsed.add(index);
  }),
  groups: [
    FlexibleDataTableGroup(
      header: Text('Fruits'),
      startIndex: 0,
      endIndex: 2,
      collapsible: true,
    ),
    FlexibleDataTableGroup(
      header: Text('Vegetables'),
      startIndex: 3,
      endIndex: 5,
      collapsible: true,
    ),
  ],
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Striped theme

```dart
FlexibleDataTable(
  theme: FlexibleDataTableTheme.striped(context),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Hide a column at runtime

```dart
FlexibleDataTableColumn(
  header: Text('Internal ID'),
  visible: _showId,   // toggle this to show/hide the column
)
```

### Footer row

```dart
FlexibleDataTable(
  footerRows: [
    FlexibleDataTableRow(cells: [Text('Total'), Text('\$99.00')]),
  ],
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Custom theme

```dart
FlexibleDataTable(
  theme: FlexibleDataTableTheme.defaultTheme(context).copyWith(
    cellPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    headerTextStyle: TextStyle(fontWeight: FontWeight.w900),
    rowDivider: BorderSide(color: Colors.grey.shade200),
  ),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

## Additional information

- The table has **no built-in scrolling**. Wrap it in a `SingleChildScrollView`
  (horizontal and/or vertical) when content may overflow.
- File issues and feature requests on
  [GitHub](https://github.com/Miso-0/flexible_data_table/issues).
- Contributions are welcome — please open a PR with tests for any new behaviour.
