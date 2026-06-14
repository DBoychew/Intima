import 'package:flutter/material.dart';

/// Библиотека с пози (Фаза 8). Съдържанието е с wellness тон — без
/// графични изображения; илюстрациите са стилизирани силуети
/// (placeholder, докато дойде истинският арт — виж ZA_DIMITAR.md).

/// Пакетите: стартовият е безплатен, останалите са Premium (или
/// еднократна IAP покупка, когато billing-ът влезе).
enum PosePack { starter, romance, adventure }

extension PosePackX on PosePack {
  bool get isFree => this == PosePack.starter;
}

/// Настроение/усещане на позата — за филтрите.
enum PoseMood { tender, playful, passionate, adventurous, slow }

class Pose {
  const Pose({
    required this.id,
    required this.pack,
    required this.difficulty,
    required this.intensity,
    required this.moods,
    required this.emoji,
    required this.color,
    required Map<String, String> name,
    required Map<String, String> description,
  })  : _name = name,
        _description = description;

  final String id;
  final PosePack pack;

  /// 1..3 — колко е „трудна".
  final int difficulty;

  /// 1..3 — интензивност.
  final int intensity;

  final List<PoseMood> moods;
  final String emoji;
  final Color color;

  final Map<String, String> _name;
  final Map<String, String> _description;

  String name(String locale) =>
      _name[locale.startsWith('bg') ? 'bg' : 'en'] ?? _name['en']!;
  String description(String locale) =>
      _description[locale.startsWith('bg') ? 'bg' : 'en'] ??
      _description['en']!;
}

