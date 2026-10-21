import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/cards/post_card.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';
import '../../../widgets/layout/responsive_grid.dart';

class LatestPostsSection extends StatelessWidget {
  const LatestPostsSection({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final posts = context.content.posts.take(count).toList();
    if (posts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Insets.section),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              eyebrow: 'From the blog',
              title: 'Latest posts',
              actionLabel: 'All posts',
              actionHref: '/blog',
            ),
            ResponsiveGrid(
              minItemWidth: 300,
              maxColumns: 3,
              children: [for (final post in posts) PostCard(post: post)],
            ),
          ],
        ),
      ),
    );
  }
}
