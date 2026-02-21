# better_data_table

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
- **Hierarchical / nested rows** — add `children` to any `BetterDataTableRow` for
  infinitely deep sub-rows, indented automatically per level (like ClickUp tasks)
- **Expandable rows** — tap an indicator to reveal arbitrary content below a row
- **Collapsible groups** — named sections that users can collapse to hide rows
- **Column visibility** — hide/show columns at runtime with `visible: false`
- **Striped / alternating rows** — `BetterDataTableTheme.striped(context)`
- **Footer rows** — for totals, averages, or any summary data
- **Loading & empty states** — sensible defaults with custom builder overrides
- **Hover effects** — mouse-region highlighting (disable for touch-only targets)
- **Row & cell interactions** — `onRowTap`, `onRowDoubleTap`, `onRowLongPress`,
  `onRowSecondaryTap`, `onCellTap`
- **Per-row dividers** — `rowDivider: BorderSide(...)` paints a full-width line
  between rows
- **Column tooltips** — `BetterDataTableColumn(tooltip: 'hint')`
- **Row tooltips** — `BetterDataTableRow(tooltip: 'hint')`
- **Pointer cursor on clickable rows** — rows with tap handlers automatically
  show a pointer cursor on desktop/web
- **Fully customizable icons** — replace sort arrows, row expand/collapse toggles,
  and group chevrons with any widget via `BetterDataTableTheme`
- **Comprehensive theming** — override every decoration, padding, alignment, and
  text style via `BetterDataTableTheme` and its `copyWith`
