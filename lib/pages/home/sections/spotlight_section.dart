import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_scope.dart';
import '../../../content/models.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/app_image.dart';
import '../../../widgets/common/blurred_image.dart';
import '../../../widgets/common/links.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';

/// Epic Games Store–style featured carousel: a big banner that auto-advances,
/// with every plugin listed beside it, or in a row below it on smaller
/// screens. Shows docs folders with `featured: true`.
///
/// Like Fab's, it plays until the pause button in the banner's corner is
/// pressed. On smaller screens (phones, tablets, narrow windows) the banner can
/// also be dragged or swiped to the next or previous plugin, round and round.
class SpotlightSection extends StatefulWidget {
  const SpotlightSection({super.key});

  @override
  State<SpotlightSection> createState() => _SpotlightSectionState();
}

class _SpotlightSectionState extends State<SpotlightSection> {
  /// How long each plugin stays up.
  static const _interval = Duration(seconds: 7);

  /// Moves on to the next plugin. A plain timer rather than an animated
  /// progress bar: any animation makes the browser redraw the whole page on
  /// every frame for as long as the carousel is on screen.
  Timer? _timer;

  /// Page p shows plugin p % n, with no first or last page, so swiping goes
  /// round and round. Made once the plugins can be read from [context].
  PageController? _pages;

  /// Keeps the same slides, and the plugin they're on, when the window is
  /// resized into another layout.
  final _slidesKey = GlobalKey();

  /// The page picked from the list, while the banner slides there.
  int? _target;
  Drag? _drag;

  int _index = 0;
  bool _paused = false;
  bool _onScreen = false;

  /// False while the home page is hidden behind another section.
  bool _active = true;
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
    _pages ??= PageController(initialPage: _items.length * 1000);
    final active = TickerMode.of(context);
    if (active != _active) {
      _active = active;
      _updatePlayback();
    }
    for (final item in _items) {
      if (item.thumbnail != null) BlurredImage.precache(item.thumbnail!);
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

  /// Gives the current plugin a fresh [_interval], unless it shouldn't move:
  /// paused, scrolled away, hidden, or being dragged.
  void _updatePlayback() {
    _timer?.cancel();
    _timer = !_paused && _onScreen && _active && _drag == null ? Timer(_interval, _next) : null;
  }

  void _togglePaused() {
    setState(() => _paused = !_paused);
    _updatePlayback();
  }

  void _next() {
    final pages = _pages;
    if (pages != null && pages.hasClients) pages.nextPage(duration: Motion.slow, curve: Motion.curve);
  }

  /// Slides to plugin [index] picked from the list, staying in the same round
  /// so the banner moves the way the list is laid out.
  void _select(int index) {
    final pages = _pages;
    if (pages == null || !pages.hasClients) return;
    final page = pages.page?.round() ?? pages.initialPage;
    final target = page - page % _items.length + index;
    _updatePlayback();
    if (target == page) return;
    setState(() {
      _index = index;
      _target = target;
    });
    pages.animateToPage(target, duration: Motion.slow, curve: Motion.curve).whenComplete(() {
      _target = null;
      // A drag can cut the slide short; catch up with wherever it stopped.
      final stopped = pages.hasClients ? pages.page!.round() : target;
      if (mounted && stopped != target) _pageChanged(stopped);
    });
  }

  void _pageChanged(int page) {
    if (_target != null) return; // sliding past other plugins on the way to the one picked
    setState(() => _index = page % _items.length);
    _updatePlayback();
  }

  // Drags are handled here rather than by the PageView itself, which would
  // also take sideways wheel and trackpad scrolling and catch the page's own
  // scrolling on its way past.
  void _dragStart(DragStartDetails details) {
    _drag = _pages?.position.drag(details, () => _drag = null);
    _updatePlayback();
  }

  void _dragEnd(DragEndDetails details) {
    _drag?.end(details);
    _updatePlayback();
  }

  void _dragCancel() {
    _drag?.cancel();
    _updatePlayback();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkOnScreen);
    _pages?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();
    final size = ScreenSize.of(context);

    Widget slides = PageView.builder(
      key: _slidesKey,
      controller: _pages,
      physics: const NeverScrollableScrollPhysics(),
      scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      onPageChanged: _pageChanged,
      itemBuilder: (context, page) => _Banner(plugin: items[page % items.length], compact: size.isCompact),
    );
    // On smaller screens the banner also follows a finger or the mouse.
    if (!size.isExpanded) {
      slides = GestureDetector(
        onHorizontalDragStart: _dragStart,
        onHorizontalDragUpdate: (details) => _drag?.update(details),
        onHorizontalDragEnd: _dragEnd,
        onHorizontalDragCancel: _dragCancel,
        child: slides,
      );
    }

    final banner = Stack(
      children: [
        // One rounded frame around all the slides, so they meet edge to edge while moving.
        Positioned.fill(child: RepaintBoundary(child: ClipRRect(borderRadius: Radii.lgAll, child: slides))),
        Positioned(right: Insets.md, bottom: Insets.md, child: _PauseButton(paused: _paused, onPressed: _togglePaused)),
      ],
    );

    final carousel =
        size.isExpanded
            ? SizedBox(
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
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: _Tab(plugin: item, active: i == _index, onTap: () => _select(i)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A fixed height for swiping, with room for the longest title and pitch.
                SizedBox(height: size.isCompact ? 560 : 480, child: banner),
                const SizedBox(height: Insets.sm),
                // The same list, as a row that always shares out the full width.
                SizedBox(
                  height: 72,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, item) in items.indexed) ...[
                        if (i > 0) const SizedBox(width: Insets.sm),
                        Expanded(child: _Tab(plugin: item, active: i == _index, onTap: () => _select(i))),
                      ],
                    ],
                  ),
                ),
              ],
            );

    return Padding(
      padding: const EdgeInsets.only(top: Insets.section),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              eyebrow: 'Featured',
              title: 'Unreal Engine plugins',
              actionLabel: 'All plugins',
              actionHref: '/docs',
            ),
            carousel,
          ],
        ),
      ),
    );
  }
}

