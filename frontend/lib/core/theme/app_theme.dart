import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette (User Specified)
  // #193940: Deep Slate Teal
  static const Color primary = Color(0xFF193940);
  static const Color primaryLight = Color(0xFF2A535C);
  static const Color primaryDark = Color(0xFF10252A);

  // #7ABF5A: Agricultural Mid Green
  static const Color secondary = Color(0xFF7ABF5A);
  static const Color secondaryLight = Color(0xFF8ECC6F);
  static const Color secondaryDark = Color(0xFF5D9A42);

  // #9BF272: Vibrant Sprout Lime
  static const Color accent = Color(0xFF9BF272);
  static const Color accentLight = Color(0xFFD6F9C2);
  static const Color accentDark = Color(0xFF72CB4B);

  // #BAC8D9: Soft Steel Mist
  static const Color steelMist = Color(0xFFBAC8D9);
  static const Color steelMistLight = Color(0xFFE8EEF5);
  static const Color steelMistDark = Color(0xFF8FA3BA);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0B1716);
  static const Color surface = Color(0xFF142522);
  static const Color surfaceVariant = Color(0xFF1D3530);

  // Status Colors
  static const Color success = Color(0xFF7ABF5A);
  static const Color warning = Color(0xFFE67E22);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2980B9);

  // Escrow & MFS Colors
  static const Color bkashPink = Color(0xFFE2136E);
  static const Color nagadOrange = Color(0xFFF7941D);
  static const Color rocketPurple = Color(0xFF8C3494);

  // Text & Borders
  static const Color textPrimary = Color(0xFFE2F0E7);
  static const Color textSecondary = Color(0xFFB2C7BB);
  static const Color textLight = Color(0xFF78958A);
  static const Color border = Color(0xFF315048);
  static const Color divider = Color(0xFF28423B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.secondaryDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.secondary,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
