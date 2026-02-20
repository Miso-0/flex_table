## 0.1.0

Initial public release.

**New features:**
- `BetterDataTableColumn.visible` — hide/show individual columns at runtime
- `BetterDataTableColumn.tooltip` — tooltip on column header
- `BetterDataTableColumn.minWidth` / `maxWidth` — now actually enforced via
  `MaxColumnWidth` / `MinColumnWidth` wrappers
- `BetterDataTableColumn.copyWith()`
- `BetterDataTableRow.tooltip` — tooltip on hover over entire row
- `BetterDataTableRow.copyWith()`
- `BetterDataTableGroup.collapsible` — users can collapse/expand groups;
  controlled via `BetterDataTable.collapsedGroups` + `onGroupToggled`
- `BetterDataTableGroup.copyWith()`
- `BetterDataTable.onRowSecondaryTap` — right-click / secondary tap callback
- `BetterDataTable.rowDivider` (`BorderSide?`) — full-width row divider drawn as
  a bottom border on each data row (replaces the broken single-cell `divider`)
- `BetterDataTable.collapsedGroups` + `BetterDataTable.onGroupToggled`

**Fixed:**
- `BetterDataTableTheme.striped` now actually applies alternating row colors
- `alternateRowDecoration` is now used for odd-indexed rows
- `cellTextStyle` is now applied to every data cell via `DefaultTextStyle.merge`
- `minWidth` / `maxWidth` on columns were defined but had no effect — fixed
- Expand toggle now has a circular `InkWell` splash for better touch feedback

**Structural:**
- Split into `lib/src/` modules (`better_data_table_column.dart`,
  `better_data_table_row.dart`, `better_data_table_group.dart`, `better_data_table_theme.dart`,
  `better_data_table_widget.dart`) with a clean barrel export in `lib/better_data_table.dart`
- 46 widget and unit tests added
