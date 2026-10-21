import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';

/// A Docusaurus-style callout box (`:::note`, `:::tip`, `:::info`, `:::warning`, `:::danger`).
class Admonition extends StatelessWidget {
  const Admonition({super.key, required this.type, required this.child, this.title});

  final String type;
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (color, icon, label) = switch (type) {
      'tip' => (p.tip, Icons.lightbulb_outline, 'Tip'),
      'info' => (p.info, Icons.info_outline, 'Info'),
      'warning' => (p.warning, Icons.warning_amber_rounded, 'Warning'),
      'danger' => (p.danger, Icons.local_fire_department_outlined, 'Danger'),
      _ => (p.note, Icons.sticky_note_2_outlined, 'Note'),
    };
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: p.isDark ? 0.07 : 0.06),
        borderRadius: Radii.mdAll,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: Radii.mdAll,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Insets.md + 2, Insets.md, Insets.md + 4, Insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: Insets.sm),
                    Expanded(
                      child: Text(
                        title ?? label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.sm),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
