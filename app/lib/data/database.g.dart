// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _hasPhotoMeta = const VerificationMeta(
    'hasPhoto',
  );
  @override
  late final GeneratedColumn<bool> hasPhoto = GeneratedColumn<bool>(
    'has_photo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_photo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photosMeta = const VerificationMeta('photos');
  @override
  late final GeneratedColumn<String> photos = GeneratedColumn<String>(
    'photos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _videosMeta = const VerificationMeta('videos');
  @override
  late final GeneratedColumn<String> videos = GeneratedColumn<String>(
    'videos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _audiosMeta = const VerificationMeta('audios');
  @override
  late final GeneratedColumn<String> audios = GeneratedColumn<String>(
    'audios',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    date,
    mood,
    tags,
    hasPhoto,
    photoPath,
    photos,
    videos,
    audios,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('has_photo')) {
      context.handle(
        _hasPhotoMeta,
        hasPhoto.isAcceptableOrUnknown(data['has_photo']!, _hasPhotoMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('photos')) {
      context.handle(
        _photosMeta,
        photos.isAcceptableOrUnknown(data['photos']!, _photosMeta),
      );
    }
    if (data.containsKey('videos')) {
      context.handle(
        _videosMeta,
        videos.isAcceptableOrUnknown(data['videos']!, _videosMeta),
      );
    }
    if (data.containsKey('audios')) {
      context.handle(
        _audiosMeta,
        audios.isAcceptableOrUnknown(data['audios']!, _audiosMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      hasPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_photo'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      photos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photos'],
      )!,
      videos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}videos'],
      )!,
      audios: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audios'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntryRow extends DataClass implements Insertable<DiaryEntryRow> {
  final int id;
  final String title;
  final String body;
  final DateTime date;
  final int? mood;

  /// JSON списък от тагове, напр. `["нас","вечеря"]`.
  final String tags;
  final bool hasPhoto;

  /// Път до снимката в private storage на приложението (v2).
  /// Заменена от [photos] във v3 — пазим я само заради миграцията.
  final String? photoPath;

  /// JSON списък с пътища до снимките в private storage (v3).
  final String photos;

  /// JSON списък с пътища до видеата в private storage (v4, Premium).
  final String videos;

  /// JSON списък с пътища до аудио бележките в private storage
  /// (v5, Premium).
  final String audios;
  const DiaryEntryRow({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.mood,
    required this.tags,
    required this.hasPhoto,
    this.photoPath,
    required this.photos,
    required this.videos,
    required this.audios,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    map['tags'] = Variable<String>(tags);
    map['has_photo'] = Variable<bool>(hasPhoto);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['photos'] = Variable<String>(photos);
    map['videos'] = Variable<String>(videos);
    map['audios'] = Variable<String>(audios);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      date: Value(date),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      tags: Value(tags),
      hasPhoto: Value(hasPhoto),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photos: Value(photos),
      videos: Value(videos),
      audios: Value(audios),
    );
  }

  factory DiaryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntryRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      date: serializer.fromJson<DateTime>(json['date']),
      mood: serializer.fromJson<int?>(json['mood']),
      tags: serializer.fromJson<String>(json['tags']),
      hasPhoto: serializer.fromJson<bool>(json['hasPhoto']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      photos: serializer.fromJson<String>(json['photos']),
      videos: serializer.fromJson<String>(json['videos']),
      audios: serializer.fromJson<String>(json['audios']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'date': serializer.toJson<DateTime>(date),
      'mood': serializer.toJson<int?>(mood),
      'tags': serializer.toJson<String>(tags),
      'hasPhoto': serializer.toJson<bool>(hasPhoto),
      'photoPath': serializer.toJson<String?>(photoPath),
      'photos': serializer.toJson<String>(photos),
      'videos': serializer.toJson<String>(videos),
      'audios': serializer.toJson<String>(audios),
    };
  }

  DiaryEntryRow copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? date,
    Value<int?> mood = const Value.absent(),
    String? tags,
    bool? hasPhoto,
    Value<String?> photoPath = const Value.absent(),
    String? photos,
    String? videos,
    String? audios,
  }) => DiaryEntryRow(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    date: date ?? this.date,
    mood: mood.present ? mood.value : this.mood,
    tags: tags ?? this.tags,
    hasPhoto: hasPhoto ?? this.hasPhoto,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    photos: photos ?? this.photos,
    videos: videos ?? this.videos,
    audios: audios ?? this.audios,
  );
  DiaryEntryRow copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      tags: data.tags.present ? data.tags.value : this.tags,
      hasPhoto: data.hasPhoto.present ? data.hasPhoto.value : this.hasPhoto,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photos: data.photos.present ? data.photos.value : this.photos,
      videos: data.videos.present ? data.videos.value : this.videos,
      audios: data.audios.present ? data.audios.value : this.audios,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntryRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('hasPhoto: $hasPhoto, ')
          ..write('photoPath: $photoPath, ')
          ..write('photos: $photos, ')
          ..write('videos: $videos, ')
          ..write('audios: $audios')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    date,
    mood,
    tags,
    hasPhoto,
    photoPath,
    photos,
    videos,
    audios,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntryRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.tags == this.tags &&
          other.hasPhoto == this.hasPhoto &&
          other.photoPath == this.photoPath &&
          other.photos == this.photos &&
          other.videos == this.videos &&
          other.audios == this.audios);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntryRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> date;
  final Value<int?> mood;
  final Value<String> tags;
  final Value<bool> hasPhoto;
  final Value<String?> photoPath;
  final Value<String> photos;
  final Value<String> videos;
  final Value<String> audios;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.tags = const Value.absent(),
    this.hasPhoto = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photos = const Value.absent(),
    this.videos = const Value.absent(),
    this.audios = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String body,
    required DateTime date,
    this.mood = const Value.absent(),
    this.tags = const Value.absent(),
    this.hasPhoto = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photos = const Value.absent(),
    this.videos = const Value.absent(),
    this.audios = const Value.absent(),
  }) : title = Value(title),
       body = Value(body),
       date = Value(date);
  static Insertable<DiaryEntryRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? date,
    Expression<int>? mood,
    Expression<String>? tags,
    Expression<bool>? hasPhoto,
    Expression<String>? photoPath,
    Expression<String>? photos,
    Expression<String>? videos,
    Expression<String>? audios,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (tags != null) 'tags': tags,
      if (hasPhoto != null) 'has_photo': hasPhoto,
      if (photoPath != null) 'photo_path': photoPath,
      if (photos != null) 'photos': photos,
      if (videos != null) 'videos': videos,
      if (audios != null) 'audios': audios,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? date,
    Value<int?>? mood,
    Value<String>? tags,
    Value<bool>? hasPhoto,
    Value<String?>? photoPath,
    Value<String>? photos,
    Value<String>? videos,
    Value<String>? audios,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      photoPath: photoPath ?? this.photoPath,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      audios: audios ?? this.audios,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (hasPhoto.present) {
      map['has_photo'] = Variable<bool>(hasPhoto.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photos.present) {
      map['photos'] = Variable<String>(photos.value);
    }
    if (videos.present) {
      map['videos'] = Variable<String>(videos.value);
    }
    if (audios.present) {
      map['audios'] = Variable<String>(audios.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('hasPhoto: $hasPhoto, ')
          ..write('photoPath: $photoPath, ')
          ..write('photos: $photos, ')
          ..write('videos: $videos, ')
          ..write('audios: $audios')
          ..write(')'))
        .toString();
  }
}

