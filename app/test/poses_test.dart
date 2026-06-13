import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/data/pose_repository.dart';
import 'package:intima/features/poses/poses_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('каталогът има безплатен старт пакет и заключени колекции', () {
    expect(posesCatalog, isNotEmpty);
    expect(posesCatalog.where((p) => p.pack == PosePack.starter), isNotEmpty);
    expect(posesCatalog.where((p) => !p.pack.isFree), isNotEmpty);
    // Двуезични имена.
    final p = posesCatalog.first;
    expect(p.name('bg'), isNotEmpty);
    expect(p.name('en'), isNotEmpty);
    expect(p.name('bg'), isNot(p.name('en')));
  });

  test('filterPoses по пакет, настроение и статус', () {
    final states = {
      'spooning': const PoseState(status: PoseStatus.favorite),
    };
    expect(
      filterPoses(posesCatalog, states, pack: PosePack.starter)
          .every((p) => p.pack == PosePack.starter),
      isTrue,
    );
    expect(
      filterPoses(posesCatalog, states, mood: PoseMood.adventurous)
          .every((p) => p.moods.contains(PoseMood.adventurous)),
      isTrue,
    );
    final favs = filterPoses(posesCatalog, states,
        status: PoseStatus.favorite);
    expect(favs.map((p) => p.id), ['spooning']);
  });

  test('PoseRepository: статус, оценка, бележка персистират', () async {
    final repo = PoseRepository();
    await repo.init();
    expect(repo.stateOf('spooning').status, PoseStatus.none);

    await repo.update(
        'spooning',
        const PoseState(
            status: PoseStatus.tried, rating: 4, note: 'хубаво'));
    expect(repo.stateOf('spooning').rating, 4);

    // Нова инстанция = нов старт → чете от хранилището.
    final restarted = PoseRepository();
    await restarted.init();
    expect(restarted.stateOf('spooning').status, PoseStatus.tried);
    expect(restarted.stateOf('spooning').note, 'хубаво');

    // Изчистване до празно маха записа.
    await repo.update('spooning', const PoseState());
    final again = PoseRepository();
    await again.init();
    expect(again.stateOf('spooning').status, PoseStatus.none);
  });
}
