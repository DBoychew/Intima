/// Модел на запис в дневника (in-memory за прототипа; БД идва във Фаза 4).
class DiaryEntry {
  DiaryEntry({
    required this.title,
    required this.text,
    required this.date,
    this.mood,
    this.tags = const [],
    this.hasPhoto = false,
  });

  final String title;
  final String text;
  final String date;
  final int? mood;
  final List<String> tags;
  final bool hasPhoto;

  static const moods = ['😞', '😐', '🙂', '😊', '🥰'];

  String get moodEmoji => mood == null ? '📝' : moods[mood!];

  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        text.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