- **`copyWith` everywhere** — `BetterDataTableColumn`, `BetterDataTableRow`,
  `BetterDataTableGroup`, and `BetterDataTableTheme` all support immutable updates

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  better_data_table: ^0.1.0
```

Then import it:

```dart
import 'package:better_data_table/better_data_table.dart';
```

## Usage

### Basic table

```dart
BetterDataTable(
  columns: [
    BetterDataTableColumn(header: Text('Name'), width: FlexColumnWidth(2)),
    BetterDataTableColumn(header: Text('Age'),  width: FixedColumnWidth(80)),
    BetterDataTableColumn(header: Text('City'), width: FlexColumnWidth(1)),
  ],
  rows: [
    BetterDataTableRow(cells: [Text('Alice'), Text('28'), Text('New York')]),
    BetterDataTableRow(cells: [Text('Bob'),   Text('34'), Text('Berlin')]),
  ],
)
```

### Sortable columns

```dart
BetterDataTable(
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
    BetterDataTableColumn(header: Text('Name'), sortable: true),
    BetterDataTableColumn(header: Text('Age'),  sortable: true),
  ],
  rows: _people.map((p) =>
    BetterDataTableRow(cells: [Text(p.name), Text('${p.age}')])).toList(),
)
```

### Row selection with checkboxes

```dart
BetterDataTable(
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

Add `children` to any `BetterDataTableRow` to create an infinitely deep tree of
sub-rows. The expand/collapse toggle appears automatically, and each level is
indented by 24 px. Expand state is tracked by a dot-separated path string
(`"0"`, `"0.1"`, `"0.1.2"`, …).

```dart
// State: Set<String> _expanded = {};

BetterDataTable(
  expandedRows: _expanded,
  onRowExpanded: (path) => setState(() {
    _expanded.contains(path)
        ? _expanded.remove(path)
        : _expanded.add(path);
  }),
  columns: [
    BetterDataTableColumn(header: Text('Task'),     width: FlexColumnWidth(3)),
    BetterDataTableColumn(header: Text('Status'),   width: FlexColumnWidth(1)),
    BetterDataTableColumn(header: Text('Priority'), width: FixedColumnWidth(100)),
  ],
  rows: [
    BetterDataTableRow(
      cells: [Text('Project Alpha'), Text('In Progress'), Text('High')],
      children: [
        BetterDataTableRow(
          cells: [Text('Phase 1'), Text('Completed'), Text('High')],
          children: [
            BetterDataTableRow(
              cells: [Text('Research'), Text('Done'), Text('Medium')],
            ),
            BetterDataTableRow(
              cells: [Text('Define requirements'), Text('Done'), Text('High')],
              // nest deeper — no limit
              children: [
                BetterDataTableRow(
                  cells: [Text('Write specs'), Text('Done'), Text('High')],
                ),
              ],
            ),
          ],
        ),
        BetterDataTableRow(
          cells: [Text('Phase 2'), Text('In Progress'), Text('High')],
        ),
      ],
    ),
    BetterDataTableRow(
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

BetterDataTable(
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
BetterDataTable(
  collapsedGroups: _collapsed,
  onGroupToggled: (index) => setState(() {
    _collapsed.contains(index)
        ? _collapsed.remove(index)
        : _collapsed.add(index);
  }),
  groups: [
    BetterDataTableGroup(
      header: Text('Fruits'),
      startIndex: 0,
      endIndex: 2,
      collapsible: true,
    ),
    BetterDataTableGroup(
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
BetterDataTable(
  theme: BetterDataTableTheme.striped(context),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Hide a column at runtime

```dart
BetterDataTableColumn(
  header: Text('Internal ID'),
  visible: _showId,   // toggle this to show/hide the column
)
```

### Footer row

```dart
BetterDataTable(
  footerRows: [
    BetterDataTableRow(cells: [Text('Total'), Text('\$99.00')]),
  ],
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Custom theme

```dart
BetterDataTable(
  theme: BetterDataTableTheme.defaultTheme(context).copyWith(
    cellPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    headerTextStyle: TextStyle(fontWeight: FontWeight.w900),
    rowDivider: BorderSide(color: Colors.grey.shade200),
  ),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Custom icons

Every icon used by the table can be replaced with any widget via
`BetterDataTableTheme`. Pass `null` (the default) to keep the built-in icon.

| Theme field | Default icon | Where it appears |
|---|---|---|
| `sortAscendingIcon` | `Icons.arrow_upward` (16 px) | Sorted column header — ascending |
| `sortDescendingIcon` | `Icons.arrow_downward` (16 px) | Sorted column header — descending |
| `rowExpandIcon` | `Icons.expand_more` (20 px) | Collapsed expandable / hierarchical row |
| `rowCollapseIcon` | `Icons.expand_less` (20 px) | Expanded expandable / hierarchical row |
| `groupExpandIcon` | `Icons.chevron_right` (20 px) | Collapsed group header |
| `groupCollapseIcon` | `Icons.expand_more` (20 px) | Expanded group header |

```dart
BetterDataTable(
  theme: BetterDataTableTheme.defaultTheme(context).copyWith(
    // Replace sort arrows with triangles
    sortAscendingIcon:  Icon(Icons.arrow_drop_up,   size: 20, color: Colors.blue),
    sortDescendingIcon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.blue),
    // Use custom SVG or any widget for row expand toggles
    rowExpandIcon:   Icon(Icons.add_circle_outline,    size: 18),
    rowCollapseIcon: Icon(Icons.remove_circle_outline, size: 18),
    // Custom group chevrons
    groupExpandIcon:   Icon(Icons.chevron_right, size: 20),
    groupCollapseIcon: Icon(Icons.expand_more,   size: 20),
  ),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

### Pointer cursor on clickable rows

Rows that have any tap handler (`onRowTap`, `onRowDoubleTap`, `onRowLongPress`,
`onRowSecondaryTap`, or `BetterDataTableRow.onTap`) automatically show the
system pointer cursor on desktop and web — no extra configuration needed.

```dart
BetterDataTable(
  onRowTap: (index) => print('tapped row $index'),
  columns: [ /* ... */ ],
  rows: _rows,
)
```

## Additional information

- The table has **no built-in scrolling**. Wrap it in a `SingleChildScrollView`
  (horizontal and/or vertical) when content may overflow.
- File issues and feature requests on
  [GitHub](https://github.com/Miso-0/better_data_table/issues).
- Contributions are welcome — please open a PR with tests for any new behaviour.
