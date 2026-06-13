import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../features/poses/poses_data.dart';
import '../security/app_lock.dart';
import '../security/secure_store.dart';

/// Статус на потребителя спрямо една поза.
enum PoseStatus { none, wantToTry, tried, favorite }

class PoseState {
  const PoseState({
    this.status = PoseStatus.none,
    this.rating,
    this.note = '',
    this.triedOn,
  });

  final PoseStatus status;

  /// 1..5 звезди, null = без оценка.
  final int? rating;
  final String note;
  final DateTime? triedOn;

  PoseState copyWith({
    PoseStatus? status,
    int? rating,
    bool clearRating = false,
    String? note,
    DateTime? triedOn,
    bool clearTriedOn = false,
  }) =>
      PoseState(
        status: status ?? this.status,
        rating: clearRating ? null : (rating ?? this.rating),
        note: note ?? this.note,
        triedOn: clearTriedOn ? null : (triedOn ?? this.triedOn),
      );

  Map<String, dynamic> toJson() => {
        's': status.index,
        if (rating != null) 'r': rating,
        if (note.isNotEmpty) 'n': note,
        if (triedOn != null) 't': triedOn!.toIso8601String(),
      };

  static PoseState fromJson(Map<String, dynamic> j) => PoseState(
        status: PoseStatus.values[(j['s'] as num?)?.toInt() ?? 0],
        rating: (j['r'] as num?)?.toInt(),
        note: j['n'] as String? ?? '',
        triedOn: j['t'] == null ? null : DateTime.tryParse(j['t'] as String),
      );
}

/// Чисто филтриране — host-тестваемо без UI/съхранение.
List<Pose> filterPoses(
  List<Pose> poses,
  Map<String, PoseState> states, {
  PosePack? pack,
  int? difficulty,
  int? intensity,
  PoseMood? mood,
  PoseStatus? status,
}) {
  return [
    for (final p in poses)
      if ((pack == null || p.pack == pack) &&
          (difficulty == null || p.difficulty == difficulty) &&
          (intensity == null || p.intensity == intensity) &&
          (mood == null || p.moods.contains(mood)) &&
          (status == null ||
              (states[p.id]?.status ?? PoseStatus.none) == status))
        p,
  ];
}

/// Състоянията на позите, пазени локално в защитеното хранилище
/// (JSON map id → PoseState). Без сървър — лично е.
class PoseRepository extends ChangeNotifier {
  static const _key = 'pose_states';

  Map<String, PoseState> _states = {};
  Map<String, PoseState> get states =>
      appLock.decoyActive ? const {} : _states;

  PoseState stateOf(String id) =>
      appLock.decoyActive ? const PoseState() : (_states[id] ?? const PoseState());

  Future<void> init() async {
    final raw = await SecureStore.read(_key);
    if (raw == null) {
      _states = {};
      return;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _states = map.map(
        (k, v) => MapEntry(k, PoseState.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _persist() async {
    await SecureStore.write(
      _key,
      jsonEncode(_states.map((k, v) => MapEntry(k, v.toJson()))),
    );
    notifyListeners();
  }

  Future<void> update(String id, PoseState state) async {
    // Stealth копието не пише нищо.
    if (appLock.decoyActive) return;
    // Празно състояние → махаме записа, за да не трупаме.
    if (state.status == PoseStatus.none &&
        state.rating == null &&
        state.note.isEmpty &&
        state.triedOn == null) {
      _states.remove(id);
    } else {
      _states[id] = state;
    }
    await _persist();
  }

  Future<void> reset() async {
    _states = {};
    await SecureStore.delete(_key);
    notifyListeners();
  }
}

final poseRepository = PoseRepository();
