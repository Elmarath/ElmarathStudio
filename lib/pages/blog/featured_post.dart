import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/post_card.dart';
import '../../widgets/common/hover_card.dart';

/// The big post at the top of the blog: a glowing cover on the left, the
/// date, title, excerpt and "Read more" on the right.
class FeaturedPost extends StatefulWidget {
  const FeaturedPost({super.key, required this.post});

  final BlogPost post;

  @override
  State<FeaturedPost> createState() => _FeaturedPostState();
}

class _FeaturedPostState extends State<FeaturedPost> {
  bool _hovered = false;

  void _open() => context.go(widget.post.route);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;
    final post = widget.post;
    const radius = BorderRadius.all(Radius.circular(24));

    final cover = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _open,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: p.accent.withValues(alpha: p.isDark ? 0.28 : 0.2),
                blurRadius: 140,
                spreadRadius: 6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HoverZoom(hovered: _hovered, child: PostCover(post: post)),
                  Positioned(left: 20, right: 20, bottom: 20, child: PostBadges(post: post)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatDate(post.date), style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: Insets.sm + 4),
        Text(
          post.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: (compact ? text.headlineLarge : text.displaySmall)?.copyWith(height: 1.15),
        ),
        const SizedBox(height: Insets.lg - 4),
        Text(post.excerpt, maxLines: 4, overflow: TextOverflow.ellipsis, style: text.bodyLarge),
        const SizedBox(height: Insets.xl - 4),
        FilledButton(onPressed: _open, child: const Text('Read more')),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [cover, const SizedBox(height: Insets.xl), details],
      );
    }
    return Row(
      children: [
        Expanded(flex: 11, child: cover),
        const SizedBox(width: 64),
        Expanded(flex: 10, child: details),
      ],
    );
  }
}
