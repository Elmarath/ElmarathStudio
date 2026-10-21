import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../content/markdown_blocks.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';

/// "On this page": the h2/h3 headings of a page, highlighting the one in view.
class DocToc extends StatelessWidget {
  const DocToc({super.key, required this.headings, required this.active, required this.onSelect});

  final List<MdHeading> headings;
  final ValueListenable<String?> active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Insets.sm, Insets.xxl, Insets.lg, Insets.xxl),
      child: ValueListenableBuilder(
        valueListenable: active,
        builder: (context, activeId, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: Insets.md),
              child: Text('ON THIS PAGE', style: text.labelSmall),
            ),
            for (final h in headings)
              InkWell(
                onTap: () => onSelect(h.id),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: EdgeInsets.fromLTRB(h.level == 3 ? 26 : 14, 6, 4, 6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: h.id == activeId ? p.accent : p.border, width: 2),
                    ),
                  ),
                  child: Text(
                    h.text,
                    style: text.bodySmall?.copyWith(
                      fontSize: 13.5,
                      color: h.id == activeId ? p.accent : p.textSecondary,
                      fontWeight: h.id == activeId ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
