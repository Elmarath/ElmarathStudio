import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/text_utils.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/post_card.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/hover_card.dart';
import '../../widgets/common/links.dart';
import '../../widgets/layout/content_width.dart';
import '../../widgets/markdown/markdown_view.dart';
import '../not_found_page.dart';

/// `/blog/<slug>`.
class BlogPostPage extends StatelessWidget {
  const BlogPostPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final content = context.content;
    final post = content.post(slug);
    if (post == null) return const NotFoundPage();

    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final compact = ScreenSize.of(context).isCompact;
    final index = content.posts.indexOf(post);
    final newer = index > 0 ? content.posts[index - 1] : null;
    final older = index < content.posts.length - 1 ? content.posts[index + 1] : null;
    final image = post.image;
    // Skip the cover if the post already shows the same image in its body.
    final showCover = image != null && !post.body.contains(image.split('/').last);

    return PageTitle(
      title: post.title,
      child: PageScroll(
        children: [
          ContentWidth(
            maxWidth: ContentWidths.reading,
            child: Padding(
              padding: const EdgeInsets.only(top: Insets.xl, bottom: Insets.section),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go('/blog'),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('All posts'),
                    ),
                  ),
                  const SizedBox(height: Insets.lg),
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: Insets.sm,
                      runSpacing: Insets.sm,
                      children: [
                        for (final t in post.tags)
                          ActionChip(
                            label: Text(t),
                            onPressed: () => context.go('/blog?tag=${Uri.encodeQueryComponent(slugify(t))}'),
                          ),
                      ],
                    ),
                  const SizedBox(height: Insets.md),
                  Text(post.title, style: compact ? text.headlineLarge : text.displaySmall),
                  const SizedBox(height: Insets.md),
                  _Meta(post: post),
                  const SizedBox(height: Insets.xl),
                  if (showCover) ...[
                    ClipRRect(
                      borderRadius: Radii.lgAll,
                      child: AspectRatio(aspectRatio: 16 / 9, child: AppImage(image)),
                    ),
                    const SizedBox(height: Insets.xl),
                  ],
                  SelectionArea(
                    child: MarkdownView(blocks: post.parsed.blocks, sourcePath: post.assetPath),
                  ),
                  const SizedBox(height: Insets.xxl),
                  Divider(color: p.border),
                  const SizedBox(height: Insets.lg),
                  for (final author in post.authors) ...[
                    _AuthorCard(author: author),
                    const SizedBox(height: Insets.lg),
                  ],
                  _PostPager(newer: newer, older: older),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final author = post.authors.firstOrNull;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        if (author?.imageUrl != null)
          ClipOval(child: AppImage(author!.imageUrl!, width: 28, height: 28)),
        if (author != null) Text(author.name, style: text.labelLarge),
        if (author != null) Text('·', style: text.bodySmall),
        Text(formatDate(post.date), style: text.bodyMedium),
        Text('·', style: text.bodySmall),
        Text('${post.readingMinutes} min read', style: text.bodyMedium),
        if (post.draft) const DraftBadge(),
      ],
    );
  }
}

class _AuthorCard extends StatelessWidget {
  const _AuthorCard({required this.author});

  final Author author;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Row(
      children: [
        if (author.imageUrl != null) ...[
          ClipOval(child: AppImage(author.imageUrl!, width: 52, height: 52)),
          const SizedBox(width: Insets.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WRITTEN BY', style: text.labelSmall),
              const SizedBox(height: 2),
              Text(author.name, style: text.titleMedium),
              if (author.title != null) Text(author.title!, style: text.bodySmall),
            ],
          ),
        ),
        if (author.url != null)
          IconButton(
            tooltip: 'Profile',
            onPressed: () => openLink(context, author.url!),
            icon: Icon(Icons.open_in_new, color: p.textSecondary),
          ),
      ],
    );
  }
}

class _PostPager extends StatelessWidget {
  const _PostPager({this.newer, this.older});

  final BlogPost? newer;
  final BlogPost? older;

  @override
  Widget build(BuildContext context) {
    Widget card(BlogPost post, String label, bool alignEnd) {
      final text = Theme.of(context).textTheme;
      return HoverCard(
        onTap: () => context.go(post.route),
        padding: const EdgeInsets.all(Insets.md + 2),
        builder: (context, hovered) => SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(label, style: text.labelSmall),
              const SizedBox(height: 4),
              Text(
                post.title,
                textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                style: text.titleMedium?.copyWith(color: context.palette.accent),
              ),
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: newer == null ? const SizedBox() : card(newer!, 'Newer post', false)),
          const SizedBox(width: Insets.md),
          Expanded(child: older == null ? const SizedBox() : card(older!, 'Older post', true)),
        ],
      ),
    );
  }
}
