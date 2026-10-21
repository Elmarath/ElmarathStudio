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
    });

  int _index = 0;
  bool _hovered = false;
  bool _onScreen = false;
  ScrollPosition? _scrollPosition;

  List<DocCategory> get _items => context.content.featuredPlugins;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnScreen());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.removeListener(_checkOnScreen);
      _scrollPosition = position?..addListener(_checkOnScreen);
    }
  }

  /// The timer only runs while the carousel is visible: an animation that
  /// never stops keeps the browser drawing frames even when nothing changes.
  void _checkOnScreen() {
    final box = context.findRenderObject() as RenderBox?;
    if (!mounted || box == null || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final onScreen = top < MediaQuery.sizeOf(context).height && top + box.size.height > 0;
    if (onScreen != _onScreen) {
      _onScreen = onScreen;
      _updatePlayback();
    }
  }

  void _updatePlayback() => _onScreen && !_hovered ? _progress.forward() : _progress.stop();

  void _select(int index) {
    if (_items.isEmpty) return;
    setState(() => _index = index % _items.length);
    _progress.value = 0;
    _updatePlayback();
  }

  void _pause(bool paused) {
    _hovered = paused;
    _updatePlayback();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkOnScreen);
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();
    final size = ScreenSize.of(context);
    final current = items[_index.clamp(0, items.length - 1)];

    final banner = RepaintBoundary(
      child: AnimatedSwitcher(
        duration: Motion.slow,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        // Next to the tab list the banner has a fixed height; on its own it grows with its text.
        layoutBuilder:
            (current, previous) => Stack(
              fit: size.isExpanded ? StackFit.expand : StackFit.loose,
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
        child: _Banner(
          key: ValueKey(current.id),
          plugin: current,
          compact: size.isCompact,
          minHeight: switch (size) {
            ScreenSize.compact => 560,
            ScreenSize.medium => 420,
            ScreenSize.expanded => 0,
          },
        ),
      ),
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
                banner,
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
  const _Banner({super.key, required this.plugin, required this.compact, required this.minHeight});

  final DocCategory plugin;
  final bool compact;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final thumbnail = plugin.thumbnail;
    final fab = plugin.links['fab'];

    final art =
        thumbnail == null
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Stack(
          alignment: compact ? Alignment.bottomLeft : Alignment.centerLeft,
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFF0B0B0E))),
            if (thumbnail != null)
              // A tiny copy of the thumbnail stretched over the banner reads as a soft
              // blur, without a live blur filter that costs every frame on the web.
              Positioned.fill(child: AppImage(thumbnail, cacheWidth: 24, filterQuality: FilterQuality.high)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: compact ? Alignment.bottomCenter : Alignment.centerLeft,
                    end: compact ? Alignment.topCenter : Alignment.centerRight,
                    colors: [Colors.black.withValues(alpha: 0.82), Colors.black.withValues(alpha: 0.35)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? Insets.lg : Insets.xxl),
              child:
                  compact
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [art, const SizedBox(height: Insets.lg), details],
                      )
                      : Row(children: [Expanded(child: details), const SizedBox(width: Insets.xl), art]),
            ),
          ],
        ),
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
            alignment: AlignmentDirectional.centerStart,
            children: [
              if (active)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: progress,
                      builder:
                          (context, _) => FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.value,
                            child: ColoredBox(color: p.surfaceRaised),
                          ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (plugin.thumbnail != null)
                      ClipRRect(borderRadius: Radii.smAll, child: AppImage(plugin.thumbnail!, width: 48, height: 48)),
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
    return RepaintBoundary(
      child: GestureDetector(
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
            child:
                active
                    ? AnimatedBuilder(
                      animation: progress,
                      builder:
                          (context, _) => FractionallySizedBox(
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
      ),
    );
  }
}
