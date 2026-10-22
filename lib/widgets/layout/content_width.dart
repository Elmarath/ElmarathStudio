import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/site_config.dart';
import '../../theme/tokens.dart';
import 'site_footer.dart';

/// Centers its child and limits its width, with responsive side padding.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = ContentWidths.page});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = ScreenSize.of(context).gutter;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// A vertical scroll view whose content is drawn once and then only moved while
/// scrolling. A plain [SingleChildScrollView] redraws all of its content on
/// every scroll frame, which makes long pages stutter on the web.
///
/// A mouse wheel glides each notch over a moment, the way browsers scroll
/// ordinary web pages; Flutter would otherwise jump a notch at a time.
/// Trackpads scroll as they are: they already send small, smooth steps.
class ContentScrollView extends StatefulWidget {
  const ContentScrollView({super.key, required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  State<ContentScrollView> createState() => _ContentScrollViewState();
}

class _ContentScrollViewState extends State<ContentScrollView> with SingleTickerProviderStateMixin {
  ScrollController? _ownController;
  ScrollController get _controller => widget.controller ?? (_ownController ??= ScrollController());

  // A glide sets the scroll position on each frame itself. An animated scroll
  // (animateTo) would stop the page from hearing the next notch while it runs.
  // Made on the first notch: most visits never use a mouse wheel.
  AnimationController? _glide;
  double _glideFrom = 0;
  double _glideTo = 0;
  double _glidePixels = 0; // where the glide last put the page

  void _onPointerSignal(PointerSignalEvent event) {
    // Trackpads, and Shift + wheel (which scrolls sideways), keep the usual handling.
    if (event is! PointerScrollEvent || event.kind != PointerDeviceKind.mouse) return;
    if (event.scrollDelta.dy == 0 || HardwareKeyboard.instance.isShiftPressed) return;
    // Registering first (this sits below the scroll view) keeps the scroll view from jumping too.
    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (event) => _glideBy((event as PointerScrollEvent).scrollDelta.dy),
    );
  }

  void _glideBy(double delta) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final glide =
        _glide ??= AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
          ..addListener(_glideStep);
    // Quick notches add up: the next one starts from where the last was heading.
    final target = ((glide.isAnimating ? _glideTo : position.pixels) + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return;
    _glideFrom = _glidePixels = position.pixels;
    _glideTo = target;
    glide.forward(from: 0);
  }

  void _glideStep() {
    final glide = _glide!;
    if (!_controller.hasClients) return glide.stop();
    final position = _controller.position;
    // Anything else that moves the page (a drag, the trackpad, a link to a heading) wins.
    if ((position.pixels - _glidePixels).abs() > 1) return glide.stop();
    _glidePixels = _glideFrom + (_glideTo - _glideFrom) * Curves.easeOutCubic.transform(glide.value);
    position.jumpTo(_glidePixels);
  }

  @override
  void dispose() {
    _glide?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      child: Listener(onPointerSignal: _onPointerSignal, child: RepaintBoundary(child: widget.child)),
    );
  }
}

/// A scrolling page: [children] stacked vertically with the footer at the end.
class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.controller, this.showFooter = true});

  final List<Widget> children;
  final ScrollController? controller;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return ContentScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (showFooter) const SiteFooter(),
        ],
      ),
    );
  }
}

/// Sets the browser tab title for a page.
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Only the page showing sets the title: not one on its way out, nor one in
    // a section that's hidden. A section coming back into view rebuilds this
    // (TickerMode turns on), which puts its title back. The page itself always
    // stays in the same place in the tree, so it's never rebuilt for this.
    if ((ModalRoute.of(context)?.isCurrent ?? true) && TickerMode.of(context)) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: title == null ? '${SiteConfig.siteName} · Unreal Engine tools & devlog' : '$title · ${SiteConfig.siteName}',
          primaryColor: Theme.of(context).colorScheme.primary.toARGB32(),
        ),
      );
    }
    return child;
  }
}
