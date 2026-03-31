import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF000666);
  static const Color primaryContainer = Color(0xFF1A237E);
  static const Color secondary = Color(0xFF1B6D24);
  static const Color secondaryContainer = Color(0xFFA0F399);
  static const Color tertiary = Color(0xFF5F1400);
  static const Color tertiaryContainer = Color(0xFFFFDBD1);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceLow = Color(0xFFF3F4F5);
  static const Color surfaceHigh = Color(0xFFE7E8E9);
  static const Color surfaceHighest = Color(0xFFE1E3E4);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color outline = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D4);
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFF59E0B);
}

ThemeData buildAppTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ).copyWith(
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurface,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    canvasColor: AppColors.surface,
    dividerColor: Colors.transparent,
    textTheme: base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 56,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -1.2,
      ),
      displayMedium: const TextStyle(
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.8,
      ),
      headlineLarge: const TextStyle(
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.6,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.4,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        height: 1.24,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLowest,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.onSurface,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
