import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/text_utils.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/post_card.dart';
import '../../widgets/layout/content_width.dart';
import '../../widgets/layout/responsive_grid.dart';
import 'blog_filter_bar.dart';
import 'featured_post.dart';

/// `/blog` and `/blog?tag=<tag>`, laid out like the Unreal Engine feed:
/// tag filters, one featured post, then a grid of cards.
class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key, this.tag});

  final String? tag;

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  /// Cards shown before "Load more".
  static const _pageSize = 9;
  int _visible = _pageSize;

  @override
  void didUpdateWidget(BlogListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tag != widget.tag) _visible = _pageSize;
  }

  void _select(String? slug) =>
      context.go(slug == null ? '/blog' : '/blog?tag=${Uri.encodeQueryComponent(slug)}');

  @override
  Widget build(BuildContext context) {
    final content = context.content;
    final compact = ScreenSize.of(context).isCompact;
    final selected = widget.tag == null ? null : slugify(widget.tag!);
    final posts = selected == null
        ? content.posts
        : content.posts.where((post) => post.tags.any((t) => slugify(t) == selected)).toList();

    // The newest featured post leads; the rest follow, featured ones first.
    final hero = posts.where((p) => p.featured).firstOrNull ?? posts.firstOrNull;
    final rest = posts.where((p) => p != hero).toList()
      ..sort((a, b) => a.featured == b.featured ? b.date.compareTo(a.date) : (a.featured ? -1 : 1));

    return PageTitle(
      title: 'Blog',
      child: PageScroll(
        children: [
          ContentWidth(
            child: Padding(
              padding: EdgeInsets.only(top: compact ? Insets.lg : Insets.xxl, bottom: Insets.section),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlogFilterBar(tags: content.tags, selected: selected, onSelect: _select),
                  SizedBox(height: compact ? Insets.xxl : 104),
                  if (hero == null)
                    _EmptyState(onShowAll: () => _select(null))
                  else
                    FeaturedPost(post: hero),
                  if (rest.isNotEmpty) ...[
                    SizedBox(height: compact ? Insets.xxl : 120),
                    ResponsiveGrid(
                      minItemWidth: 300,
                      maxColumns: 3,
                      spacing: Insets.lg - 4,
                      children: [for (final post in rest.take(_visible)) PostCard(post: post)],
                    ),
                  ],
                  if (rest.length > _visible) ...[
                    const SizedBox(height: Insets.xl),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _visible += _pageSize),
                        child: const Text('Load more'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 40, color: p.textMuted),
          const SizedBox(height: Insets.md),
          Text('No posts with this tag yet.', style: text.titleMedium),
          const SizedBox(height: Insets.sm),
          TextButton(onPressed: onShowAll, child: const Text('Show all posts')),
        ],
      ),
    );
  }
}
