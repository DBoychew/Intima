/// Персонализирани журналинг промптове (Фаза 9) — избор изцяло на
/// устройството според фазата на цикъла. Без AI, без мрежа.
enum PromptKind { menstrual, follicular, ovulation, luteal, neutral }

/// Избира вид промпт по дни от овулацията и дали денят е менструален.
/// [daysFromOvulation] null → неутрален (няма достатъчно данни).
PromptKind suggestPromptKind({
  int? daysFromOvulation,
  bool isPeriod = false,
}) {
  if (isPeriod) return PromptKind.menstrual;
  final d = daysFromOvulation;
  if (d == null) return PromptKind.neutral;
  if (d >= -1 && d <= 1) return PromptKind.ovulation;
  if (d < -1) return PromptKind.follicular;
  return PromptKind.luteal; // d > 1
}
