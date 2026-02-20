import 'package:flutter/material.dart';

/// Visual configuration for a [FlexibleDataTable].
///
/// Pass a [FlexibleDataTableTheme] to [FlexibleDataTable.theme] to override defaults. Use the
/// factory constructors [FlexibleDataTableTheme.defaultTheme], [FlexibleDataTableTheme.minimal],
/// or [FlexibleDataTableTheme.striped] as starting points, then call [copyWith] to
/// adjust individual properties.
class FlexibleDataTableTheme {
  const FlexibleDataTableTheme({
    this.headerDecoration,
    this.rowDecoration,
    this.alternateRowDecoration,
    this.hoveredRowDecoration,
    this.selectedRowDecoration,
    this.footerDecoration,
    this.expandedRowDecoration,
    this.groupHeaderDecoration,
    this.border,
    this.headerCellPadding = const EdgeInsets.all(12),
    this.cellPadding = const EdgeInsets.all(12),
    this.footerCellPadding,
    this.expandedRowPadding,
    this.groupHeaderPadding,
    this.headerCellAlignment = Alignment.centerLeft,
    this.cellAlignment = Alignment.centerLeft,
    this.footerCellAlignment,
    this.headerTextStyle,
    this.cellTextStyle,
    this.footerTextStyle,
    this.groupHeaderTextStyle,
    this.emptyTextStyle,
    this.sortIconColor,
    this.enableHoverEffect = true,
  });

  /// Decoration applied to the header row.
  final BoxDecoration? headerDecoration;

  /// Decoration applied to odd-indexed (0, 2, 4 …) data rows.
  final BoxDecoration? rowDecoration;

  /// Decoration applied to even-indexed (1, 3, 5 …) data rows when using
  /// [FlexibleDataTableTheme.striped]. Also used by the striped factory.
  final BoxDecoration? alternateRowDecoration;

  /// Decoration applied when the pointer hovers over a data row.
  final BoxDecoration? hoveredRowDecoration;

  /// Decoration applied to selected data rows.
  final BoxDecoration? selectedRowDecoration;

  /// Decoration applied to footer rows.
  final BoxDecoration? footerDecoration;

  /// Decoration applied to the expanded-content row.
  final BoxDecoration? expandedRowDecoration;

  /// Decoration applied to group header rows.
  final BoxDecoration? groupHeaderDecoration;

  /// Border drawn around and between table cells.
  final TableBorder? border;

  /// Padding inside header cells. Defaults to `EdgeInsets.all(12)`.
  final EdgeInsets headerCellPadding;

  /// Padding inside data cells. Defaults to `EdgeInsets.all(12)`.
  final EdgeInsets cellPadding;

  /// Padding inside footer cells. Falls back to [cellPadding] when `null`.
  final EdgeInsets? footerCellPadding;

  /// Padding around the expanded row content. Falls back to [cellPadding].
  final EdgeInsets? expandedRowPadding;

  /// Padding inside group header cells. Falls back to [cellPadding].
  final EdgeInsets? groupHeaderPadding;

  /// Alignment of header cell content.
  final Alignment headerCellAlignment;

  /// Alignment of data cell content.
  final Alignment cellAlignment;

  /// Alignment of footer cell content. Falls back to [cellAlignment].
  final Alignment? footerCellAlignment;

  /// Text style applied to header cell content via [DefaultTextStyle].
  final TextStyle? headerTextStyle;

  /// Text style applied to data cell content via [DefaultTextStyle].
  final TextStyle? cellTextStyle;

  /// Text style applied to footer cell content via [DefaultTextStyle].
  final TextStyle? footerTextStyle;

  /// Text style applied to group header content via [DefaultTextStyle].
  final TextStyle? groupHeaderTextStyle;

  /// Text style for the default empty-state message.
  final TextStyle? emptyTextStyle;

  /// Color of the sort direction arrow icon.
  final Color? sortIconColor;

