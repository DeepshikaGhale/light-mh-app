import 'package:flutter/material.dart';

/// Observability theme — supports both dark and light modes.
class ObsTheme {
  // ──── DARK MODE PALETTE ────
  static const Color bg = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF252525);
  static const Color border = Color(0xFF333333);

  // ──── LIGHT MODE PALETTE ────
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color surfaceLt = Colors.white;
  static const Color surfaceLightLt = Color(0xFFF0F2F5);
  static const Color borderLt = Color(0xFFE0E0E0);

  // ──── SHARED ACCENT COLORS ────
  static const Color safe = Color(0xFF00C853);        // Green (works on both)
  static const Color safeDark = Color(0xFF00FF41);     // Matrix green (dark only)
  static const Color warning = Color(0xFFFFAB00);      // Amber
  static const Color critical = Color(0xFFFF3E3E);     // Red
  static const Color info = Color(0xFF2196F3);         // Blue
  static const Color muted = Color(0xFF666666);

  // ──── TEXT (dark) ────
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF555555);

  // ──── TEXT (light) ────
  static const Color textPrimaryLt = Color(0xFF1A1A2E);
  static const Color textSecondaryLt = Color(0xFF636E72);
  static const Color textMutedLt = Color(0xFFAAAAAA);

  // ──── THEME-AWARE HELPERS ────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) => isDark(context) ? bg : bgLight;
  static Color surfaceOf(BuildContext context) => isDark(context) ? surface : surfaceLt;
  static Color surfaceLightOf(BuildContext context) => isDark(context) ? surfaceLight : surfaceLightLt;
  static Color borderOf(BuildContext context) => isDark(context) ? border : borderLt;
  static Color safeOf(BuildContext context) => isDark(context) ? safeDark : safe;
  static Color textPrimaryOf(BuildContext context) => isDark(context) ? textPrimary : textPrimaryLt;
  static Color textSecondaryOf(BuildContext context) => isDark(context) ? textSecondary : textSecondaryLt;
  static Color textMutedOf(BuildContext context) => isDark(context) ? textMuted : textMutedLt;

  static Color tierColor(int score) {
    if (score >= 75) return critical;
    if (score >= 50) return warning;
    if (score >= 25) return const Color(0xFFFF9800);
    return safe;
  }

  static String tierLabel(int score) {
    if (score >= 75) return 'IMMEDIATE ACTION';
    if (score >= 50) return 'EARLY INTERVENTION';
    if (score >= 25) return 'MONITOR RISK';
    return 'MAINTAIN BALANCE';
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: safeDark,
        secondary: warning,
        surface: surface,
        error: critical,
        onPrimary: bg,
        onSecondary: bg,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: safeDark,
          foregroundColor: bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: safeDark.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 11, color: safeDark, fontFamily: 'Poppins');
          }
          return const TextStyle(fontSize: 11, color: textSecondary, fontFamily: 'Poppins');
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.light(
        primary: safe,
        secondary: warning,
        surface: surfaceLt,
        error: critical,
        onPrimary: Colors.white,
        onSecondary: textPrimaryLt,
        onSurface: textPrimaryLt,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLt,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLt),
      ),
      cardTheme: CardThemeData(
        color: surfaceLt,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderLt),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: safe,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLt,
        indicatorColor: safe.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 11, color: safe, fontFamily: 'Poppins');
          }
          return TextStyle(fontSize: 11, color: textSecondaryLt, fontFamily: 'Poppins');
        }),
      ),
    );
  }
}
