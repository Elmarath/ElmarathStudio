import 'package:flutter/material.dart';

/// Every color the site uses, in one place.
///
/// Widgets read it with `context.palette`. To make a new look, add an
/// [AppPalette] to `app_themes.dart`; nothing else needs to change.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.heroGlow,
    required this.codeBackground,
    required this.codeTheme,
    required this.note,
    required this.tip,
    required this.info,
    required this.warning,
    required this.danger,
  });

  final Brightness brightness;

  /// Page background.
  final Color background;

  /// Cards, nav bar, sidebars.
  final Color surface;

  /// Hovered or selected surfaces, inputs.
  final Color surfaceRaised;

  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Buttons, links, active states.
  final Color accent;
  final Color onAccent;

  /// Soft glow used behind the home hero.
  final Color heroGlow;

  final Color codeBackground;

  /// Syntax highlight theme (any theme from `package:flutter_highlight/themes`).
  final Map<String, TextStyle> codeTheme;

  // Admonition colors (:::note, :::tip, ...).
  final Color note;
  final Color tip;
  final Color info;
  final Color warning;
  final Color danger;

  bool get isDark => brightness == Brightness.dark;

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? heroGlow,
    Color? codeBackground,
    Map<String, TextStyle>? codeTheme,
    Color? note,
    Color? tip,
    Color? info,
    Color? warning,
    Color? danger,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      heroGlow: heroGlow ?? this.heroGlow,
      codeBackground: codeBackground ?? this.codeBackground,
      codeTheme: codeTheme ?? this.codeTheme,
      note: note ?? this.note,
      tip: tip ?? this.tip,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      border: l(border, other.border),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      heroGlow: l(heroGlow, other.heroGlow),
      codeBackground: l(codeBackground, other.codeBackground),
      codeTheme: t < 0.5 ? codeTheme : other.codeTheme,
      note: l(note, other.note),
      tip: l(tip, other.tip),
      info: l(info, other.info),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
