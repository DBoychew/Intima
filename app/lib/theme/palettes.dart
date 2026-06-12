import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Цветовите палитри на Intima. Всяка дефинира пълните 13 токена за
/// тъмен и светъл режим — темата (dark/light/system) и палитрата са
/// независими избори. Класиката „Intima" и „Роуз голд" са безплатни
/// (вкус от функцията); „Среднощно синьо" и „Океан" са Premium.
enum AppPalette {
  intima,
  roseGold,
  midnightBlue,
  ocean;

  bool get isPremium =>
      this == AppPalette.midnightBlue || this == AppPalette.ocean;

  IntimaColors get dark => switch (this) {
        AppPalette.intima => IntimaColors.dark,
        AppPalette.roseGold => _roseGoldDark,
        AppPalette.midnightBlue => _midnightDark,
        AppPalette.ocean => _oceanDark,
      };

  IntimaColors get light => switch (this) {
        AppPalette.intima => IntimaColors.light,
        AppPalette.roseGold => _roseGoldLight,
        AppPalette.midnightBlue => _midnightLight,
        AppPalette.ocean => _oceanLight,
      };

  /// Стойността в защитеното хранилище; [fromStored] връща класиката
  /// при непознат/липсващ запис.
  String get storageValue => name;

  static AppPalette fromStored(String? value) => AppPalette.values
      .firstWhere((p) => p.name == value, orElse: () => AppPalette.intima);
}

/// Роуз голд — топло розово злато върху виненотъмни повърхности.
const _roseGoldDark = IntimaColors(
  background: Color(0xFF231019),
  surface: Color(0xFF301823),
  surfaceHigh: Color(0xFF3D202E),
  primary: Color(0xFFD9466F),
  primarySoft: Color(0xFFF08CA8),
  accent: Color(0xFFE0A18A),
  accentSoft: Color(0xFFF0C0AE),
  textPrimary: Color(0xFFFAF0F2),
  textSecondary: Color(0xFFB599A4),
  period: Color(0xFFEF5A6F),
  intimacy: Color(0xFFE0A18A),
  fertile: Color(0xFF58C7A0),
  error: Color(0xFFF25C6B),
);

const _roseGoldLight = IntimaColors(
  background: Color(0xFFF3E4E8),
  surface: Color(0xFFFBF2F4),
  surfaceHigh: Color(0xFFEAD2D9),
  primary: Color(0xFFB83A64),
  primarySoft: Color(0xFFC94E78),
  accent: Color(0xFFA8643C),
  accentSoft: Color(0xFF8F5430),
  textPrimary: Color(0xFF33141E),
  textSecondary: Color(0xFF7A5560),
  period: Color(0xFFC42B53),
  intimacy: Color(0xFFA8643C),
  fertile: Color(0xFF178F6C),
  error: Color(0xFFC92B43),
);

/// Среднощно синьо — дълбоко синьо с шампанско злато.
const _midnightDark = IntimaColors(
  background: Color(0xFF0E1426),
  surface: Color(0xFF16203A),
  surfaceHigh: Color(0xFF1F2C4D),
  primary: Color(0xFF4F7CF0),
  primarySoft: Color(0xFF8FB0F7),
  accent: Color(0xFFD4B16A),
  accentSoft: Color(0xFFE8CD93),
  textPrimary: Color(0xFFEDF1FA),
  textSecondary: Color(0xFF8E9AB8),
  period: Color(0xFFE25563),
  intimacy: Color(0xFFD4B16A),
  fertile: Color(0xFF4EC9B0),
  error: Color(0xFFEF5366),
);

const _midnightLight = IntimaColors(
  background: Color(0xFFE3E9F5),
  surface: Color(0xFFF2F5FC),
  surfaceHigh: Color(0xFFD0DAEE),
  primary: Color(0xFF2C55C9),
  primarySoft: Color(0xFF3E66D6),
  accent: Color(0xFF8F6B14),
  accentSoft: Color(0xFF7A5A0E),
  textPrimary: Color(0xFF18203A),
  textSecondary: Color(0xFF4D5A7A),
  period: Color(0xFFC93350),
  intimacy: Color(0xFF8F6B14),
  fertile: Color(0xFF178F6C),
  error: Color(0xFFC92B43),
);

/// Океан — спокойно тюркоазено с коралов акцент.
const _oceanDark = IntimaColors(
  background: Color(0xFF0B1D22),
  surface: Color(0xFF122B31),
  surfaceHigh: Color(0xFF1A3A42),
  primary: Color(0xFF1F9E8F),
  primarySoft: Color(0xFF66CFC2),
  accent: Color(0xFFED8A6B),
  accentSoft: Color(0xFFF5AD96),
  textPrimary: Color(0xFFEAF6F5),
  textSecondary: Color(0xFF87A8A6),
  period: Color(0xFFE8556D),
  intimacy: Color(0xFFED8A6B),
  fertile: Color(0xFF74C969),
  error: Color(0xFFEF5366),
);

const _oceanLight = IntimaColors(
  background: Color(0xFFDFEDEE),
  surface: Color(0xFFF1F8F8),
  surfaceHigh: Color(0xFFC9E0E2),
  primary: Color(0xFF0E7C70),
  primarySoft: Color(0xFF169285),
  accent: Color(0xFFBA5C3B),
  accentSoft: Color(0xFF9E4B2E),
  textPrimary: Color(0xFF122B2E),
  textSecondary: Color(0xFF44666B),
  period: Color(0xFFC93350),
  intimacy: Color(0xFFBA5C3B),
  fertile: Color(0xFF178F50),
  error: Color(0xFFC92B43),
);
