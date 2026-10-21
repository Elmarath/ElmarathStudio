import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Lays out cards in as many columns as fit (at least [minItemWidth] each).
/// Cards in the same row get the same height.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 280,
    this.maxColumns = 4,
    this.spacing = Insets.md,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fit = ((constraints.maxWidth + spacing) / (minItemWidth + spacing)).floor();
      final columns = fit.clamp(1, maxColumns);
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += columns) {
        final rowChildren = <Widget>[];
        for (var c = 0; c < columns; c++) {
          if (c > 0) rowChildren.add(SizedBox(width: spacing));
          final index = i + c;
          rowChildren.add(Expanded(child: index < children.length ? children[index] : const SizedBox()));
        }
        if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
        rows.add(IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: rowChildren),
        ));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    });
  }
}
