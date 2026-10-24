import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

import 'app_palette.dart';

/// A selectable theme: shows up in the theme menu in the nav bar.
class AppThemePreset {
  const AppThemePreset({
    required this.id,
    required this.name,
    required this.palette,
  });

  /// Stored in the browser to remember the visitor's choice. Keep it stable.
  final String id;
  final String name;
  final AppPalette palette;
}

/// All themes on the site: a dark one (the default, as the first) and a bright one.
///
/// To add a theme, copy one of the presets below, give it a new `id`, and
/// change the colors. It appears in the theme menu automatically.
const List<AppThemePreset> appThemes = [
  AppThemePreset(
    id: 'unreal-dark',
    name: 'Dark',
    palette: AppPalette(
      brightness: Brightness.dark,
      background: Color(0xFF0E0E11),
      surface: Color(0xFF18181C),
      surfaceRaised: Color(0xFF232328),
      border: Color(0x1FFFFFFF),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFFB4B4BC),
      textMuted: Color(0xFF7D7D86),
      accent: Color(0xFF26BBFF),
      onAccent: Color(0xFF041722),
      heroGlow: Color(0xFF0B4F7A),
      codeBackground: Color(0xFF121216),
      codeTheme: atomOneDarkTheme,
      note: Color(0xFF9CA3AF),
      tip: Color(0xFF34D399),
      info: Color(0xFF26BBFF),
      warning: Color(0xFFFBBF24),
      danger: Color(0xFFF87171),
    ),
  ),
  AppThemePreset(
    id: 'elmarath-gold',
    name: 'Elmarath Gold',
    palette: AppPalette(
      brightness: Brightness.light,
      background: Color(0xFFFAF7F2),
      surface: Color(0xFFFFFFFF),
      surfaceRaised: Color(0xFFF1EBE2),
      border: Color(0x1F3A2A10),
      textPrimary: Color(0xFF1C1712),
      textSecondary: Color(0xFF5A5046),
      textMuted: Color(0xFF736859),
      // A deeper gold than the logo's, so links and labels stay readable on white.
      accent: Color(0xFFA0650A),
      onAccent: Color(0xFFFFFFFF),
      heroGlow: Color(0xFFF5D7A1),
      codeBackground: Color(0xFFF7F2EA),
      codeTheme: githubTheme,
      note: Color(0xFF78716C),
      tip: Color(0xFF15803D),
      info: Color(0xFF2563EB),
      warning: Color(0xFFB45309),
      danger: Color(0xFFDC2626),
    ),
  ),
];
