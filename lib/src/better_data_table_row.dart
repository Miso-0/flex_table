import 'package:flutter/material.dart';

/// Defines a data row in a [BetterDataTable].
class BetterDataTableRow {
  const BetterDataTableRow({
    required this.cells,
    this.decoration,
    this.onTap,
    this.cellPadding,
    this.cellAlignment,
    this.tooltip,
    this.key,
    this.children,
  });

  /// Widgets rendered in each cell. The number of cells should match the number
  /// of visible columns. Extra cells are ignored; missing cells render empty.
  final List<Widget> cells;

  /// Optional decoration applied to the entire row, overriding theme defaults.
  final BoxDecoration? decoration;

  /// Tap callback specific to this row. Called in addition to
  /// [BetterDataTable.onRowTap].
  final VoidCallback? onTap;

  /// Padding applied to all cells in this row, overriding
  /// [BetterDataTableTheme.cellPadding] and column-level padding.
  final EdgeInsets? cellPadding;

  /// Alignment of all cells in this row, overriding [BetterDataTableTheme.cellAlignment]
  /// and column-level alignment.
  final Alignment? cellAlignment;

  /// Tooltip message shown when hovering over any cell in this row.
  final String? tooltip;

  /// Optional key, useful for list animations.
  final Key? key;

  /// Optional child rows for hierarchical/nested table structures.
  /// When provided, an expand/collapse toggle is automatically shown.
  final List<BetterDataTableRow>? children;

  /// Creates a copy of this row with the given fields replaced.
  BetterDataTableRow copyWith({
    List<Widget>? cells,
    BoxDecoration? decoration,
    VoidCallback? onTap,
    EdgeInsets? cellPadding,
    Alignment? cellAlignment,
    String? tooltip,
    Key? key,
    List<BetterDataTableRow>? children,
  }) {
    return BetterDataTableRow(
      cells: cells ?? this.cells,
      decoration: decoration ?? this.decoration,
      onTap: onTap ?? this.onTap,
      cellPadding: cellPadding ?? this.cellPadding,
      cellAlignment: cellAlignment ?? this.cellAlignment,
      tooltip: tooltip ?? this.tooltip,
      key: key ?? this.key,
      children: children ?? this.children,
    );
  }
}