class $DayLogsTable extends DayLogs with TableInfo<$DayLogsTable, DayLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _libidoMeta = const VerificationMeta('libido');
  @override
  late final GeneratedColumn<double> libido = GeneratedColumn<double>(
    'libido',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<double> energy = GeneratedColumn<double>(
    'energy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPeriodMeta = const VerificationMeta(
    'isPeriod',
  );
  @override
  late final GeneratedColumn<bool> isPeriod = GeneratedColumn<bool>(
    'is_period',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_period" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    mood,
    libido,
    energy,
    isPeriod,
    symptoms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('libido')) {
      context.handle(
        _libidoMeta,
        libido.isAcceptableOrUnknown(data['libido']!, _libidoMeta),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('is_period')) {
      context.handle(
        _isPeriodMeta,
        isPeriod.isAcceptableOrUnknown(data['is_period']!, _isPeriodMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DayLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLogRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      libido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}libido'],
      ),
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy'],
      ),
      isPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_period'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
    );
  }

  @override
  $DayLogsTable createAlias(String alias) {
    return $DayLogsTable(attachedDatabase, alias);
  }
}

class DayLogRow extends DataClass implements Insertable<DayLogRow> {
  /// Ключ 'YYYY-MM-DD' — избягва часови зони и улеснява заявки по месец.
  final String date;
  final int? mood;
  final double? libido;
  final double? energy;
  final bool isPeriod;

