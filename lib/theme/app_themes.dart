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

/// All themes on the site. The first one is the default.
///
/// To add a theme, copy one of the presets below, give it a new `id`, and
/// change the colors. It appears in the theme menu automatically.
const List<AppThemePreset> appThemes = [
  AppThemePreset(
    id: 'unreal-dark',
    name: 'Unreal Dark',
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
      brightness: Brightness.dark,
      background: Color(0xFF100E0B),
      surface: Color(0xFF1A1714),
      surfaceRaised: Color(0xFF26221D),
      border: Color(0x1FFFF4E0),
      textPrimary: Color(0xFFF7F3EE),
      textSecondary: Color(0xFFBDB4A8),
      textMuted: Color(0xFF857C70),
      accent: Color(0xFFF2A638),
      onAccent: Color(0xFF2A1A02),
      heroGlow: Color(0xFF6B3F07),
      codeBackground: Color(0xFF141210),
      codeTheme: atomOneDarkTheme,
      note: Color(0xFFA8A29E),
      tip: Color(0xFF4ADE80),
      info: Color(0xFF60A5FA),
      warning: Color(0xFFF2A638),
      danger: Color(0xFFF87171),
    ),
  ),
  AppThemePreset(
    id: 'daylight',
    name: 'Daylight',
    palette: AppPalette(
      brightness: Brightness.light,
      background: Color(0xFFF5F5F7),
      surface: Color(0xFFFFFFFF),
      surfaceRaised: Color(0xFFECECF0),
      border: Color(0x1A000000),
      textPrimary: Color(0xFF111114),
      textSecondary: Color(0xFF4B4B55),
      textMuted: Color(0xFF7A7A85),
      accent: Color(0xFF0074E4),
      onAccent: Color(0xFFFFFFFF),
      heroGlow: Color(0xFFBFDFFF),
      codeBackground: Color(0xFFF7F7F9),
      codeTheme: githubTheme,
      note: Color(0xFF6B7280),
      tip: Color(0xFF059669),
      info: Color(0xFF0074E4),
      warning: Color(0xFFD97706),
      danger: Color(0xFFDC2626),
    ),
  ),
];
