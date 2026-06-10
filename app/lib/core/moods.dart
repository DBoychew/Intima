/// Петте настроения на Intima — общи за календара и дневника.
const moodEmojis = ['😞', '😐', '🙂', '😊', '🥰'];

/// Емоджи за [mood] или неутрален маркер при липса.
String moodEmoji(int? mood) =>
    mood == null ? '📝' : moodEmojis[mood.clamp(0, moodEmojis.length - 1)];
