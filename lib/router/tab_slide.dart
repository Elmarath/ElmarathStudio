import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Lets the nav bar tabs (Home, Docs, Blog, About) slide pages sideways,
/// while every other navigation keeps the default fade-through.
///
/// The nav bar calls [prepare] right before navigating. The slide stays
/// active until the location changes to somewhere else (a link, search,
/// browser back), which resets it.
abstract final class TabSlide {
  static int _direction = 0;
  static String? _target;

  /// +1: the new page comes in from the right. -1: from the left. 0: no slide.
  static int get direction => _direction;

  static void prepare({required int direction, required String target}) {
    _direction = direction;
    _target = target;
  }

  /// Called by the router on every navigation.
  static void onLocationChanged(String path) {
    if (path != _target) {
      _direction = 0;
      _target = null;
    }
  }
}

/// Page transition for top-level pages: a horizontal slide after a tab press,
/// Material fade-through otherwise.
///
/// The widget tree is the same in both cases (only the animations change), so
/// switching between them never rebuilds the page and loses its state.
Widget tabSlideOrFadeThrough(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final direction = TabSlide.direction;
      final sliding = direction != 0;
      var offset = 0.0;
      if (sliding) {
        // The leaving page plays this route's animation in reverse; mirror the
        // curve so both pages move in step and stay edge to edge.
        final leaving =
            animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.dismissed;
        const curve = Curves.easeOutCubic;
        offset = leaving
            ? -direction * (1 - curve.flipped.transform(animation.value))
            : direction * (1 - curve.transform(animation.value));
      }
      return FadeThroughTransition(
        animation: sliding ? kAlwaysCompleteAnimation : animation,
        secondaryAnimation: sliding ? kAlwaysDismissedAnimation : secondaryAnimation,
        fillColor: Colors.transparent,
        child: FractionalTranslation(
          translation: Offset(offset, 0),
          // Opaque, so the page sliding out never shows through this one.
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: child),
        ),
      );
    },
  );
}
