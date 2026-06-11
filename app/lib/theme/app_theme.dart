import 'package:flutter/material.dart';

/// Източник на истината за дизайн токените — виж docs/design/DESIGN-SYSTEM.md
abstract class AppColors {
  static const background = Color(0xFF1A1025);
  static const surface = Color(0xFF251735);
  static const surfaceHigh = Color(0xFF2F1F44);
  static const primary = Color(0xFF7C3AED);
  static const primarySoft = Color(0xFFA78BFA);
  static const accent = Color(0xFFD4A843);
  static const accentSoft = Color(0xFFE8C97A);
  static const textPrimary = Color(0xFFF3EFFA);
  static const textSecondary = Color(0xFF9B8FB0);
  static const period = Color(0xFFE25563);
  static const intimacy = Color(0xFFD4A843);
  static const fertile = Color(0xFF5EC9A8);
  static const error = Color(0xFFEF5366);
}

/// Вградени шрифтове (assets/fonts) — без runtime fetch, приложението
/// е изцяло офлайн.
abstract class AppFonts {
  static const body = 'Inter';
  static const display = 'PlayfairDisplay';
}

abstract class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Color(0xFF2A1F0A),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceHigh,
        error: AppColors.error,
      ),
    );

    final body = base.textTheme.apply(
      fontFamily: AppFonts.body,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    final textTheme = body.copyWith(
      displaySmall: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      headlineSmall: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      titleLarge: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      bodyMedium: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
          color: AppColors.textPrimary),
      labelMedium: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13,
          color: AppColors.textSecondary),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Color(0xFF2A1F0A),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary.withValues(alpha: 0.22),
        side: const BorderSide(color: AppColors.surfaceHigh),
        labelStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: AppColors.textPrimary),
        shape: const StadiumBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            color: AppColors.textSecondary)),
        iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: AppColors.textPrimary)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
            fontFamily: AppFonts.body, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(
            fontFamily: AppFonts.body, color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.surfaceHigh),
    );
  }
}
