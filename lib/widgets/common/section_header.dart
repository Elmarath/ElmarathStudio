import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import 'links.dart';

/// Small uppercase label above a heading ("FEATURED", "FROM THE BLOG").
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color ?? context.palette.accent),
    );
  }
}

/// Heading for a page section, with an optional "View all" link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.actionHref,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final String? actionHref;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: Insets.sm)],
                Text(title, style: text.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: Insets.sm),
                  Text(subtitle!, style: text.bodyLarge),
                ],
              ],
            ),
          ),
          if (actionLabel != null && actionHref != null)
            Padding(
              padding: const EdgeInsets.only(left: Insets.md, bottom: 4),
              child: InlineLink(
                label: actionLabel!,
                href: actionHref!,
                trailingIcon: Icons.arrow_forward,
                style: text.labelLarge?.copyWith(color: context.palette.accent),
              ),
            ),
        ],
      ),
    );
  }
}
