import 'package:flutter/material.dart';

/// Dark "observability" theme — looks like a developer tool, not a wellness app.
class ObsTheme {
  // Core palette
  static const Color bg = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF252525);
  static const Color border = Color(0xFF333333);

  // Accent colors
  static const Color safe = Color(0xFF00FF41);       // Matrix green
  static const Color warning = Color(0xFFFFD700);     // Gold
  static const Color critical = Color(0xFFFF3E3E);    // Red
  static const Color info = Color(0xFF4FC3F7);        // Light blue
  static const Color muted = Color(0xFF666666);

  // Text
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF555555);

  // Status colors mapped to OCH tiers
  static Color tierColor(int score) {
    if (score >= 75) return critical;
    if (score >= 50) return warning;
    if (score >= 25) return Color(0xFFFF9800); // orange
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
        primary: safe,
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
          backgroundColor: safe,
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
        indicatorColor: safe.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 11, color: safe, fontFamily: 'Poppins');
          }
          return const TextStyle(fontSize: 11, color: textSecondary, fontFamily: 'Poppins');
        }),
      ),
    );
  }
}
