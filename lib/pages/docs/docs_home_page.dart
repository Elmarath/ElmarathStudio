import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/plugin_card.dart';
import '../../widgets/common/hover_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/layout/content_width.dart';
import '../../widgets/layout/responsive_grid.dart';

/// `/docs`: getting-started pages and a card for every plugin.
class DocsHomePage extends StatelessWidget {
  const DocsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.content;
    final text = Theme.of(context).textTheme;
    final guides = content.docsRoot.children.whereType<DocPage>().toList();

    return PageTitle(
      title: 'Documentation',
      child: ContentScrollView(
        child: ContentWidth(
          maxWidth: 1040,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Documentation'),
                const SizedBox(height: Insets.sm),
                Text('Plugin docs', style: text.displaySmall),
                const SizedBox(height: Insets.md),
                Text(
                  'Guides for every Elmarath plugin, kept up to date whenever a feature changes. '
                  'Pick a plugin to get started, or press ⌘K / Ctrl K to search.',
                  style: text.bodyLarge,
                ),
                if (guides.isNotEmpty) ...[
                  const SizedBox(height: Insets.xl),
                  for (final guide in guides) ...[
                    _GuideCard(page: guide),
                    const SizedBox(height: Insets.sm),
                  ],
                ],
                const SizedBox(height: Insets.xxl),
                const SectionHeader(title: 'Plugins'),
                ResponsiveGrid(
                  minItemWidth: 380,
                  maxColumns: 2,
                  children: [for (final plugin in content.plugins) PluginCard(category: plugin)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.page});

  final DocPage page;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return HoverCard(
      onTap: () => context.go(page.route),
      padding: const EdgeInsets.all(Insets.lg - 4),
      builder: (context, hovered) => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.12), borderRadius: Radii.mdAll),
            child: Icon(Icons.rocket_launch_outlined, color: p.accent, size: 22),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start here', style: text.labelSmall?.copyWith(color: p.accent)),
                const SizedBox(height: 2),
                Text(page.title, style: text.titleMedium),
              ],
            ),
          ),
          AnimatedSlide(
            offset: Offset(hovered ? 0.2 : 0, 0),
            duration: Motion.fast,
            child: Icon(Icons.arrow_forward, color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}
