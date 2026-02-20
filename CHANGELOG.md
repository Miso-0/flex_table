## 0.1.0

Initial public release.

**New features:**
- `FlexibleDataTableColumn.visible` — hide/show individual columns at runtime
- `FlexibleDataTableColumn.tooltip` — tooltip on column header
- `FlexibleDataTableColumn.minWidth` / `maxWidth` — now actually enforced via
  `MaxColumnWidth` / `MinColumnWidth` wrappers
- `FlexibleDataTableColumn.copyWith()`
- `FlexibleDataTableRow.tooltip` — tooltip on hover over entire row
- `FlexibleDataTableRow.copyWith()`
- `FlexibleDataTableGroup.collapsible` — users can collapse/expand groups;
  controlled via `FlexibleDataTable.collapsedGroups` + `onGroupToggled`
- `FlexibleDataTableGroup.copyWith()`
- `FlexibleDataTable.onRowSecondaryTap` — right-click / secondary tap callback
- `FlexibleDataTable.rowDivider` (`BorderSide?`) — full-width row divider drawn as
  a bottom border on each data row (replaces the broken single-cell `divider`)
- `FlexibleDataTable.collapsedGroups` + `FlexibleDataTable.onGroupToggled`

**Fixed:**
- `FlexibleDataTableTheme.striped` now actually applies alternating row colors
- `alternateRowDecoration` is now used for odd-indexed rows
- `cellTextStyle` is now applied to every data cell via `DefaultTextStyle.merge`
- `minWidth` / `maxWidth` on columns were defined but had no effect — fixed
- Expand toggle now has a circular `InkWell` splash for better touch feedback

**Structural:**
- Split into `lib/src/` modules (`flexible_data_table_column.dart`,
  `flexible_data_table_row.dart`, `flexible_data_table_group.dart`, `flexible_data_table_theme.dart`,
  `flexible_data_table_widget.dart`) with a clean barrel export in `lib/flexible_data_table.dart`
- 46 widget and unit tests added
