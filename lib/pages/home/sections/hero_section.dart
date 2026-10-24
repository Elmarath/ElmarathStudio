import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../app_scope.dart';
import '../../../config/site_config.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/app_image.dart';
import '../../../widgets/layout/content_width.dart';
import 'hero_video_stub.dart' if (dart.library.js_interop) 'hero_video_web.dart';

/// The top of the home page, after unrealengine.com: who you are and what you
/// make on one side, a looping showreel with a soft glow of it behind it on the
/// other (below, on smaller screens).
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  /// On wide screens, as on unrealengine.com: a narrow column of text, and the
  /// video filling the rest of the row. Unreal slides its video a little under
  /// the text; here they stay apart, as dark text over the video can't be read.
  static const _textWidth = 400.0;
  static const _videoLeft = _textWidth + 40;

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    // The showreel comes first in each layout: drawn under the text, its glow
    // can spread out behind it, as on unrealengine.com.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.isCompact ? Insets.xxl : 96),
      child: ContentWidth(
        child:
            size.isExpanded
                ? const Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // Its glow is centred on the whole row, so it reaches in behind the text.
                    Padding(
                      padding: EdgeInsets.only(left: _videoLeft),
                      child: _Showreel(blur: 80, shift: _videoLeft / 2),
                    ),
                    SizedBox(width: _textWidth, child: _Intro()),
                  ],
                )
                // Laid out bottom to top, so the text above is drawn after the showreel below.
                : const Column(
                  verticalDirection: VerticalDirection.up,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_Showreel(blur: 48), SizedBox(height: 64), _Intro()],
                ),
      ),
    );
  }
}

/// Name, the big statement, what you do, and where to go next.
class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final size = ScreenSize.of(context);
    final content = context.content;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            const _OwnerChip(),
            const SizedBox(height: Insets.xl),
            Text(
              SiteConfig.heroTitle,
              // Beside the video there's room for two lines only at a smaller size
              // (about Unreal's 40px).
              style: size == ScreenSize.medium ? text.displayLarge : text.displaySmall,
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
            const SizedBox(height: Insets.xl),
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
    );
  }
}

/// The video in a rounded 16:9 frame, with its glow spilling out around it.
class _Showreel extends StatelessWidget {
  const _Showreel({required this.blur, this.shift = 0});

  /// How much the glow is blurred; it fades out within twice that.
  final double blur;

  /// How far left of the video the glow is centred.
  final double shift;

  @override
  Widget build(BuildContext context) {
    final margin = 2 * blur;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -(shift + margin),
            top: -margin,
            right: -margin,
            bottom: -margin,
            child: HeroVideo(blur: blur, shift: shift, radius: 32),
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
    final shape = StadiumBorder(side: BorderSide(color: _hovered ? p.textPrimary.withValues(alpha: 0.4) : p.border));
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
