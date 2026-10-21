import 'package:flutter/widgets.dart';

/// Spacing scale. Use these instead of raw numbers so the rhythm stays consistent.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Vertical space between home page sections.
  static const double section = 88;
}

abstract final class Radii {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
  static const Curve curve = Curves.easeOutCubic;
}

/// Max content widths.
abstract final class ContentWidths {
  /// Home, blog list, docs landing.
  static const double page = 1240;

  /// Blog posts and doc text: comfortable line length for reading.
  static const double reading = 780;
}

/// Width breakpoints.
enum ScreenSize {
  compact,
  medium,
  expanded;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 720) return ScreenSize.compact;
    if (width < 1100) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => this == ScreenSize.compact;
  bool get isExpanded => this == ScreenSize.expanded;

  /// Horizontal page padding.
  double get gutter => switch (this) {
        ScreenSize.compact => 16,
        ScreenSize.medium => 24,
        ScreenSize.expanded => 32,
      };
}
