import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/data/calendar_repository.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';
import 'package:intima/data/diary_repository.dart';
import 'package:intima/security/app_lock.dart';

/// В stealth (decoy) режим приложението изглежда празно и нищо
/// не се записва върху реалните данни.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CalendarRepository calendar;
  late DiaryRepository diary;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await dbManager.openForTesting(IntimaDatabase(NativeDatabase.memory()));
    calendar = CalendarRepository(dbManager);
    diary = DiaryRepository(dbManager);
    cycleSettings.resetToDefaults();

    // Реални данни преди влизане в stealth.
    await calendar.saveQuickLog(
      date: DateTime(2026, 6, 10),
      mood: 4,
      period: true,
      libido: 0.6,
      energy: 0.6,
      symptoms: const [],
      moments: const [MomentDraft()],
    );
    await diary.create(
      title: 'Тайна',
      body: 'Лично съдържание',
      date: DateTime(2026, 6, 9),
      mood: 4,
      tags: const [],
      photos: const [],
    );

    await appLock.setPin('1111');
    await appLock.setDecoyPin('2222');
    appLock.lock();
    appLock.unlockDecoy();
  });

  tearDown(() async {
    appLock.lock();
    await appLock.disablePin();
  });

  test('календарът и дневникът изглеждат празни', () async {
    final june = await calendar.month(2026, 6);
    expect(june.logs, isEmpty);
    expect(june.momentsByDay, isEmpty);
    expect(await diary.all(), isEmpty);
    expect(await diary.memory(), isNull);

    await calendar.refreshLastPeriodStart();
    expect(cycleSettings.lastPeriodStart, isNull);
  });

  test('записите в stealth не пипат реалните данни', () async {
    await calendar.saveQuickLog(
      date: DateTime(2026, 6, 15),
      mood: 1,
      period: true,
      libido: 0.1,
      energy: 0.1,
      symptoms: const ['ПМС'],
      moments: const [],
    );
    await diary.create(
      title: 'Фалшив запис',
      body: '…',
      date: DateTime(2026, 6, 15),
      mood: 1,
      tags: const [],
      photos: const [],
    );

    // Излизаме от stealth → реалните данни са непокътнати.
    appLock.lock();
    final june = await calendar.month(2026, 6);
    expect(june.isPeriod(10), isTrue);
    expect(june.logs.containsKey(15), isFalse);
    final entries = await diary.all();
    expect(entries.single.title, 'Тайна');
  });

  test('изтриване в stealth не трие реални записи', () async {
    appLock.lock(); // реален режим, за да вземем реалния запис
    final real = (await diary.all()).single;
    appLock.lock();
    appLock.unlockDecoy();

    await diary.delete(real); // no-op в stealth
    appLock.lock();
    expect(await diary.all(), hasLength(1));
  });
}
