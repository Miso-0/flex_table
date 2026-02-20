import 'package:flutter/material.dart';

/// Defines a column in a [BetterDataTable].
///
/// Each column specifies its header widget, width strategy, sorting behavior,
/// and per-column styling overrides.
class BetterDataTableColumn {
  const BetterDataTableColumn({
    required this.header,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.sortable = false,
    this.visible = true,
    this.tooltip,
    this.onTap,
    this.headerPadding,
    this.headerAlignment,
    this.cellPadding,
    this.cellAlignment,
    this.constraints,
  });

  /// Widget displayed in the column header.
  final Widget header;

  /// Width strategy for this column.
  ///
  /// Accepts any [TableColumnWidth]: [FlexColumnWidth], [FixedColumnWidth],
  /// [IntrinsicColumnWidth], or [FractionColumnWidth]. Defaults to
  /// [FlexColumnWidth(1)] if not provided.
  final TableColumnWidth? width;

  /// Minimum width in logical pixels. Wraps [width] with [MaxColumnWidth].
  final double? minWidth;

  /// Maximum width in logical pixels. Wraps [width] with [MinColumnWidth].
  final double? maxWidth;

  /// Whether tapping this column header triggers sorting via [BetterDataTable.onSort].
  final bool sortable;

  /// Whether this column is rendered. Hidden columns are completely excluded
  /// from layout. Defaults to `true`.
  final bool visible;

  /// Tooltip shown when hovering over the column header.
  final String? tooltip;

  /// Tap callback for non-sortable column headers. Ignored when [sortable] is
  /// `true` and [BetterDataTable.onSort] is provided.
  final VoidCallback? onTap;

  /// Padding applied to this column's header cell, overriding
  /// [BetterDataTableTheme.headerCellPadding].
  final EdgeInsets? headerPadding;

  /// Alignment of the header cell content, overriding
  /// [BetterDataTableTheme.headerCellAlignment].
  final Alignment? headerAlignment;

  /// Padding applied to all data cells in this column, overriding
  /// [BetterDataTableTheme.cellPadding].
  final EdgeInsets? cellPadding;

  /// Alignment of all data cell content in this column, overriding
  /// [BetterDataTableTheme.cellAlignment].
  final Alignment? cellAlignment;

  /// Additional box constraints applied to data cells in this column.
  final BoxConstraints? constraints;

  /// Creates a copy of this column with the given fields replaced.
  BetterDataTableColumn copyWith({
    Widget? header,
    TableColumnWidth? width,
    double? minWidth,
    double? maxWidth,
    bool? sortable,
    bool? visible,
    String? tooltip,
    VoidCallback? onTap,
    EdgeInsets? headerPadding,
    Alignment? headerAlignment,
    EdgeInsets? cellPadding,
    Alignment? cellAlignment,
    BoxConstraints? constraints,
  }) {
    return BetterDataTableColumn(
      header: header ?? this.header,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      sortable: sortable ?? this.sortable,
      visible: visible ?? this.visible,
      tooltip: tooltip ?? this.tooltip,
      onTap: onTap ?? this.onTap,
      headerPadding: headerPadding ?? this.headerPadding,
      headerAlignment: headerAlignment ?? this.headerAlignment,
      cellPadding: cellPadding ?? this.cellPadding,
      cellAlignment: cellAlignment ?? this.cellAlignment,
      constraints: constraints ?? this.constraints,
    );
  }
}
