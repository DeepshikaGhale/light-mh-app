import 'package:flutter/material.dart';

class ObsTheme {
  // ──── BRAND PALETTE ────
  static const Color brandText = Color(0xFF11363E);
  static const Color brandBg = Color(0xFFCCE7E2);
  static const Color brandSurface = Color(0xFFFFFFFF);

  // ──── DARK MODE PALETTE ────
  static const Color bg = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF252525);
  static const Color border = Color(0xFF333333);

  // ──── LIGHT MODE PALETTE ────
  static const Color bgLight = brandBg;
  static const Color surfaceLt = brandSurface;
  static const Color surfaceLightLt = Color(0xFFE0F0EC);
  static const Color borderLt = Color(0xFFB3D4CC);

  // ──── ACCENT COLORS ────
  static const Color safe = Color(0xFF11363E);
  static const Color safeDark = Color(0xFF00FF41);
  static const Color warning = Color(0xFFE8A317);
  static const Color critical = Color(0xFFD94444);
  static const Color info = Color(0xFF2B7A8E);
  static const Color muted = Color(0xFF6B8F8A);

  // ──── HIGHLIGHT COLORS (for crucial info) ────
  static const Color highlightUrgent = Color(0xFFFF6B6B);
  static const Color highlightPositive = Color(0xFF2ECC71);
  static const Color highlightWarn = Color(0xFFF39C12);
  static const Color highlightInfo = Color(0xFF3498DB);

  // ──── TEXT (dark) ────
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF555555);

  // ──── TEXT (light) ────
  static const Color textPrimaryLt = brandText;
  static const Color textSecondaryLt = Color(0xFF3D6B63);
  static const Color textMutedLt = Color(0xFF7FA39B);

  // ──── FONTS ────
  static const String titleFont = 'RubikOne';
  static const String bodyFont = 'Telegraf';

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
    if (score >= 25) return highlightWarn;
    return highlightPositive;
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
      fontFamily: bodyFont,
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
          fontFamily: titleFont,
          fontSize: 18,
          fontWeight: FontWeight.w400,
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
            fontFamily: bodyFont,
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
            return const TextStyle(fontSize: 11, color: safeDark, fontFamily: bodyFont);
          }
          return const TextStyle(fontSize: 11, color: textSecondary, fontFamily: bodyFont);
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: bodyFont,
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
          fontFamily: titleFont,
          fontSize: 18,
          fontWeight: FontWeight.w400,
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
            fontFamily: bodyFont,
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
            return const TextStyle(fontSize: 11, color: safe, fontFamily: bodyFont);
          }
          return TextStyle(fontSize: 11, color: textSecondaryLt, fontFamily: bodyFont);
        }),
      ),
    );
  }
}
