import 'package:flutter/material.dart';

/// Брандовите цветове като ThemeExtension — екраните ги четат през
/// `context.colors`, така светлата/тъмната тема се сменят навсякъде.
/// Източник на истината за токените: docs/design/DESIGN-SYSTEM.md.
class IntimaColors extends ThemeExtension<IntimaColors> {
  const IntimaColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.period,
    required this.intimacy,
    required this.fertile,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color primary;
  final Color primarySoft;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color period;
  final Color intimacy;
  final Color fertile;
  final Color error;

  static const dark = IntimaColors(
    background: Color(0xFF1A1025),
    surface: Color(0xFF251735),
    surfaceHigh: Color(0xFF2F1F44),
    primary: Color(0xFF7C3AED),
    primarySoft: Color(0xFFA78BFA),
    accent: Color(0xFFD4A843),
    accentSoft: Color(0xFFE8C97A),
    textPrimary: Color(0xFFF3EFFA),
    textSecondary: Color(0xFF9B8FB0),
    period: Color(0xFFE25563),
    intimacy: Color(0xFFD4A843),
    fertile: Color(0xFF5EC9A8),
    error: Color(0xFFEF5366),
  );

  /// Светла палитра „лилава мъгла" — не бяла: тонирани лавандулови
  /// повърхности, същият бранд (лилаво + злато), потъмнени акценти
  /// за контраст върху светло.
  static const light = IntimaColors(
    background: Color(0xFFE9E2F3),
    surface: Color(0xFFF4F0FA),
    surfaceHigh: Color(0xFFDCD1EC),
    primary: Color(0xFF6D2FD6),
    primarySoft: Color(0xFF7C3AED),
    accent: Color(0xFFA87B22),
    accentSoft: Color(0xFF8F6914),
    textPrimary: Color(0xFF241A33),
    textSecondary: Color(0xFF5E5276),
    period: Color(0xFFC93350),
    intimacy: Color(0xFFA87B22),
    fertile: Color(0xFF178F6C),
    error: Color(0xFFC92B43),
  );

  @override
  IntimaColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? primary,
    Color? primarySoft,
    Color? accent,
    Color? accentSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? period,
    Color? intimacy,
    Color? fertile,
    Color? error,
  }) {
    return IntimaColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      period: period ?? this.period,
      intimacy: intimacy ?? this.intimacy,
      fertile: fertile ?? this.fertile,
      error: error ?? this.error,
    );
  }

  @override
  IntimaColors lerp(IntimaColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return IntimaColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      primary: l(primary, other.primary),
      primarySoft: l(primarySoft, other.primarySoft),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      period: l(period, other.period),
      intimacy: l(intimacy, other.intimacy),
      fertile: l(fertile, other.fertile),
      error: l(error, other.error),
    );
  }
}

/// `context.colors.accent` навсякъде из екраните.
extension IntimaColorsX on BuildContext {
  IntimaColors get colors => Theme.of(this).extension<IntimaColors>()!;
}

/// Вградени шрифтове (assets/fonts) — без runtime fetch, приложението
/// е изцяло офлайн.
abstract class AppFonts {
  static const body = 'Inter';
  static const display = 'PlayfairDisplay';
}

abstract class AppTheme {
  static ThemeData dark(IntimaColors colors) =>
      _build(colors, Brightness.dark);
  static ThemeData light(IntimaColors colors) =>
      _build(colors, Brightness.light);

  static ThemeData _build(IntimaColors c, Brightness brightness) {
    final onAccent =
        brightness == Brightness.dark ? const Color(0xFF2A1F0A) : Colors.white;
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: brightness,
      ).copyWith(
        primary: c.primary,
        onPrimary: Colors.white,
        secondary: c.accent,
        onSecondary: onAccent,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surfaceHigh,
        error: c.error,
      ),
      extensions: [c],
    );

    final body = base.textTheme.apply(
      fontFamily: AppFonts.body,
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    );
    final textTheme = body.copyWith(
      displaySmall: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: c.textPrimary),
      headlineSmall: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: c.textPrimary),
      titleLarge: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.textPrimary),
      bodyMedium: TextStyle(
          fontFamily: AppFonts.body, fontSize: 15, color: c.textPrimary),
      labelMedium: TextStyle(
          fontFamily: AppFonts.body, fontSize: 13, color: c.textSecondary),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: onAccent,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: c.primary.withValues(alpha: 0.22),
        side: BorderSide(color: c.surfaceHigh),
        labelStyle: TextStyle(
            fontFamily: AppFonts.body, fontSize: 13, color: c.textPrimary),
        shape: const StadiumBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            color: c.textSecondary)),
        iconTheme:
            WidgetStatePropertyAll(IconThemeData(color: c.textPrimary)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle:
            TextStyle(fontFamily: AppFonts.body, color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceHigh,
        contentTextStyle:
            TextStyle(fontFamily: AppFonts.body, color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: c.surfaceHigh),
    );
  }
}
