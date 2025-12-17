import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ===== Palette (from screenshot) =====
  // Primary set
  static const Color cream = Color(0xFFE0DACE); // e0dace
  static const Color forest = Color(0xFF4B5143); // 4b5143
  static const Color navy = Color(0xFF0C2C48); // 0c2c48
  static const Color ink = Color(0xFF010101); // 010101

  // Secondary set
  static const Color slate = Color(0xFF616A71); // 616a71
  static const Color clay = Color(0xFFA47758); // a47758
  static const Color olive = Color(0xFF777B65); // 777b65

  // ===== Brand mappings =====
  static const Color primary = navy; // brand primary (dark)
  static const Color accent = clay; // accent color
  static const Color backgroundLight = cream;
  static const Color backgroundDark = ink;
  static const Color surfaceLight = cream;
  static const Color surfaceDark = forest;
  static const Color textPrimary = ink;
  static const Color textSecondary = slate;

  /// Slightly bump text on large screens (tablets/desktop).
  static TextScaler textScalerForWidth(double width) {
    if (width >= 1200) return const TextScaler.linear(1.5);
    if (width >= 900) return const TextScaler.linear(1.5);
    return const TextScaler.linear(1.0);
  }

  static ThemeData light() {
    final baseTextTheme = const TextTheme().apply(
      fontFamily: 'Zain',
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    // Build a scheme and override the "on*" contrast colors so text flips to cream on dark brand surfaces.
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      tertiary: olive,
      surface: surfaceLight,
      background: backgroundLight,
      brightness: Brightness.light,
    ).copyWith(
      onPrimary: cream, // <-- text/icon color on primary (navy) backgrounds
      onSecondary: cream, // optional: cream on accent surfaces
      onTertiary: cream,
      onSurface: textPrimary,
      onBackground: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Zain',
      colorScheme: scheme,

      scaffoldBackgroundColor: backgroundLight,

      // When a widget uses the "primary" color (e.g., AppBar), use cream for text/icons.
      primaryTextTheme: baseTextTheme.apply(
        bodyColor: cream,
        displayColor: cream,
      ),
      primaryIconTheme: const IconThemeData(color: cream),

      // APP BAR: dark background, cream foreground (title + icons) + light status bar icons.
      appBarTheme: AppBarTheme(
        backgroundColor: primary, // dark brand background
        foregroundColor: cream, // title + icons
        elevation: 0,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: cream,
        ),
        iconTheme: const IconThemeData(color: cream),
        actionsIconTheme: const IconThemeData(color: cream),
        systemOverlayStyle:
            SystemUiOverlayStyle.light, // status bar icons on dark bg
      ),

      textTheme: baseTextTheme,

      cardTheme: CardThemeData(
        color: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
      ),

      // Buttons that live on primary surfaces get cream text/icons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cream, // was white
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: baseTextTheme.bodyMedium,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      // Optional: FAB on dark brand background with cream icon.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: cream,
      ),
    );
  }

  // You said the app is light-only, but leaving dark() intact.
  static ThemeData dark() {
    final baseTextTheme = const TextTheme().apply(
      fontFamily: 'Zain',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      tertiary: olive,
      surface: surfaceDark,
      background: backgroundDark,
      brightness: Brightness.dark,
    ).copyWith(
      onPrimary: cream,
      onSecondary: cream,
      onTertiary: cream,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Zain',
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: baseTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: cream),
      ),
      textTheme: baseTextTheme,
      cardTheme: CardThemeData(
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cream,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cream,
          side: const BorderSide(color: cream),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: baseTextTheme.bodyMedium,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
      ),
    );
  }
}
