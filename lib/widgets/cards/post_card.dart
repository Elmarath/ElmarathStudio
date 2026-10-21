import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/app_image.dart';
import '../common/hover_card.dart';

/// A blog post preview. [featured] makes it a wide, side-by-side card.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.featured = false});

  final BlogPost post;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      semanticLabel: post.title,
      onTap: () => context.go(post.route),
      builder: (context, hovered) {
        final cover = HoverZoom(hovered: hovered, child: PostCover(post: post));
        final details = _Details(post: post, featured: featured);
        if (featured) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 6, child: AspectRatio(aspectRatio: 16 / 9, child: cover)),
                Expanded(flex: 5, child: details),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: cover),
            Expanded(child: details),
          ],
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.post, required this.featured});

  final BlogPost post;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.all(featured ? Insets.xl : Insets.lg - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: featured ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (post.tags.isNotEmpty)
            Text(
              post.tags.take(2).join(' · ').toUpperCase(),
              style: text.labelSmall?.copyWith(color: p.accent),
            ),
          const SizedBox(height: Insets.sm),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: featured ? text.headlineMedium : text.titleLarge,
          ),
          const SizedBox(height: Insets.sm),
          Text(post.excerpt, maxLines: featured ? 4 : 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
          if (featured) const SizedBox(height: Insets.lg) else const Spacer(),
          if (!featured) const SizedBox(height: Insets.md),
          Row(
            children: [
              Text('${formatDate(post.date)}  ·  ${post.readingMinutes} min read', style: text.bodySmall),
              if (post.draft) ...[
                const SizedBox(width: Insets.sm),
                const DraftBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The post's cover image, or a generated gradient when it has none.
class PostCover extends StatelessWidget {
  const PostCover({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    if (post.image != null) return AppImage(post.image!);
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroGlow, p.accent.withValues(alpha: 0.55), p.surface],
          stops: const [0, 0.55, 1],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        post.title.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}

class DraftBadge extends StatelessWidget {
  const DraftBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: p.warning.withValues(alpha: 0.15),
        borderRadius: Radii.smAll,
      ),
      child: Text('DRAFT', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: p.warning)),
    );
  }
}
