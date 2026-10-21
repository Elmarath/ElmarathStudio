import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/text_utils.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/post_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/layout/content_width.dart';
import '../../widgets/layout/responsive_grid.dart';

/// `/blog` and `/blog?tag=<tag>`.
class BlogListPage extends StatelessWidget {
  const BlogListPage({super.key, this.tag});

  final String? tag;

  @override
  Widget build(BuildContext context) {
    final content = context.content;
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final size = ScreenSize.of(context);
    final selected = tag == null ? null : slugify(tag!);
    final posts = selected == null
        ? content.posts
        : content.posts.where((post) => post.tags.any((t) => slugify(t) == selected)).toList();
    final featured = selected == null && !size.isCompact && posts.isNotEmpty ? posts.first : null;
    final rest = featured == null ? posts : posts.skip(1).toList();

    return PageTitle(
      title: 'Blog',
      child: PageScroll(
        children: [
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.only(top: Insets.xxl + 8, bottom: Insets.section),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('Dev blog'),
                  const SizedBox(height: Insets.sm),
                  Text('Devlogs & deep dives', style: text.displaySmall),
                  const SizedBox(height: Insets.md),
                  Text(
                    "Notes from building Hermod's Ride and the plugins on this site.",
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: Insets.lg),
                  Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: selected == null,
                        onSelected: (_) => context.go('/blog'),
                      ),
                      for (final t in content.tags)
                        ChoiceChip(
                          label: Text(t),
                          selected: slugify(t) == selected,
                          onSelected: (_) => context.go('/blog?tag=${Uri.encodeQueryComponent(slugify(t))}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: Insets.xl),
                  if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
                      child: Text('No posts here yet.', style: text.bodyLarge?.copyWith(color: p.textMuted)),
                    ),
                  if (featured != null) ...[
                    PostCard(post: featured, featured: true),
                    const SizedBox(height: Insets.md),
                  ],
                  ResponsiveGrid(
                    minItemWidth: 300,
                    maxColumns: 3,
                    children: [for (final post in rest) PostCard(post: post)],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
