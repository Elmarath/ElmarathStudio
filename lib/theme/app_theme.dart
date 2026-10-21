import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';
import 'tokens.dart';

/// Builds a Material [ThemeData] from an [AppPalette].
///
/// Component styling (buttons, cards, chips, ...) lives here, so every
/// standard Flutter widget picks up the site's look automatically.
abstract final class AppTheme {
  /// Monospace style for code. Change the font here to change it everywhere.
  static TextStyle code({double fontSize = 13.5, Color? color}) =>
      GoogleFonts.jetBrainsMono(fontSize: fontSize, height: 1.6, color: color);

  /// Fetches the fonts before the first frame, so text never renders (and gets
  /// measured) with a fallback font first. Gives up after a few seconds offline.
  static Future<void> preloadFonts() async {
    for (final weight in [FontWeight.w400, FontWeight.w600, FontWeight.w700, FontWeight.w800, FontWeight.w900]) {
      GoogleFonts.inter(fontWeight: weight);
    }
    GoogleFonts.inter(fontStyle: FontStyle.italic);
    GoogleFonts.jetBrainsMono();
    try {
      await GoogleFonts.pendingFonts().timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  static ThemeData build(AppPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surfaceRaised,
      outline: p.border,
      outlineVariant: p.border,
    );

    final base = ThemeData(brightness: p.brightness, useMaterial3: true);
    final text = _textTheme(base.textTheme, p);

    final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: Radii.smAll),
    );
    const buttonPadding = WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    );
    final buttonText = WidgetStatePropertyAll<TextStyle?>(
      text.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: text,
      dividerColor: p.border,
      hoverColor: p.textPrimary.withValues(alpha: 0.04),
      focusColor: p.accent.withValues(alpha: 0.16),
      splashFactory: InkSparkle.splashFactory,
      extensions: [p],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.3),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: p.textSecondary, size: 20),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: buttonText,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Color.lerp(p.accent, Colors.white, 0.12);
            }
            return p.accent;
          }),
          foregroundColor: WidgetStatePropertyAll(p.onAccent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: buttonText,
          foregroundColor: WidgetStatePropertyAll(p.textPrimary),
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
                color: states.contains(WidgetState.hovered)
                    ? p.textPrimary.withValues(alpha: 0.6)
                    : p.textPrimary.withValues(alpha: 0.25),
              )),
          overlayColor: WidgetStatePropertyAll(p.textPrimary.withValues(alpha: 0.06)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          textStyle: buttonText,
          foregroundColor: WidgetStatePropertyAll(p.textPrimary),
          overlayColor: WidgetStatePropertyAll(p.textPrimary.withValues(alpha: 0.06)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered) ? p.textPrimary : p.textSecondary),
          shape: buttonShape,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll,
          side: BorderSide(color: p.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.accent.withValues(alpha: 0.18),
        side: BorderSide(color: p.border),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium?.copyWith(color: p.textSecondary),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: p.accent),
        checkmarkColor: p.accent,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
        selectedColor: p.accent,
        selectedTileColor: p.accent.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: p.textSecondary,
        collapsedIconColor: p.textMuted,
        textColor: p.textPrimary,
        collapsedTextColor: p.textSecondary,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll,
          side: BorderSide(color: p.border),
        ),
        textStyle: text.bodyMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: Radii.lgAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.surfaceRaised,
          borderRadius: Radii.smAll,
          border: Border.all(color: p.border),
        ),
        textStyle: text.labelMedium?.copyWith(color: p.textPrimary),
        waitDuration: const Duration(milliseconds: 400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surfaceRaised,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
        width: 360,
      ),
      searchViewTheme: SearchViewThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        dividerColor: p.border,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: p.border),
        ),
        headerTextStyle: text.titleMedium,
        headerHintStyle: text.titleMedium?.copyWith(color: p.textMuted),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(6),
        thumbColor: WidgetStatePropertyAll(p.textPrimary.withValues(alpha: 0.18)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppPalette p) {
    final inter = GoogleFonts.interTextTheme(base);
    TextStyle? heading(TextStyle? s, double size, {double spacing = -0.5}) => s?.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: spacing,
          height: 1.12,
          color: p.textPrimary,
        );

    return inter.copyWith(
      displayLarge: heading(inter.displayLarge, 64, spacing: -2),
      displayMedium: heading(inter.displayMedium, 48, spacing: -1.5),
      displaySmall: heading(inter.displaySmall, 38, spacing: -1),
      headlineLarge: heading(inter.headlineLarge, 32),
      headlineMedium: heading(inter.headlineMedium, 26),
      headlineSmall: heading(inter.headlineSmall, 21, spacing: -0.2),
      titleLarge: inter.titleLarge?.copyWith(
          fontSize: 19, fontWeight: FontWeight.w700, color: p.textPrimary, height: 1.3),
      titleMedium: inter.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: p.textPrimary, height: 1.35),
      titleSmall: inter.titleSmall?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: p.textPrimary),
      bodyLarge: inter.bodyLarge?.copyWith(fontSize: 16.5, height: 1.7, color: p.textSecondary),
      bodyMedium: inter.bodyMedium?.copyWith(fontSize: 14.5, height: 1.6, color: p.textSecondary),
      bodySmall: inter.bodySmall?.copyWith(fontSize: 13, height: 1.5, color: p.textMuted),
      labelLarge: inter.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: p.textPrimary),
      labelMedium: inter.labelMedium?.copyWith(
          fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: p.textSecondary),
      labelSmall: inter.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: p.textMuted),
    );
  }
}
