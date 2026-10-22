import 'package:flutter/material.dart';

/// Holds every section of the site (Home, Docs, Blog, About, other pages),
/// each with its own pages. A section stays built once visited, so going back
/// to it is instant and finds it as you left it, scroll position included.
///
/// The section showing slides in from the side its tab sits on while the old
/// one slides out. It only moves the two pages, which is cheap; the others are
/// kept but hidden: not drawn, and their animations paused.
class SectionSlider extends StatefulWidget {
  const SectionSlider({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<SectionSlider> createState() => _SectionSliderState();
}

class _SectionSliderState extends State<SectionSlider> with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _leaving = null);
    });

  late int _current = widget.index;
  int? _leaving;

  @override
  void didUpdateWidget(SectionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == _current) return;
    _leaving = _current;
    _current = widget.index;
    _slide.value = 0;
    // Start once the new section has been built: building a page can take a
    // frame or two, which would otherwise make the slide skip its start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _leaving != null) _slide.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaving = _leaving;
    final direction = leaving == null ? 0.0 : (_current - leaving).sign.toDouble();
    return ClipRect(
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_slide.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              for (final (i, child) in widget.children.indexed)
                Offstage(
                  offstage: i != _current && i != leaving,
                  child: TickerMode(
                    enabled: i == _current,
                    child: FractionalTranslation(
                      translation: Offset(i == _current ? direction * (1 - t) : -direction * t, 0),
                      child: RepaintBoundary(child: child),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
