import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../app_scope.dart';
import '../../../config/site_config.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/app_image.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';

/// Full-width banner: who you are, what the site is, and where to go next.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final size = ScreenSize.of(context);
    final content = context.content;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.isCompact ? 560 : 640),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            child: Image.asset(SiteConfig.heroImage, fit: BoxFit.cover, alignment: const Alignment(0.6, -0.2)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [p.background, p.background.withValues(alpha: 0.88), p.background.withValues(alpha: 0.25)],
                  stops: size.isCompact ? const [0, 0.6, 1] : const [0, 0.42, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.background.withValues(alpha: 0), p.background],
                  stops: const [0.55, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, -0.8),
                  radius: 1.1,
                  colors: [p.heroGlow.withValues(alpha: 0.45), p.heroGlow.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          ContentWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size.isCompact ? Insets.xxl : 88),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      const _OwnerChip(),
                      const SizedBox(height: Insets.lg),
                      Eyebrow(SiteConfig.heroEyebrow),
                      const SizedBox(height: Insets.md),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Text(
                          SiteConfig.heroTitle,
                          style: size.isCompact ? text.displaySmall : text.displayLarge,
                        ),
                      ),
                      const SizedBox(height: Insets.lg),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(SiteConfig.heroSubtitle, style: text.bodyLarge?.copyWith(fontSize: 18)),
                      ),
                      const SizedBox(height: Insets.xl),
                      Wrap(
                        spacing: Insets.md,
                        runSpacing: Insets.md,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.go('/docs'),
                            icon: const Icon(Icons.menu_book_outlined, size: 18),
                            label: const Text('Explore the docs'),
                          ),
                          OutlinedButton(onPressed: () => context.go('/blog'), child: const Text('Read the blog')),
                        ],
                      ),
                      const SizedBox(height: Insets.xxl),
                      Wrap(
                        spacing: Insets.md,
                        runSpacing: Insets.sm,
                        children: [
                          _Stat(value: content.plugins.length, label: 'Plugins', route: '/docs'),
                          _Stat(
                            value: content.posts.length,
                            label: content.posts.length == 1 ? 'Blog post' : 'Blog posts',
                            route: '/blog',
                          ),
                        ],
                      ),
                    ]
                    .animate(interval: 70.ms)
                    .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.25, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar, name and role. Opens the About page.
class _OwnerChip extends StatefulWidget {
  const _OwnerChip();

  @override
  State<_OwnerChip> createState() => _OwnerChipState();
}

class _OwnerChipState extends State<_OwnerChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final shape = StadiumBorder(
      side: BorderSide(color: _hovered ? p.textPrimary.withValues(alpha: 0.4) : p.border),
    );
    return Material(
      color: (_hovered ? p.surfaceRaised : p.surface).withValues(alpha: 0.75),
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: () => context.go('/about'),
        onHover: (hovered) => setState(() => _hovered = hovered),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(child: AppImage(SiteConfig.avatarUrl, width: 30, height: 30)),
              const SizedBox(width: 10),
              Text(SiteConfig.ownerName, style: text.labelLarge),
              Flexible(
                child: Text(
                  '  ·  ${SiteConfig.role}',
                  style: text.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Insets.sm),
              AnimatedSlide(
                offset: Offset(_hovered ? 0.25 : 0, 0),
                duration: Motion.fast,
                child: Icon(Icons.arrow_forward, size: 16, color: p.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A count that opens its page: "8 Plugins →" goes to the docs.
class _Stat extends StatefulWidget {
  const _Stat({required this.value, required this.label, required this.route});

  final int value;
  final String label;
  final String route;

  @override
  State<_Stat> createState() => _StatState();
}

class _StatState extends State<_Stat> {
  bool _hovered = false;

  /// The button's inner padding; the row is shifted left by this much so the
  /// numbers still line up with the text above.
  static const _inset = 12.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final color = _hovered ? p.textPrimary : p.textMuted;
    return Transform.translate(
      offset: const Offset(-_inset, 0),
      child: Material(
        color: _hovered ? p.surface.withValues(alpha: 0.7) : Colors.transparent,
        borderRadius: Radii.mdAll,
        child: InkWell(
          borderRadius: Radii.mdAll,
          onTap: () => context.go(widget.route),
          onHover: (hovered) => setState(() => _hovered = hovered),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_inset, 8, _inset + 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.value}', style: text.headlineLarge),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.label.toUpperCase(), style: text.labelSmall?.copyWith(color: color)),
                    const SizedBox(width: 6),
                    AnimatedSlide(
                      offset: Offset(_hovered ? 0.3 : 0, 0),
                      duration: Motion.fast,
                      child: Icon(Icons.arrow_forward, size: 14, color: _hovered ? p.accent : color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
