/// Шанс за забременяване според деня спрямо овулацията.
///
/// Базирано на класическите проучвания за фертилния прозорец (напр.
/// Wilcox et al.): зачеване е възможно в ~6-дневен прозорец — петте дни
/// преди овулацията плюс самия ден; сперматозоидите оцеляват до ~5 дни,
/// а яйцеклетката ~24 часа. Стойностите са ПРИБЛИЗИТЕЛНИ и НЕ са метод
/// за контрацепция.
enum FertilityLevel { negligible, low, moderate, high, veryHigh }

class PregnancyChance {
  const PregnancyChance({
    required this.level,
    required this.percentApprox,
    required this.daysFromOvulation,
  });

  final FertilityLevel level;

  /// Приблизителен процент (груба ориентировъчна стойност).
  final int percentApprox;

  /// Дни спрямо овулацията: 0 = в деня на овулацията, отрицателно =
  /// преди нея, положително = след нея.
  final int daysFromOvulation;
}

PregnancyChance pregnancyChance(int daysFromOvulation) {
  final d = daysFromOvulation;
  final (FertilityLevel level, int pct) = switch (d) {
    0 => (FertilityLevel.veryHigh, 33),
    -1 => (FertilityLevel.veryHigh, 31),
    -2 => (FertilityLevel.high, 27),
    -3 => (FertilityLevel.moderate, 20),
    -4 => (FertilityLevel.low, 14),
    -5 => (FertilityLevel.low, 10),
    1 => (FertilityLevel.low, 8), // яйцеклетката може да е още жива
    _ => (FertilityLevel.negligible, 0), // ≤ -6 или ≥ +2
  };
  return PregnancyChance(
    level: level,
    percentApprox: pct,
    daysFromOvulation: d,
  );
}