/// The small round button that stops and restarts the carousel.
class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.paused, required this.onPressed});

  final bool paused;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: paused ? 'Play' : 'Pause',
      iconSize: 18,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        hoverColor: Colors.white.withValues(alpha: 0.12),
      ),
      icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.plugin, required this.compact});

  /// Both buttons are this wide (wider than either label needs), so they match.
  static const _buttonSize = Size(168, 40);

  final DocCategory plugin;
  final bool compact;

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
            FilledButton(
              onPressed: () => context.go(plugin.route),
              style: FilledButton.styleFrom(minimumSize: _buttonSize),
              child: const Text('Read the docs'),
            ),
            if (fab != null)
              OutlinedButton.icon(
                onPressed: () => openLink(context, fab),
                style: OutlinedButton.styleFrom(
                  minimumSize: _buttonSize,
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

    return Stack(
      alignment: compact ? Alignment.bottomLeft : Alignment.centerLeft,
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFF0B0B0E))),
        if (thumbnail != null) Positioned.fill(child: BlurredImage(thumbnail)),
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
    );
  }
}

/// One plugin in the list beside or below the banner; the active one is
/// highlighted. When it's too narrow for the name, it shows just the
/// thumbnail, with the name as a tooltip.
class _Tab extends StatelessWidget {
  const _Tab({required this.plugin, required this.active, required this.onTap});

  static const _minWidthForName = 180.0;

  final DocCategory plugin;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    Widget thumbnail(double side) =>
        plugin.thumbnail == null
            ? SizedBox.square(dimension: side)
            : ClipRRect(borderRadius: Radii.smAll, child: AppImage(plugin.thumbnail!, width: side, height: side));

    return Material(
      color: active ? p.surface : Colors.transparent,
      borderRadius: Radii.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _minWidthForName) {
              return Tooltip(
                message: plugin.label,
                child: Center(
                  child: Opacity(opacity: active ? 1 : 0.6, child: thumbnail(math.min(48, constraints.maxWidth - 12))),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  thumbnail(48),
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
            );
          },
        ),
      ),
    );
  }
}
