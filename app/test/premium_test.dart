import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/premium.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/diary_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Premium: активиране, персистентност, изключване', () async {
    final p = Premium();
    await p.init();
    expect(p.active, isFalse);

    var notified = 0;
    p.addListener(() => notified++);
    await p.activate();
    expect(p.active, isTrue);
    expect(notified, 1);

    // Нова инстанция = нов старт — статусът се пази.
    final restarted = Premium();
    await restarted.init();
    expect(restarted.active, isTrue);

    await p.deactivate();
    expect(p.active, isFalse);
  });

  test('PDF: генерира валиден документ с кирилица и тагове', () async {
    ByteData font(String path) {
      final bytes = File(path).readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }

    final entries = [
      DiaryEntryRow(
        id: 1,
        title: 'Вечерята с Н.',
        body: 'Най-хубавата вечер от месеци. Говорихме си до късно.',
        date: DateTime(2026, 6, 8),
        mood: 4,
        tags: '["нас","вечеря"]',
        hasPhoto: false,
        photos: '[]',
        videos: '[]',
        audios: '[]',
      ),
      DiaryEntryRow(
        id: 2,
        title: 'Благодарност',
        body: 'Днес съм благодарна за спокойствието.',
        date: DateTime(2026, 6, 10),
        mood: 3,
        tags: '[]',
        hasPhoto: false,
        photos: '["/липсваща/снимка.jpg"]', // не трябва да чупи нищо
        videos: '[]',
        audios: '[]',
      ),
    ];

    final bytes = await buildDiaryPdf(
      entries,
      title: 'Моят дневник',
      body: font('assets/fonts/Inter-Regular.ttf'),
      bold: font('assets/fonts/Inter-SemiBold.ttf'),
      display: font('assets/fonts/PlayfairDisplay-SemiBold.ttf'),
      formatDate: (d) => '${d.day}.${d.month}.${d.year}',
    );

    expect(bytes.length, greaterThan(1000));
    // PDF magic header.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
