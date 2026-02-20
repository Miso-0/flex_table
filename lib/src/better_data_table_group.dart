import 'package:flutter/material.dart';

/// Defines a named section of rows in a [BetterDataTable].
///
/// Groups add a spanning header above a contiguous range of rows. When
/// [collapsible] is `true`, users can tap the header to show or hide the rows.
class BetterDataTableGroup {
  const BetterDataTableGroup({
    required this.header,
    required this.startIndex,
    required this.endIndex,
    this.collapsible = false,
    this.key,
  });

  /// Widget displayed as the group header, spanning all columns.
  final Widget header;

  /// First row index (inclusive) belonging to this group.
  final int startIndex;

  /// Last row index (inclusive) belonging to this group.
  final int endIndex;

  /// When `true`, a toggle icon is shown in the group header and users can
  /// collapse the group to hide its rows. Collapsed state is tracked via
  /// [BetterDataTable.collapsedGroups] and [BetterDataTable.onGroupToggled].
  final bool collapsible;

  /// Optional key, useful for list animations.
  final Key? key;

  /// Creates a copy of this group with the given fields replaced.
  BetterDataTableGroup copyWith({
    Widget? header,
    int? startIndex,
    int? endIndex,
    bool? collapsible,
    Key? key,
  }) {
    return BetterDataTableGroup(
      header: header ?? this.header,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      collapsible: collapsible ?? this.collapsible,
      key: key ?? this.key,
    );
  }
}
