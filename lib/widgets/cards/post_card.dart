import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/site_config.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/app_image.dart';
import '../common/hover_card.dart';

/// A blog post preview in the style of the Unreal Engine feed: an inset cover
/// with badges, then the date, title and excerpt.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return HoverCard(
      semanticLabel: post.title,
      onTap: () => context.go(post.route),
      borderRadius: Radii.lgAll,
      padding: const EdgeInsets.all(18),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Radii.mdAll,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HoverZoom(hovered: hovered, child: PostCover(post: post)),
                  Positioned(left: 12, right: 12, bottom: 12, child: PostBadges(post: post)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Insets.md + 2),
          Text(formatDate(post.date), style: text.bodyMedium?.copyWith(color: p.textMuted)),
          const SizedBox(height: 6),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            post.excerpt,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

/// "★ Featured", the first tag and "Draft", shown over a post's cover.
class PostBadges extends StatelessWidget {
  const PostBadges({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (post.featured) const PostBadge(label: 'Featured', icon: Icons.star_border_rounded),
        if (post.tags.isNotEmpty) PostBadge(label: post.tags.first),
        if (post.draft) const PostBadge(label: 'Draft', icon: Icons.edit_outlined),
      ],
    );
  }
}

/// A dark pill that stays readable on any image, in every theme.
class PostBadge extends StatelessWidget {
  const PostBadge({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xD916161A),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

/// The post's cover image, or a branded gradient when it has none.
class PostCover extends StatelessWidget {
  const PostCover({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    if (post.image != null) return AppImage(post.image!);
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.8),
          radius: 1.4,
          colors: [p.heroGlow, const Color(0xFF0B0B0E)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Image.asset(
            SiteConfig.logoAsset,
            height: constraints.maxHeight * 0.36,
            opacity: const AlwaysStoppedAnimation(0.9),
          ),
        ),
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
