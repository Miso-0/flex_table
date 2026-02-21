## 0.2.1

**Fixed:**
- **Expand icon displays at true size** — the expand toggle cell no longer applies
  `cellPadding` to its container, which was shrinking the available space in the
  fixed-width (48 px) column and clipping larger custom icons
- **Custom expand icons rendered without extra padding** — the inner `Padding(EdgeInsets.all(4))`
  now wraps only the default fallback icons; widgets supplied via
  `BetterDataTableTheme.rowExpandIcon` / `rowCollapseIcon` are rendered as-is

---

## 0.2.0

**New features:**
- **Pointer cursor on clickable rows** — rows with any tap handler (`onRowTap`,
  `onRowDoubleTap`, `onRowLongPress`, `onRowSecondaryTap`, `BetterDataTableRow.onTap`)
  automatically show `SystemMouseCursors.click` on desktop and web
- **Fully customizable icons** — six new `Widget?` fields on `BetterDataTableTheme`
  let you replace every icon with any widget:
  - `sortAscendingIcon` / `sortDescendingIcon` — sort direction indicators in column headers
  - `rowExpandIcon` / `rowCollapseIcon` — expand/collapse toggle on hierarchical and
    expandable rows
  - `groupExpandIcon` / `groupCollapseIcon` — chevron in collapsible group headers
- **No empty box for non-expandable rows** — when the expand column is present but a
  row has no children and no expandable content, the cell now renders as
  `SizedBox.shrink()` instead of a padded empty container

---

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
