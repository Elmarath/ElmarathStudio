import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_scope.dart';
import '../../../content/models.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/app_image.dart';
import '../../../widgets/common/links.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';

/// Epic Games Store–style featured carousel: a big banner plus a list on the
/// right that auto-advances. Shows docs folders with `featured: true`.
class SpotlightSection extends StatefulWidget {
  const SpotlightSection({super.key});

  @override
  State<SpotlightSection> createState() => _SpotlightSectionState();
}

class _SpotlightSectionState extends State<SpotlightSection> with SingleTickerProviderStateMixin {
  static const _interval = Duration(seconds: 7);

  late final AnimationController _progress = AnimationController(vsync: this, duration: _interval)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _select(_index + 1);
    })
    ..forward();

  int _index = 0;

  List<DocCategory> get _items => context.content.featuredPlugins;

  void _select(int index) {
    if (_items.isEmpty) return;
    setState(() => _index = index % _items.length);
    _progress.forward(from: 0);
  }

  void _pause(bool paused) => paused ? _progress.stop() : _progress.forward();

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();
    final size = ScreenSize.of(context);
    final current = items[_index.clamp(0, items.length - 1)];

    final banner = AnimatedSwitcher(
      duration: Motion.slow,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
      child: _Banner(key: ValueKey(current.id), plugin: current, compact: size.isCompact),
    );

    return Padding(
      padding: const EdgeInsets.only(top: Insets.section),
      child: ContentWidth(
        child: MouseRegion(
          onEnter: (_) => _pause(true),
          onExit: (_) => _pause(false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                eyebrow: 'Featured',
                title: 'Unreal Engine plugins',
                actionLabel: 'All plugins',
                actionHref: '/docs',
              ),
              if (size.isExpanded)
                SizedBox(
                  height: 440,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: banner),
                      const SizedBox(width: Insets.md),
                      SizedBox(
                        width: 290,
                        child: Column(
                          children: [
                            for (final (i, item) in items.indexed)
                              Expanded(
                                child: _Tab(
                                  plugin: item,
                                  active: i == _index,
                                  progress: _progress,
                                  onTap: () => _select(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                SizedBox(height: size.isCompact ? 580 : 420, child: banner),
                const SizedBox(height: Insets.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _Dot(active: i == _index, progress: _progress, onTap: () => _select(i)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.plugin, required this.compact});

  final DocCategory plugin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final thumbnail = plugin.thumbnail;
    final fab = plugin.links['fab'];

    final art = thumbnail == null
        ? const SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
              borderRadius: Radii.lgAll,
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 20))],
            ),
            child: ClipRRect(
              borderRadius: Radii.lgAll,
              child: AppImage(thumbnail, width: compact ? 120 : 280, height: compact ? 120 : 280),
            ),
          );

    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Unreal Engine plugin', color: Colors.white70),
        const SizedBox(height: Insets.sm),
        Text(
          plugin.label,
          style: (compact ? text.headlineLarge : text.displaySmall)?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: Insets.md),
        Text(
          plugin.pitch,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: text.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: Insets.lg),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            FilledButton(onPressed: () => context.go(plugin.route), child: const Text('Read the docs')),
            if (fab != null)
              OutlinedButton.icon(
                onPressed: () => openLink(context, fab),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text('View on Fab'),
              ),
          ],
        ),
      ],
    );

    return ClipRRect(
      borderRadius: Radii.lgAll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0B0B0E)),
          if (thumbnail != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.clamp),
              child: Transform.scale(scale: 1.3, child: AppImage(thumbnail)),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: compact ? Alignment.bottomCenter : Alignment.centerLeft,
                end: compact ? Alignment.topCenter : Alignment.centerRight,
                colors: [Colors.black.withValues(alpha: 0.82), Colors.black.withValues(alpha: 0.35)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? Insets.lg : Insets.xxl),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [art, const SizedBox(height: Insets.lg), details],
                  )
                : Row(
                    children: [
                      Expanded(child: details),
                      const SizedBox(width: Insets.xl),
                      art,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// One entry in the list next to the banner. The active one fills up as the timer runs.
class _Tab extends StatelessWidget {
  const _Tab({required this.plugin, required this.active, required this.progress, required this.onTap});

  final DocCategory plugin;
  final bool active;
  final Animation<double> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? p.surface : Colors.transparent,
        borderRadius: Radii.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (active)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.value,
                      child: ColoredBox(color: p.surfaceRaised),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (plugin.thumbnail != null)
                      ClipRRect(
                        borderRadius: Radii.smAll,
                        child: AppImage(plugin.thumbnail!, width: 48, height: 48),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        plugin.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(color: active ? p.textPrimary : p.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.progress, required this.onTap});

  final bool active;
  final Animation<double> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: Motion.normal,
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? p.surfaceRaised : p.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: active
              ? AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