/// Курираният каталог. Имената/описанията са двуезични тук, за да не
/// раздуваме .arb файловете с десетки ключове за съдържание.
const posesCatalog = <Pose>[
  // ── Стартов пакет (безплатен) ──
  Pose(
    id: 'spooning',
    pack: PosePack.starter,
    difficulty: 1,
    intensity: 1,
    moods: [PoseMood.tender, PoseMood.slow],
    emoji: '🌙',
    color: Color(0xFF7C3AED),
    name: {'bg': 'Лъжички', 'en': 'Spooning'},
    description: {
      'bg': 'Близост на спокойствие — двамата на една страна, прегърнати. '
          'Топло, бавно, без бързане.',
      'en': 'Easy closeness — both on your side, wrapped together. '
          'Warm, slow, unhurried.',
    },
  ),
  Pose(
    id: 'face_to_face',
    pack: PosePack.starter,
    difficulty: 1,
    intensity: 2,
    moods: [PoseMood.tender, PoseMood.passionate],
    emoji: '💞',
    color: Color(0xFFD9466F),
    name: {'bg': 'Лице в лице', 'en': 'Face to face'},
    description: {
      'bg': 'Очи в очи, преплетени — за повече свързаност и нежност.',
      'en': 'Eye to eye, intertwined — for connection and tenderness.',
    },
  ),
  Pose(
    id: 'seated_embrace',
    pack: PosePack.starter,
    difficulty: 2,
    intensity: 2,
    moods: [PoseMood.tender, PoseMood.playful],
    emoji: '🤍',
    color: Color(0xFF5EC9A8),
    name: {'bg': 'Седнала прегръдка', 'en': 'Seated embrace'},
    description: {
      'bg': 'Единият седнал, другият в скута — близо, лице в лице.',
      'en': 'One seated, the other in their lap — close, face to face.',
    },
  ),
  Pose(
    id: 'on_top',
    pack: PosePack.starter,
    difficulty: 2,
    intensity: 3,
    moods: [PoseMood.passionate, PoseMood.playful],
    emoji: '🔥',
    color: Color(0xFFE0A18A),
    name: {'bg': 'Отгоре', 'en': 'On top'},
    description: {
      'bg': 'Единият води темпото — повече контрол и близост.',
      'en': 'One sets the pace — more control and closeness.',
    },
  ),
  // ── Романтика (Premium) ──
  Pose(
    id: 'candlelight',
    pack: PosePack.romance,
    difficulty: 1,
    intensity: 2,
    moods: [PoseMood.slow, PoseMood.tender],
    emoji: '🕯️',
    color: Color(0xFFD4A843),
    name: {'bg': 'На свещи', 'en': 'By candlelight'},
    description: {
      'bg': 'Бавно начало с масаж и нежност — за специална вечер.',
      'en': 'A slow start with massage and tenderness — for a special night.',
    },
  ),
  Pose(
    id: 'slow_dance',
    pack: PosePack.romance,
    difficulty: 2,
    intensity: 2,
    moods: [PoseMood.slow, PoseMood.passionate],
    emoji: '🌹',
    color: Color(0xFFC93350),
    name: {'bg': 'Бавен танц', 'en': 'Slow dance'},
    description: {
      'bg': 'Прави, прегърнати, в ритъм — близост на крака.',
      'en': 'Standing, embraced, in rhythm — closeness on your feet.',
    },
  ),
  Pose(
    id: 'morning_light',
    pack: PosePack.romance,
    difficulty: 1,
    intensity: 1,
    moods: [PoseMood.tender, PoseMood.slow],
    emoji: '☀️',
    color: Color(0xFFE8C97A),
    name: {'bg': 'Утринна светлина', 'en': 'Morning light'},
    description: {
      'bg': 'Лениво, топло събуждане заедно — без план, само вие двамата.',
      'en': 'A lazy, warm wake-up together — no plan, just the two of you.',
    },
  ),
  // ── Приключение (Premium) ──
  Pose(
    id: 'standing',
    pack: PosePack.adventure,
    difficulty: 3,
    intensity: 3,
    moods: [PoseMood.adventurous, PoseMood.passionate],
    emoji: '⚡',
    color: Color(0xFF4F7CF0),
    name: {'bg': 'Права', 'en': 'Standing'},
    description: {
      'bg': 'Спонтанно и игриво — изисква малко баланс и доверие.',
      'en': 'Spontaneous and playful — takes a little balance and trust.',
    },
  ),
  Pose(
    id: 'new_room',
    pack: PosePack.adventure,
    difficulty: 2,
    intensity: 3,
    moods: [PoseMood.adventurous, PoseMood.playful],
    emoji: '🗝️',
    color: Color(0xFF1F9E8F),
    name: {'bg': 'Нова стая', 'en': 'A new room'},
    description: {
      'bg': 'Смяна на обстановката — друга стая, друго усещане.',
      'en': 'Change the setting — a different room, a different mood.',
    },
  ),
  // ── Още старт (безплатни) ──
  Pose(
    id: 'reclining',
    pack: PosePack.starter,
    difficulty: 1,
    intensity: 1,
    moods: [PoseMood.tender, PoseMood.slow],
    emoji: '🌿',
    color: Color(0xFF5EC9A8),
    name: {'bg': 'Полегнали заедно', 'en': 'Reclining together'},
    description: {
      'bg': 'Облегнати един на друг — дишане в синхрон, без бързане.',
      'en': 'Leaning into each other — breathing in sync, no rush.',
    },
  ),
  Pose(
    id: 'kneeling',
    pack: PosePack.starter,
    difficulty: 2,
    intensity: 2,
    moods: [PoseMood.tender, PoseMood.passionate],
    emoji: '🤲',
    color: Color(0xFF9B6BE0),
    name: {'bg': 'На колене, лице в лице', 'en': 'Kneeling, face to face'},
    description: {
      'bg': 'И двамата на колене, прегърнати — равни, близки, в очите.',
      'en': 'Both kneeling, embraced — equal, close, eye to eye.',
    },
  ),
  // ── Още романтика (Premium) ──
  Pose(
    id: 'bath',
    pack: PosePack.romance,
    difficulty: 1,
    intensity: 2,
    moods: [PoseMood.slow, PoseMood.tender],
    emoji: '🛁',
    color: Color(0xFF4F9FF0),
    name: {'bg': 'Заедно във ваната', 'en': 'In the bath together'},
    description: {
      'bg': 'Топла вода, пяна и тишина — релакс, който води до близост.',
      'en': 'Warm water, foam and quiet — relaxation that leads to closeness.',
    },
  ),
  Pose(
    id: 'sunset',
    pack: PosePack.romance,
    difficulty: 2,
    intensity: 2,
    moods: [PoseMood.slow, PoseMood.passionate],
    emoji: '🌅',
    color: Color(0xFFE0884F),
    name: {'bg': 'На залез', 'en': 'At sunset'},
    description: {
      'bg': 'Меката светлина прави всичко по-нежно — без бързане.',
      'en': 'Soft light makes everything gentler — take your time.',
    },
  ),
  // ── Още приключение (Premium) ──
  Pose(
    id: 'mirror',
    pack: PosePack.adventure,
    difficulty: 2,
    intensity: 3,
    moods: [PoseMood.adventurous, PoseMood.passionate],
    emoji: '🪞',
    color: Color(0xFF6C7BF0),
    name: {'bg': 'Пред огледалото', 'en': 'By the mirror'},
    description: {
      'bg': 'Нов ъгъл, нов поглед — да се видите заедно.',
      'en': 'A new angle, a new view — seeing yourselves together.',
    },
  ),
  Pose(
    id: 'chair',
    pack: PosePack.adventure,
    difficulty: 2,
    intensity: 3,
    moods: [PoseMood.playful, PoseMood.adventurous],
    emoji: '🪑',
    color: Color(0xFF2BA89B),
    name: {'bg': 'На стола', 'en': 'On the chair'},
    description: {
      'bg': 'Единият седнал, другият отгоре — игриво и близко.',
      'en': 'One seated, the other on top — playful and close.',
    },
  ),
];

Pose? poseById(String id) {
  for (final p in posesCatalog) {
    if (p.id == id) return p;
  }
  return null;
}