  /// Whether hovering a row triggers a visual decoration change.
  /// Disable for tables on touch-only devices. Defaults to `true`.
  final bool enableHoverEffect;

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Material Design 3 theme derived from the ambient [ThemeData].
  factory FlexibleDataTableTheme.defaultTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FlexibleDataTableTheme(
      headerDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colorScheme.outline)),
      ),
      rowDecoration: BoxDecoration(color: colorScheme.surface),
      alternateRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      hoveredRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
      ),
      selectedRowDecoration: BoxDecoration(color: colorScheme.primaryContainer),
      footerDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: colorScheme.outline)),
      ),
      expandedRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      groupHeaderDecoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
      ),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      headerTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      cellTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      footerTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      groupHeaderTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSecondaryContainer,
      ),
      emptyTextStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      sortIconColor: colorScheme.primary,
    );
  }

  /// Minimal theme: no decorations, hover disabled.
  factory FlexibleDataTableTheme.minimal() {
    return const FlexibleDataTableTheme(enableHoverEffect: false);
  }

  /// Striped theme: odd rows use [rowDecoration], even rows use
  /// [alternateRowDecoration] for visual separation.
  factory FlexibleDataTableTheme.striped(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = FlexibleDataTableTheme.defaultTheme(context);

    return base.copyWith(
      rowDecoration: BoxDecoration(color: colorScheme.surface),
      alternateRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a new [FlexibleDataTableTheme] with the given fields replaced.
  FlexibleDataTableTheme copyWith({
    BoxDecoration? headerDecoration,
    BoxDecoration? rowDecoration,
    BoxDecoration? alternateRowDecoration,
    BoxDecoration? hoveredRowDecoration,
    BoxDecoration? selectedRowDecoration,
    BoxDecoration? footerDecoration,
    BoxDecoration? expandedRowDecoration,
    BoxDecoration? groupHeaderDecoration,
    TableBorder? border,
    EdgeInsets? headerCellPadding,
    EdgeInsets? cellPadding,
    EdgeInsets? footerCellPadding,
    EdgeInsets? expandedRowPadding,
    EdgeInsets? groupHeaderPadding,
    Alignment? headerCellAlignment,
    Alignment? cellAlignment,
    Alignment? footerCellAlignment,
    TextStyle? headerTextStyle,
    TextStyle? cellTextStyle,
    TextStyle? footerTextStyle,
    TextStyle? groupHeaderTextStyle,
    TextStyle? emptyTextStyle,
    Color? sortIconColor,
    bool? enableHoverEffect,
  }) {
    return FlexibleDataTableTheme(
      headerDecoration: headerDecoration ?? this.headerDecoration,
      rowDecoration: rowDecoration ?? this.rowDecoration,
      alternateRowDecoration:
          alternateRowDecoration ?? this.alternateRowDecoration,
      hoveredRowDecoration: hoveredRowDecoration ?? this.hoveredRowDecoration,
      selectedRowDecoration:
          selectedRowDecoration ?? this.selectedRowDecoration,
      footerDecoration: footerDecoration ?? this.footerDecoration,
      expandedRowDecoration:
          expandedRowDecoration ?? this.expandedRowDecoration,
      groupHeaderDecoration:
          groupHeaderDecoration ?? this.groupHeaderDecoration,
      border: border ?? this.border,
      headerCellPadding: headerCellPadding ?? this.headerCellPadding,
      cellPadding: cellPadding ?? this.cellPadding,
      footerCellPadding: footerCellPadding ?? this.footerCellPadding,
      expandedRowPadding: expandedRowPadding ?? this.expandedRowPadding,
      groupHeaderPadding: groupHeaderPadding ?? this.groupHeaderPadding,
      headerCellAlignment: headerCellAlignment ?? this.headerCellAlignment,
      cellAlignment: cellAlignment ?? this.cellAlignment,
      footerCellAlignment: footerCellAlignment ?? this.footerCellAlignment,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      footerTextStyle: footerTextStyle ?? this.footerTextStyle,
      groupHeaderTextStyle: groupHeaderTextStyle ?? this.groupHeaderTextStyle,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      sortIconColor: sortIconColor ?? this.sortIconColor,
      enableHoverEffect: enableHoverEffect ?? this.enableHoverEffect,
    );
  }
}