  /// JSON списък от симптоми, напр. `["ПМС","Главоболие"]`.
  final String symptoms;
  const DayLogRow({
    required this.date,
    this.mood,
    this.libido,
    this.energy,
    required this.isPeriod,
    required this.symptoms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    if (!nullToAbsent || libido != null) {
      map['libido'] = Variable<double>(libido);
    }
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<double>(energy);
    }
    map['is_period'] = Variable<bool>(isPeriod);
    map['symptoms'] = Variable<String>(symptoms);
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      date: Value(date),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      libido: libido == null && nullToAbsent
          ? const Value.absent()
          : Value(libido),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      isPeriod: Value(isPeriod),
      symptoms: Value(symptoms),
    );
  }

  factory DayLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLogRow(
      date: serializer.fromJson<String>(json['date']),
      mood: serializer.fromJson<int?>(json['mood']),
      libido: serializer.fromJson<double?>(json['libido']),
      energy: serializer.fromJson<double?>(json['energy']),
      isPeriod: serializer.fromJson<bool>(json['isPeriod']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'mood': serializer.toJson<int?>(mood),
      'libido': serializer.toJson<double?>(libido),
      'energy': serializer.toJson<double?>(energy),
      'isPeriod': serializer.toJson<bool>(isPeriod),
      'symptoms': serializer.toJson<String>(symptoms),
    };
  }

  DayLogRow copyWith({
    String? date,
    Value<int?> mood = const Value.absent(),
    Value<double?> libido = const Value.absent(),
    Value<double?> energy = const Value.absent(),
    bool? isPeriod,
    String? symptoms,
  }) => DayLogRow(
    date: date ?? this.date,
    mood: mood.present ? mood.value : this.mood,
    libido: libido.present ? libido.value : this.libido,
    energy: energy.present ? energy.value : this.energy,
    isPeriod: isPeriod ?? this.isPeriod,
    symptoms: symptoms ?? this.symptoms,
  );
  DayLogRow copyWithCompanion(DayLogsCompanion data) {
    return DayLogRow(
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      libido: data.libido.present ? data.libido.value : this.libido,
      energy: data.energy.present ? data.energy.value : this.energy,
      isPeriod: data.isPeriod.present ? data.isPeriod.value : this.isPeriod,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLogRow(')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('libido: $libido, ')
          ..write('energy: $energy, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('symptoms: $symptoms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, mood, libido, energy, isPeriod, symptoms);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLogRow &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.libido == this.libido &&
          other.energy == this.energy &&
          other.isPeriod == this.isPeriod &&
          other.symptoms == this.symptoms);
}

class DayLogsCompanion extends UpdateCompanion<DayLogRow> {
  final Value<String> date;
  final Value<int?> mood;
  final Value<double?> libido;
  final Value<double?> energy;
  final Value<bool> isPeriod;
  final Value<String> symptoms;
  final Value<int> rowid;
  const DayLogsCompanion({
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.libido = const Value.absent(),
    this.energy = const Value.absent(),
    this.isPeriod = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayLogsCompanion.insert({
    required String date,
    this.mood = const Value.absent(),
    this.libido = const Value.absent(),
    this.energy = const Value.absent(),
    this.isPeriod = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DayLogRow> custom({
    Expression<String>? date,
    Expression<int>? mood,
    Expression<double>? libido,
    Expression<double>? energy,
    Expression<bool>? isPeriod,
    Expression<String>? symptoms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (libido != null) 'libido': libido,
      if (energy != null) 'energy': energy,
      if (isPeriod != null) 'is_period': isPeriod,
      if (symptoms != null) 'symptoms': symptoms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogsCompanion copyWith({
    Value<String>? date,
    Value<int?>? mood,
    Value<double?>? libido,
    Value<double?>? energy,
    Value<bool>? isPeriod,
    Value<String>? symptoms,
    Value<int>? rowid,
  }) {
    return DayLogsCompanion(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      libido: libido ?? this.libido,
      energy: energy ?? this.energy,
      isPeriod: isPeriod ?? this.isPeriod,
      symptoms: symptoms ?? this.symptoms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (libido.present) {
      map['libido'] = Variable<double>(libido.value);
    }
    if (energy.present) {
      map['energy'] = Variable<double>(energy.value);
    }
    if (isPeriod.present) {
      map['is_period'] = Variable<bool>(isPeriod.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogsCompanion(')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('libido: $libido, ')
          ..write('energy: $energy, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('symptoms: $symptoms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntimateMomentsTable extends IntimateMoments
    with TableInfo<$IntimateMomentsTable, IntimateMomentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntimateMomentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arousalMeta = const VerificationMeta(
    'arousal',
  );
  @override
  late final GeneratedColumn<double> arousal = GeneratedColumn<double>(
    'arousal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.6),
  );
  static const VerificationMeta _orgasmsMeta = const VerificationMeta(
    'orgasms',
  );
  @override
  late final GeneratedColumn<int> orgasms = GeneratedColumn<int>(
    'orgasms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _positionsMeta = const VerificationMeta(
    'positions',
  );
  @override
  late final GeneratedColumn<String> positions = GeneratedColumn<String>(
    'positions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    arousal,
    orgasms,
    positions,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intimate_moments';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntimateMomentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('arousal')) {
      context.handle(
        _arousalMeta,
        arousal.isAcceptableOrUnknown(data['arousal']!, _arousalMeta),
      );
    }
    if (data.containsKey('orgasms')) {
      context.handle(
        _orgasmsMeta,
        orgasms.isAcceptableOrUnknown(data['orgasms']!, _orgasmsMeta),
      );
    }
    if (data.containsKey('positions')) {
      context.handle(
        _positionsMeta,
        positions.isAcceptableOrUnknown(data['positions']!, _positionsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntimateMomentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntimateMomentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      arousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal'],
      )!,
      orgasms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orgasms'],
      )!,
      positions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}positions'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $IntimateMomentsTable createAlias(String alias) {
    return $IntimateMomentsTable(attachedDatabase, alias);
  }
}

class IntimateMomentRow extends DataClass
    implements Insertable<IntimateMomentRow> {
  final int id;
  final String date;
  final double arousal;
  final int orgasms;

  /// JSON списък от пози.
  final String positions;
  final String note;
  const IntimateMomentRow({
    required this.id,
    required this.date,
    required this.arousal,
    required this.orgasms,
    required this.positions,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['arousal'] = Variable<double>(arousal);
    map['orgasms'] = Variable<int>(orgasms);
    map['positions'] = Variable<String>(positions);
    map['note'] = Variable<String>(note);
    return map;
  }

  IntimateMomentsCompanion toCompanion(bool nullToAbsent) {
    return IntimateMomentsCompanion(
      id: Value(id),
      date: Value(date),
      arousal: Value(arousal),
      orgasms: Value(orgasms),
      positions: Value(positions),
      note: Value(note),
    );
  }

  factory IntimateMomentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntimateMomentRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      arousal: serializer.fromJson<double>(json['arousal']),
      orgasms: serializer.fromJson<int>(json['orgasms']),
      positions: serializer.fromJson<String>(json['positions']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'arousal': serializer.toJson<double>(arousal),
      'orgasms': serializer.toJson<int>(orgasms),
      'positions': serializer.toJson<String>(positions),
      'note': serializer.toJson<String>(note),
    };
  }

  IntimateMomentRow copyWith({
    int? id,
    String? date,
    double? arousal,
    int? orgasms,
    String? positions,
    String? note,
  }) => IntimateMomentRow(
    id: id ?? this.id,
    date: date ?? this.date,
    arousal: arousal ?? this.arousal,
    orgasms: orgasms ?? this.orgasms,
    positions: positions ?? this.positions,
    note: note ?? this.note,
  );
  IntimateMomentRow copyWithCompanion(IntimateMomentsCompanion data) {
    return IntimateMomentRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      arousal: data.arousal.present ? data.arousal.value : this.arousal,
      orgasms: data.orgasms.present ? data.orgasms.value : this.orgasms,
      positions: data.positions.present ? data.positions.value : this.positions,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntimateMomentRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('arousal: $arousal, ')
          ..write('orgasms: $orgasms, ')
          ..write('positions: $positions, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, arousal, orgasms, positions, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntimateMomentRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.arousal == this.arousal &&
          other.orgasms == this.orgasms &&
          other.positions == this.positions &&
          other.note == this.note);
}

class IntimateMomentsCompanion extends UpdateCompanion<IntimateMomentRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<double> arousal;
  final Value<int> orgasms;
  final Value<String> positions;
  final Value<String> note;
  const IntimateMomentsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.arousal = const Value.absent(),
    this.orgasms = const Value.absent(),
    this.positions = const Value.absent(),
    this.note = const Value.absent(),
  });
  IntimateMomentsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.arousal = const Value.absent(),
    this.orgasms = const Value.absent(),
    this.positions = const Value.absent(),
    this.note = const Value.absent(),
  }) : date = Value(date);
  static Insertable<IntimateMomentRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<double>? arousal,
    Expression<int>? orgasms,
    Expression<String>? positions,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (arousal != null) 'arousal': arousal,
      if (orgasms != null) 'orgasms': orgasms,
      if (positions != null) 'positions': positions,
      if (note != null) 'note': note,
    });
  }

  IntimateMomentsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<double>? arousal,
    Value<int>? orgasms,
    Value<String>? positions,
    Value<String>? note,
  }) {
    return IntimateMomentsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      arousal: arousal ?? this.arousal,
      orgasms: orgasms ?? this.orgasms,
      positions: positions ?? this.positions,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (arousal.present) {
      map['arousal'] = Variable<double>(arousal.value);
    }
    if (orgasms.present) {
      map['orgasms'] = Variable<int>(orgasms.value);
    }
    if (positions.present) {
      map['positions'] = Variable<String>(positions.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntimateMomentsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('arousal: $arousal, ')
          ..write('orgasms: $orgasms, ')
          ..write('positions: $positions, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CyclePrefsTable extends CyclePrefs
    with TableInfo<$CyclePrefsTable, CyclePrefsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclePrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleLengthMeta = const VerificationMeta(
    'cycleLength',
  );
  @override
  late final GeneratedColumn<int> cycleLength = GeneratedColumn<int>(
    'cycle_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _periodLengthMeta = const VerificationMeta(
    'periodLength',
  );
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
    'period_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _notifyPeriodMeta = const VerificationMeta(
    'notifyPeriod',
  );
  @override
  late final GeneratedColumn<bool> notifyPeriod = GeneratedColumn<bool>(
    'notify_period',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_period" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyOvulationMeta = const VerificationMeta(
    'notifyOvulation',
  );
  @override
  late final GeneratedColumn<bool> notifyOvulation = GeneratedColumn<bool>(
    'notify_ovulation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_ovulation" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastPeriodStartMeta = const VerificationMeta(
    'lastPeriodStart',
  );
  @override
  late final GeneratedColumn<DateTime> lastPeriodStart =
      GeneratedColumn<DateTime>(
        'last_period_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleLength,
    periodLength,
    notifyPeriod,
    notifyOvulation,
    lastPeriodStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CyclePrefsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_length')) {
      context.handle(
        _cycleLengthMeta,
        cycleLength.isAcceptableOrUnknown(
          data['cycle_length']!,
          _cycleLengthMeta,
        ),
      );
    }
    if (data.containsKey('period_length')) {
      context.handle(
        _periodLengthMeta,
        periodLength.isAcceptableOrUnknown(
          data['period_length']!,
          _periodLengthMeta,
        ),
      );
    }
    if (data.containsKey('notify_period')) {
      context.handle(
        _notifyPeriodMeta,
        notifyPeriod.isAcceptableOrUnknown(
          data['notify_period']!,
          _notifyPeriodMeta,
        ),
      );
    }
    if (data.containsKey('notify_ovulation')) {
      context.handle(
        _notifyOvulationMeta,
        notifyOvulation.isAcceptableOrUnknown(
          data['notify_ovulation']!,
          _notifyOvulationMeta,
        ),
      );
    }
    if (data.containsKey('last_period_start')) {
      context.handle(
        _lastPeriodStartMeta,
        lastPeriodStart.isAcceptableOrUnknown(
          data['last_period_start']!,
          _lastPeriodStartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclePrefsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclePrefsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length'],
      )!,
      periodLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_length'],
      )!,
      notifyPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_period'],
      )!,
      notifyOvulation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_ovulation'],
      )!,
      lastPeriodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_period_start'],
      ),
    );
  }

  @override
  $CyclePrefsTable createAlias(String alias) {
    return $CyclePrefsTable(attachedDatabase, alias);
  }
}

class CyclePrefsRow extends DataClass implements Insertable<CyclePrefsRow> {
  final int id;
  final int cycleLength;
  final int periodLength;
  final bool notifyPeriod;
  final bool notifyOvulation;
  final DateTime? lastPeriodStart;
  const CyclePrefsRow({
    required this.id,
    required this.cycleLength,
    required this.periodLength,
    required this.notifyPeriod,
    required this.notifyOvulation,
    this.lastPeriodStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_length'] = Variable<int>(cycleLength);
    map['period_length'] = Variable<int>(periodLength);
    map['notify_period'] = Variable<bool>(notifyPeriod);
    map['notify_ovulation'] = Variable<bool>(notifyOvulation);
    if (!nullToAbsent || lastPeriodStart != null) {
      map['last_period_start'] = Variable<DateTime>(lastPeriodStart);
    }
    return map;
  }

  CyclePrefsCompanion toCompanion(bool nullToAbsent) {
    return CyclePrefsCompanion(
      id: Value(id),
      cycleLength: Value(cycleLength),
      periodLength: Value(periodLength),
      notifyPeriod: Value(notifyPeriod),
      notifyOvulation: Value(notifyOvulation),
      lastPeriodStart: lastPeriodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPeriodStart),
    );
  }

  factory CyclePrefsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclePrefsRow(
      id: serializer.fromJson<int>(json['id']),
      cycleLength: serializer.fromJson<int>(json['cycleLength']),
      periodLength: serializer.fromJson<int>(json['periodLength']),
      notifyPeriod: serializer.fromJson<bool>(json['notifyPeriod']),
      notifyOvulation: serializer.fromJson<bool>(json['notifyOvulation']),
      lastPeriodStart: serializer.fromJson<DateTime?>(json['lastPeriodStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleLength': serializer.toJson<int>(cycleLength),
      'periodLength': serializer.toJson<int>(periodLength),
      'notifyPeriod': serializer.toJson<bool>(notifyPeriod),
      'notifyOvulation': serializer.toJson<bool>(notifyOvulation),
      'lastPeriodStart': serializer.toJson<DateTime?>(lastPeriodStart),
    };
  }

  CyclePrefsRow copyWith({
    int? id,
    int? cycleLength,
    int? periodLength,
    bool? notifyPeriod,
    bool? notifyOvulation,
    Value<DateTime?> lastPeriodStart = const Value.absent(),
  }) => CyclePrefsRow(
    id: id ?? this.id,
    cycleLength: cycleLength ?? this.cycleLength,
    periodLength: periodLength ?? this.periodLength,
    notifyPeriod: notifyPeriod ?? this.notifyPeriod,
    notifyOvulation: notifyOvulation ?? this.notifyOvulation,
    lastPeriodStart: lastPeriodStart.present
        ? lastPeriodStart.value
        : this.lastPeriodStart,
  );
  CyclePrefsRow copyWithCompanion(CyclePrefsCompanion data) {
    return CyclePrefsRow(
      id: data.id.present ? data.id.value : this.id,
      cycleLength: data.cycleLength.present
          ? data.cycleLength.value
          : this.cycleLength,
      periodLength: data.periodLength.present
          ? data.periodLength.value
          : this.periodLength,
      notifyPeriod: data.notifyPeriod.present
          ? data.notifyPeriod.value
          : this.notifyPeriod,
      notifyOvulation: data.notifyOvulation.present
          ? data.notifyOvulation.value
          : this.notifyOvulation,
      lastPeriodStart: data.lastPeriodStart.present
          ? data.lastPeriodStart.value
          : this.lastPeriodStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclePrefsRow(')
          ..write('id: $id, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength, ')
          ..write('notifyPeriod: $notifyPeriod, ')
          ..write('notifyOvulation: $notifyOvulation, ')
          ..write('lastPeriodStart: $lastPeriodStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleLength,
    periodLength,
    notifyPeriod,
    notifyOvulation,
    lastPeriodStart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclePrefsRow &&
          other.id == this.id &&
          other.cycleLength == this.cycleLength &&
          other.periodLength == this.periodLength &&
          other.notifyPeriod == this.notifyPeriod &&
          other.notifyOvulation == this.notifyOvulation &&
          other.lastPeriodStart == this.lastPeriodStart);
}

class CyclePrefsCompanion extends UpdateCompanion<CyclePrefsRow> {
  final Value<int> id;
  final Value<int> cycleLength;
  final Value<int> periodLength;
  final Value<bool> notifyPeriod;
  final Value<bool> notifyOvulation;
  final Value<DateTime?> lastPeriodStart;
  const CyclePrefsCompanion({
    this.id = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.notifyPeriod = const Value.absent(),
    this.notifyOvulation = const Value.absent(),
    this.lastPeriodStart = const Value.absent(),
  });
  CyclePrefsCompanion.insert({
    this.id = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.notifyPeriod = const Value.absent(),
    this.notifyOvulation = const Value.absent(),
    this.lastPeriodStart = const Value.absent(),
  });
  static Insertable<CyclePrefsRow> custom({
    Expression<int>? id,
    Expression<int>? cycleLength,
    Expression<int>? periodLength,
    Expression<bool>? notifyPeriod,
    Expression<bool>? notifyOvulation,
    Expression<DateTime>? lastPeriodStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleLength != null) 'cycle_length': cycleLength,
      if (periodLength != null) 'period_length': periodLength,
      if (notifyPeriod != null) 'notify_period': notifyPeriod,
      if (notifyOvulation != null) 'notify_ovulation': notifyOvulation,
      if (lastPeriodStart != null) 'last_period_start': lastPeriodStart,
    });
  }

  CyclePrefsCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleLength,
    Value<int>? periodLength,
    Value<bool>? notifyPeriod,
    Value<bool>? notifyOvulation,
    Value<DateTime?>? lastPeriodStart,
  }) {
    return CyclePrefsCompanion(
      id: id ?? this.id,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notifyPeriod: notifyPeriod ?? this.notifyPeriod,
      notifyOvulation: notifyOvulation ?? this.notifyOvulation,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleLength.present) {
      map['cycle_length'] = Variable<int>(cycleLength.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (notifyPeriod.present) {
      map['notify_period'] = Variable<bool>(notifyPeriod.value);
    }
    if (notifyOvulation.present) {
      map['notify_ovulation'] = Variable<bool>(notifyOvulation.value);
    }
    if (lastPeriodStart.present) {
      map['last_period_start'] = Variable<DateTime>(lastPeriodStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclePrefsCompanion(')
          ..write('id: $id, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength, ')
          ..write('notifyPeriod: $notifyPeriod, ')
          ..write('notifyOvulation: $notifyOvulation, ')
          ..write('lastPeriodStart: $lastPeriodStart')
          ..write(')'))
        .toString();
  }
}

abstract class _$IntimaDatabase extends GeneratedDatabase {
  _$IntimaDatabase(QueryExecutor e) : super(e);
  $IntimaDatabaseManager get managers => $IntimaDatabaseManager(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  late final $IntimateMomentsTable intimateMoments = $IntimateMomentsTable(
    this,
  );
  late final $CyclePrefsTable cyclePrefs = $CyclePrefsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    diaryEntries,
    dayLogs,
    intimateMoments,
    cyclePrefs,
  ];
}

typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required String title,
      required String body,
      required DateTime date,
      Value<int?> mood,
      Value<String> tags,
      Value<bool> hasPhoto,
      Value<String?> photoPath,
      Value<String> photos,
      Value<String> videos,
      Value<String> audios,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> body,
      Value<DateTime> date,
      Value<int?> mood,
      Value<String> tags,
      Value<bool> hasPhoto,
      Value<String?> photoPath,
      Value<String> photos,
      Value<String> videos,
      Value<String> audios,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$IntimaDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photos => $composableBuilder(
    column: $table.photos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videos => $composableBuilder(
    column: $table.videos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audios => $composableBuilder(
    column: $table.audios,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$IntimaDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photos => $composableBuilder(
    column: $table.photos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videos => $composableBuilder(
    column: $table.videos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audios => $composableBuilder(
    column: $table.audios,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$IntimaDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get hasPhoto =>
      $composableBuilder(column: $table.hasPhoto, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get photos =>
      $composableBuilder(column: $table.photos, builder: (column) => column);

  GeneratedColumn<String> get videos =>
      $composableBuilder(column: $table.videos, builder: (column) => column);

  GeneratedColumn<String> get audios =>
      $composableBuilder(column: $table.audios, builder: (column) => column);
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$IntimaDatabase,
          $DiaryEntriesTable,
          DiaryEntryRow,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            DiaryEntryRow,
            BaseReferences<_$IntimaDatabase, $DiaryEntriesTable, DiaryEntryRow>,
          ),
          DiaryEntryRow,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$IntimaDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> hasPhoto = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> photos = const Value.absent(),
                Value<String> videos = const Value.absent(),
                Value<String> audios = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                title: title,
                body: body,
                date: date,
                mood: mood,
                tags: tags,
                hasPhoto: hasPhoto,
                photoPath: photoPath,
                photos: photos,
                videos: videos,
                audios: audios,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String body,
                required DateTime date,
                Value<int?> mood = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> hasPhoto = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> photos = const Value.absent(),
                Value<String> videos = const Value.absent(),
                Value<String> audios = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                title: title,
                body: body,
                date: date,
                mood: mood,
                tags: tags,
                hasPhoto: hasPhoto,
                photoPath: photoPath,
                photos: photos,
                videos: videos,
                audios: audios,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$IntimaDatabase,
      $DiaryEntriesTable,
      DiaryEntryRow,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        DiaryEntryRow,
        BaseReferences<_$IntimaDatabase, $DiaryEntriesTable, DiaryEntryRow>,
      ),
      DiaryEntryRow,
      PrefetchHooks Function()
    >;
typedef $$DayLogsTableCreateCompanionBuilder =
    DayLogsCompanion Function({
      required String date,
      Value<int?> mood,
      Value<double?> libido,
      Value<double?> energy,
      Value<bool> isPeriod,
      Value<String> symptoms,
      Value<int> rowid,
    });
typedef $$DayLogsTableUpdateCompanionBuilder =
    DayLogsCompanion Function({
      Value<String> date,
      Value<int?> mood,
      Value<double?> libido,
      Value<double?> energy,
      Value<bool> isPeriod,
      Value<String> symptoms,
      Value<int> rowid,
    });

class $$DayLogsTableFilterComposer
    extends Composer<_$IntimaDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get libido => $composableBuilder(
    column: $table.libido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPeriod => $composableBuilder(
    column: $table.isPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends Composer<_$IntimaDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get libido => $composableBuilder(
    column: $table.libido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPeriod => $composableBuilder(
    column: $table.isPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends Composer<_$IntimaDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<double> get libido =>
      $composableBuilder(column: $table.libido, builder: (column) => column);

  GeneratedColumn<double> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<bool> get isPeriod =>
      $composableBuilder(column: $table.isPeriod, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        RootTableManager<
          _$IntimaDatabase,
          $DayLogsTable,
          DayLogRow,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (
            DayLogRow,
            BaseReferences<_$IntimaDatabase, $DayLogsTable, DayLogRow>,
          ),
          DayLogRow,
          PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$IntimaDatabase db, $DayLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<double?> libido = const Value.absent(),
                Value<double?> energy = const Value.absent(),
                Value<bool> isPeriod = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion(
                date: date,
                mood: mood,
                libido: libido,
                energy: energy,
                isPeriod: isPeriod,
                symptoms: symptoms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int?> mood = const Value.absent(),
                Value<double?> libido = const Value.absent(),
                Value<double?> energy = const Value.absent(),
                Value<bool> isPeriod = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion.insert(
                date: date,
                mood: mood,
                libido: libido,
                energy: energy,
                isPeriod: isPeriod,
                symptoms: symptoms,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$IntimaDatabase,
      $DayLogsTable,
      DayLogRow,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLogRow, BaseReferences<_$IntimaDatabase, $DayLogsTable, DayLogRow>),
      DayLogRow,
      PrefetchHooks Function()
    >;
typedef $$IntimateMomentsTableCreateCompanionBuilder =
    IntimateMomentsCompanion Function({
      Value<int> id,
      required String date,
      Value<double> arousal,
      Value<int> orgasms,
      Value<String> positions,
      Value<String> note,
    });
typedef $$IntimateMomentsTableUpdateCompanionBuilder =
    IntimateMomentsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<double> arousal,
      Value<int> orgasms,
      Value<String> positions,
      Value<String> note,
    });

class $$IntimateMomentsTableFilterComposer
    extends Composer<_$IntimaDatabase, $IntimateMomentsTable> {
  $$IntimateMomentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orgasms => $composableBuilder(
    column: $table.orgasms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positions => $composableBuilder(
    column: $table.positions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IntimateMomentsTableOrderingComposer
    extends Composer<_$IntimaDatabase, $IntimateMomentsTable> {
  $$IntimateMomentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orgasms => $composableBuilder(
    column: $table.orgasms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positions => $composableBuilder(
    column: $table.positions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IntimateMomentsTableAnnotationComposer
    extends Composer<_$IntimaDatabase, $IntimateMomentsTable> {
  $$IntimateMomentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get arousal =>
      $composableBuilder(column: $table.arousal, builder: (column) => column);

  GeneratedColumn<int> get orgasms =>
      $composableBuilder(column: $table.orgasms, builder: (column) => column);

  GeneratedColumn<String> get positions =>
      $composableBuilder(column: $table.positions, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$IntimateMomentsTableTableManager
    extends
        RootTableManager<
          _$IntimaDatabase,
          $IntimateMomentsTable,
          IntimateMomentRow,
          $$IntimateMomentsTableFilterComposer,
          $$IntimateMomentsTableOrderingComposer,
          $$IntimateMomentsTableAnnotationComposer,
          $$IntimateMomentsTableCreateCompanionBuilder,
          $$IntimateMomentsTableUpdateCompanionBuilder,
          (
            IntimateMomentRow,
            BaseReferences<
              _$IntimaDatabase,
              $IntimateMomentsTable,
              IntimateMomentRow
            >,
          ),
          IntimateMomentRow,
          PrefetchHooks Function()
        > {
  $$IntimateMomentsTableTableManager(
    _$IntimaDatabase db,
    $IntimateMomentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntimateMomentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntimateMomentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntimateMomentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double> arousal = const Value.absent(),
                Value<int> orgasms = const Value.absent(),
                Value<String> positions = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => IntimateMomentsCompanion(
                id: id,
                date: date,
                arousal: arousal,
                orgasms: orgasms,
                positions: positions,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<double> arousal = const Value.absent(),
                Value<int> orgasms = const Value.absent(),
                Value<String> positions = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => IntimateMomentsCompanion.insert(
                id: id,
                date: date,
                arousal: arousal,
                orgasms: orgasms,
                positions: positions,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IntimateMomentsTableProcessedTableManager =
    ProcessedTableManager<
      _$IntimaDatabase,
      $IntimateMomentsTable,
      IntimateMomentRow,
      $$IntimateMomentsTableFilterComposer,
      $$IntimateMomentsTableOrderingComposer,
      $$IntimateMomentsTableAnnotationComposer,
      $$IntimateMomentsTableCreateCompanionBuilder,
      $$IntimateMomentsTableUpdateCompanionBuilder,
      (
        IntimateMomentRow,
        BaseReferences<
          _$IntimaDatabase,
          $IntimateMomentsTable,
          IntimateMomentRow
        >,
      ),
      IntimateMomentRow,
      PrefetchHooks Function()
    >;
typedef $$CyclePrefsTableCreateCompanionBuilder =
    CyclePrefsCompanion Function({
      Value<int> id,
      Value<int> cycleLength,
      Value<int> periodLength,
      Value<bool> notifyPeriod,
      Value<bool> notifyOvulation,
      Value<DateTime?> lastPeriodStart,
    });
typedef $$CyclePrefsTableUpdateCompanionBuilder =
    CyclePrefsCompanion Function({
      Value<int> id,
      Value<int> cycleLength,
      Value<int> periodLength,
      Value<bool> notifyPeriod,
      Value<bool> notifyOvulation,
      Value<DateTime?> lastPeriodStart,
    });

class $$CyclePrefsTableFilterComposer
    extends Composer<_$IntimaDatabase, $CyclePrefsTable> {
  $$CyclePrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyPeriod => $composableBuilder(
    column: $table.notifyPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyOvulation => $composableBuilder(
    column: $table.notifyOvulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CyclePrefsTableOrderingComposer
    extends Composer<_$IntimaDatabase, $CyclePrefsTable> {
  $$CyclePrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyPeriod => $composableBuilder(
    column: $table.notifyPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyOvulation => $composableBuilder(
    column: $table.notifyOvulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CyclePrefsTableAnnotationComposer
    extends Composer<_$IntimaDatabase, $CyclePrefsTable> {
  $$CyclePrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyPeriod => $composableBuilder(
    column: $table.notifyPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyOvulation => $composableBuilder(
    column: $table.notifyOvulation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => column,
  );
}

class $$CyclePrefsTableTableManager
    extends
        RootTableManager<
          _$IntimaDatabase,
          $CyclePrefsTable,
          CyclePrefsRow,
          $$CyclePrefsTableFilterComposer,
          $$CyclePrefsTableOrderingComposer,
          $$CyclePrefsTableAnnotationComposer,
          $$CyclePrefsTableCreateCompanionBuilder,
          $$CyclePrefsTableUpdateCompanionBuilder,
          (
            CyclePrefsRow,
            BaseReferences<_$IntimaDatabase, $CyclePrefsTable, CyclePrefsRow>,
          ),
          CyclePrefsRow,
          PrefetchHooks Function()
        > {
  $$CyclePrefsTableTableManager(_$IntimaDatabase db, $CyclePrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclePrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclePrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclePrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                Value<int> periodLength = const Value.absent(),
                Value<bool> notifyPeriod = const Value.absent(),
                Value<bool> notifyOvulation = const Value.absent(),
                Value<DateTime?> lastPeriodStart = const Value.absent(),
              }) => CyclePrefsCompanion(
                id: id,
                cycleLength: cycleLength,
                periodLength: periodLength,
                notifyPeriod: notifyPeriod,
                notifyOvulation: notifyOvulation,
                lastPeriodStart: lastPeriodStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                Value<int> periodLength = const Value.absent(),
                Value<bool> notifyPeriod = const Value.absent(),
                Value<bool> notifyOvulation = const Value.absent(),
                Value<DateTime?> lastPeriodStart = const Value.absent(),
              }) => CyclePrefsCompanion.insert(
                id: id,
                cycleLength: cycleLength,
                periodLength: periodLength,
                notifyPeriod: notifyPeriod,
                notifyOvulation: notifyOvulation,
                lastPeriodStart: lastPeriodStart,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CyclePrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$IntimaDatabase,
      $CyclePrefsTable,
      CyclePrefsRow,
      $$CyclePrefsTableFilterComposer,
      $$CyclePrefsTableOrderingComposer,
      $$CyclePrefsTableAnnotationComposer,
      $$CyclePrefsTableCreateCompanionBuilder,
      $$CyclePrefsTableUpdateCompanionBuilder,
      (
        CyclePrefsRow,
        BaseReferences<_$IntimaDatabase, $CyclePrefsTable, CyclePrefsRow>,
      ),
      CyclePrefsRow,
      PrefetchHooks Function()
    >;

class $IntimaDatabaseManager {
  final _$IntimaDatabase _db;
  $IntimaDatabaseManager(this._db);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
  $$IntimateMomentsTableTableManager get intimateMoments =>
      $$IntimateMomentsTableTableManager(_db, _db.intimateMoments);
  $$CyclePrefsTableTableManager get cyclePrefs =>
      $$CyclePrefsTableTableManager(_db, _db.cyclePrefs);
}
