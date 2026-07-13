// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RunsTable extends Runs with TableInfo<$RunsTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playedAtMsMeta = const VerificationMeta(
    'playedAtMs',
  );
  @override
  late final GeneratedColumn<int> playedAtMs = GeneratedColumn<int>(
    'played_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equationsMeta = const VerificationMeta(
    'equations',
  );
  @override
  late final GeneratedColumn<int> equations = GeneratedColumn<int>(
    'equations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestComboMeta = const VerificationMeta(
    'bestCombo',
  );
  @override
  late final GeneratedColumn<int> bestCombo = GeneratedColumn<int>(
    'best_combo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelReachedMeta = const VerificationMeta(
    'levelReached',
  );
  @override
  late final GeneratedColumn<int> levelReached = GeneratedColumn<int>(
    'level_reached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesetVersionMeta = const VerificationMeta(
    'rulesetVersion',
  );
  @override
  late final GeneratedColumn<String> rulesetVersion = GeneratedColumn<String>(
    'ruleset_version',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<String> seed = GeneratedColumn<String>(
    'seed',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<String> protocolVersion = GeneratedColumn<String>(
    'protocol_version',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mapCatalogVersionMeta = const VerificationMeta(
    'mapCatalogVersion',
  );
  @override
  late final GeneratedColumn<String> mapCatalogVersion =
      GeneratedColumn<String>(
        'map_catalog_version',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 32,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mapIdMeta = const VerificationMeta('mapId');
  @override
  late final GeneratedColumn<String> mapId = GeneratedColumn<String>(
    'map_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetsSolvedMeta = const VerificationMeta(
    'targetsSolved',
  );
  @override
  late final GeneratedColumn<int> targetsSolved = GeneratedColumn<int>(
    'targets_solved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playedAtMs,
    mode,
    score,
    equations,
    bestCombo,
    levelReached,
    durationMs,
    rulesetVersion,
    seed,
    protocolVersion,
    mapCatalogVersion,
    mapId,
    targetsSolved,
    rating,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Run> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('played_at_ms')) {
      context.handle(
        _playedAtMsMeta,
        playedAtMs.isAcceptableOrUnknown(
          data['played_at_ms']!,
          _playedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playedAtMsMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('equations')) {
      context.handle(
        _equationsMeta,
        equations.isAcceptableOrUnknown(data['equations']!, _equationsMeta),
      );
    } else if (isInserting) {
      context.missing(_equationsMeta);
    }
    if (data.containsKey('best_combo')) {
      context.handle(
        _bestComboMeta,
        bestCombo.isAcceptableOrUnknown(data['best_combo']!, _bestComboMeta),
      );
    } else if (isInserting) {
      context.missing(_bestComboMeta);
    }
    if (data.containsKey('level_reached')) {
      context.handle(
        _levelReachedMeta,
        levelReached.isAcceptableOrUnknown(
          data['level_reached']!,
          _levelReachedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_levelReachedMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('ruleset_version')) {
      context.handle(
        _rulesetVersionMeta,
        rulesetVersion.isAcceptableOrUnknown(
          data['ruleset_version']!,
          _rulesetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesetVersionMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    }
    if (data.containsKey('map_catalog_version')) {
      context.handle(
        _mapCatalogVersionMeta,
        mapCatalogVersion.isAcceptableOrUnknown(
          data['map_catalog_version']!,
          _mapCatalogVersionMeta,
        ),
      );
    }
    if (data.containsKey('map_id')) {
      context.handle(
        _mapIdMeta,
        mapId.isAcceptableOrUnknown(data['map_id']!, _mapIdMeta),
      );
    }
    if (data.containsKey('targets_solved')) {
      context.handle(
        _targetsSolvedMeta,
        targetsSolved.isAcceptableOrUnknown(
          data['targets_solved']!,
          _targetsSolvedMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}played_at_ms'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      equations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equations'],
      )!,
      bestCombo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_combo'],
      )!,
      levelReached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_reached'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      rulesetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruleset_version'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed'],
      )!,
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol_version'],
      ),
      mapCatalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_catalog_version'],
      ),
      mapId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_id'],
      ),
      targetsSolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}targets_solved'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class Run extends DataClass implements Insertable<Run> {
  final int id;

  /// Epoch milliseconds when the run finished.
  final int playedAtMs;

  /// 'normal' | 'ranked' | 'daily'.
  final String mode;
  final int score;
  final int equations;
  final int bestCombo;
  final int levelReached;
  final int durationMs;
  final String rulesetVersion;
  final String seed;

  /// Nullable for legacy v1 rows created before protocol-aware sessions.
  final String? protocolVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final int targetsSolved;

  /// Level rating (0..3); null for modes without ratings and for legacy rows.
  final int? rating;
  const Run({
    required this.id,
    required this.playedAtMs,
    required this.mode,
    required this.score,
    required this.equations,
    required this.bestCombo,
    required this.levelReached,
    required this.durationMs,
    required this.rulesetVersion,
    required this.seed,
    this.protocolVersion,
    this.mapCatalogVersion,
    this.mapId,
    required this.targetsSolved,
    this.rating,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['played_at_ms'] = Variable<int>(playedAtMs);
    map['mode'] = Variable<String>(mode);
    map['score'] = Variable<int>(score);
    map['equations'] = Variable<int>(equations);
    map['best_combo'] = Variable<int>(bestCombo);
    map['level_reached'] = Variable<int>(levelReached);
    map['duration_ms'] = Variable<int>(durationMs);
    map['ruleset_version'] = Variable<String>(rulesetVersion);
    map['seed'] = Variable<String>(seed);
    if (!nullToAbsent || protocolVersion != null) {
      map['protocol_version'] = Variable<String>(protocolVersion);
    }
    if (!nullToAbsent || mapCatalogVersion != null) {
      map['map_catalog_version'] = Variable<String>(mapCatalogVersion);
    }
    if (!nullToAbsent || mapId != null) {
      map['map_id'] = Variable<String>(mapId);
    }
    map['targets_solved'] = Variable<int>(targetsSolved);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      playedAtMs: Value(playedAtMs),
      mode: Value(mode),
      score: Value(score),
      equations: Value(equations),
      bestCombo: Value(bestCombo),
      levelReached: Value(levelReached),
      durationMs: Value(durationMs),
      rulesetVersion: Value(rulesetVersion),
      seed: Value(seed),
      protocolVersion: protocolVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(protocolVersion),
      mapCatalogVersion: mapCatalogVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(mapCatalogVersion),
      mapId: mapId == null && nullToAbsent
          ? const Value.absent()
          : Value(mapId),
      targetsSolved: Value(targetsSolved),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
    );
  }

  factory Run.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<int>(json['id']),
      playedAtMs: serializer.fromJson<int>(json['playedAtMs']),
      mode: serializer.fromJson<String>(json['mode']),
      score: serializer.fromJson<int>(json['score']),
      equations: serializer.fromJson<int>(json['equations']),
      bestCombo: serializer.fromJson<int>(json['bestCombo']),
      levelReached: serializer.fromJson<int>(json['levelReached']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      rulesetVersion: serializer.fromJson<String>(json['rulesetVersion']),
      seed: serializer.fromJson<String>(json['seed']),
      protocolVersion: serializer.fromJson<String?>(json['protocolVersion']),
      mapCatalogVersion: serializer.fromJson<String?>(
        json['mapCatalogVersion'],
      ),
      mapId: serializer.fromJson<String?>(json['mapId']),
      targetsSolved: serializer.fromJson<int>(json['targetsSolved']),
      rating: serializer.fromJson<int?>(json['rating']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playedAtMs': serializer.toJson<int>(playedAtMs),
      'mode': serializer.toJson<String>(mode),
      'score': serializer.toJson<int>(score),
      'equations': serializer.toJson<int>(equations),
      'bestCombo': serializer.toJson<int>(bestCombo),
      'levelReached': serializer.toJson<int>(levelReached),
      'durationMs': serializer.toJson<int>(durationMs),
      'rulesetVersion': serializer.toJson<String>(rulesetVersion),
      'seed': serializer.toJson<String>(seed),
      'protocolVersion': serializer.toJson<String?>(protocolVersion),
      'mapCatalogVersion': serializer.toJson<String?>(mapCatalogVersion),
      'mapId': serializer.toJson<String?>(mapId),
      'targetsSolved': serializer.toJson<int>(targetsSolved),
      'rating': serializer.toJson<int?>(rating),
    };
  }

  Run copyWith({
    int? id,
    int? playedAtMs,
    String? mode,
    int? score,
    int? equations,
    int? bestCombo,
    int? levelReached,
    int? durationMs,
    String? rulesetVersion,
    String? seed,
    Value<String?> protocolVersion = const Value.absent(),
    Value<String?> mapCatalogVersion = const Value.absent(),
    Value<String?> mapId = const Value.absent(),
    int? targetsSolved,
    Value<int?> rating = const Value.absent(),
  }) => Run(
    id: id ?? this.id,
    playedAtMs: playedAtMs ?? this.playedAtMs,
    mode: mode ?? this.mode,
    score: score ?? this.score,
    equations: equations ?? this.equations,
    bestCombo: bestCombo ?? this.bestCombo,
    levelReached: levelReached ?? this.levelReached,
    durationMs: durationMs ?? this.durationMs,
    rulesetVersion: rulesetVersion ?? this.rulesetVersion,
    seed: seed ?? this.seed,
    protocolVersion: protocolVersion.present
        ? protocolVersion.value
        : this.protocolVersion,
    mapCatalogVersion: mapCatalogVersion.present
        ? mapCatalogVersion.value
        : this.mapCatalogVersion,
    mapId: mapId.present ? mapId.value : this.mapId,
    targetsSolved: targetsSolved ?? this.targetsSolved,
    rating: rating.present ? rating.value : this.rating,
  );
  Run copyWithCompanion(RunsCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      playedAtMs: data.playedAtMs.present
          ? data.playedAtMs.value
          : this.playedAtMs,
      mode: data.mode.present ? data.mode.value : this.mode,
      score: data.score.present ? data.score.value : this.score,
      equations: data.equations.present ? data.equations.value : this.equations,
      bestCombo: data.bestCombo.present ? data.bestCombo.value : this.bestCombo,
      levelReached: data.levelReached.present
          ? data.levelReached.value
          : this.levelReached,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      rulesetVersion: data.rulesetVersion.present
          ? data.rulesetVersion.value
          : this.rulesetVersion,
      seed: data.seed.present ? data.seed.value : this.seed,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      mapCatalogVersion: data.mapCatalogVersion.present
          ? data.mapCatalogVersion.value
          : this.mapCatalogVersion,
      mapId: data.mapId.present ? data.mapId.value : this.mapId,
      targetsSolved: data.targetsSolved.present
          ? data.targetsSolved.value
          : this.targetsSolved,
      rating: data.rating.present ? data.rating.value : this.rating,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('playedAtMs: $playedAtMs, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('equations: $equations, ')
          ..write('bestCombo: $bestCombo, ')
          ..write('levelReached: $levelReached, ')
          ..write('durationMs: $durationMs, ')
          ..write('rulesetVersion: $rulesetVersion, ')
          ..write('seed: $seed, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('mapCatalogVersion: $mapCatalogVersion, ')
          ..write('mapId: $mapId, ')
          ..write('targetsSolved: $targetsSolved, ')
          ..write('rating: $rating')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playedAtMs,
    mode,
    score,
    equations,
    bestCombo,
    levelReached,
    durationMs,
    rulesetVersion,
    seed,
    protocolVersion,
    mapCatalogVersion,
    mapId,
    targetsSolved,
    rating,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.playedAtMs == this.playedAtMs &&
          other.mode == this.mode &&
          other.score == this.score &&
          other.equations == this.equations &&
          other.bestCombo == this.bestCombo &&
          other.levelReached == this.levelReached &&
          other.durationMs == this.durationMs &&
          other.rulesetVersion == this.rulesetVersion &&
          other.seed == this.seed &&
          other.protocolVersion == this.protocolVersion &&
          other.mapCatalogVersion == this.mapCatalogVersion &&
          other.mapId == this.mapId &&
          other.targetsSolved == this.targetsSolved &&
          other.rating == this.rating);
}

class RunsCompanion extends UpdateCompanion<Run> {
  final Value<int> id;
  final Value<int> playedAtMs;
  final Value<String> mode;
  final Value<int> score;
  final Value<int> equations;
  final Value<int> bestCombo;
  final Value<int> levelReached;
  final Value<int> durationMs;
  final Value<String> rulesetVersion;
  final Value<String> seed;
  final Value<String?> protocolVersion;
  final Value<String?> mapCatalogVersion;
  final Value<String?> mapId;
  final Value<int> targetsSolved;
  final Value<int?> rating;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.playedAtMs = const Value.absent(),
    this.mode = const Value.absent(),
    this.score = const Value.absent(),
    this.equations = const Value.absent(),
    this.bestCombo = const Value.absent(),
    this.levelReached = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.rulesetVersion = const Value.absent(),
    this.seed = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.mapCatalogVersion = const Value.absent(),
    this.mapId = const Value.absent(),
    this.targetsSolved = const Value.absent(),
    this.rating = const Value.absent(),
  });
  RunsCompanion.insert({
    this.id = const Value.absent(),
    required int playedAtMs,
    required String mode,
    required int score,
    required int equations,
    required int bestCombo,
    required int levelReached,
    required int durationMs,
    required String rulesetVersion,
    required String seed,
    this.protocolVersion = const Value.absent(),
    this.mapCatalogVersion = const Value.absent(),
    this.mapId = const Value.absent(),
    this.targetsSolved = const Value.absent(),
    this.rating = const Value.absent(),
  }) : playedAtMs = Value(playedAtMs),
       mode = Value(mode),
       score = Value(score),
       equations = Value(equations),
       bestCombo = Value(bestCombo),
       levelReached = Value(levelReached),
       durationMs = Value(durationMs),
       rulesetVersion = Value(rulesetVersion),
       seed = Value(seed);
  static Insertable<Run> custom({
    Expression<int>? id,
    Expression<int>? playedAtMs,
    Expression<String>? mode,
    Expression<int>? score,
    Expression<int>? equations,
    Expression<int>? bestCombo,
    Expression<int>? levelReached,
    Expression<int>? durationMs,
    Expression<String>? rulesetVersion,
    Expression<String>? seed,
    Expression<String>? protocolVersion,
    Expression<String>? mapCatalogVersion,
    Expression<String>? mapId,
    Expression<int>? targetsSolved,
    Expression<int>? rating,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playedAtMs != null) 'played_at_ms': playedAtMs,
      if (mode != null) 'mode': mode,
      if (score != null) 'score': score,
      if (equations != null) 'equations': equations,
      if (bestCombo != null) 'best_combo': bestCombo,
      if (levelReached != null) 'level_reached': levelReached,
      if (durationMs != null) 'duration_ms': durationMs,
      if (rulesetVersion != null) 'ruleset_version': rulesetVersion,
      if (seed != null) 'seed': seed,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (mapCatalogVersion != null) 'map_catalog_version': mapCatalogVersion,
      if (mapId != null) 'map_id': mapId,
      if (targetsSolved != null) 'targets_solved': targetsSolved,
      if (rating != null) 'rating': rating,
    });
  }

  RunsCompanion copyWith({
    Value<int>? id,
    Value<int>? playedAtMs,
    Value<String>? mode,
    Value<int>? score,
    Value<int>? equations,
    Value<int>? bestCombo,
    Value<int>? levelReached,
    Value<int>? durationMs,
    Value<String>? rulesetVersion,
    Value<String>? seed,
    Value<String?>? protocolVersion,
    Value<String?>? mapCatalogVersion,
    Value<String?>? mapId,
    Value<int>? targetsSolved,
    Value<int?>? rating,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      playedAtMs: playedAtMs ?? this.playedAtMs,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      equations: equations ?? this.equations,
      bestCombo: bestCombo ?? this.bestCombo,
      levelReached: levelReached ?? this.levelReached,
      durationMs: durationMs ?? this.durationMs,
      rulesetVersion: rulesetVersion ?? this.rulesetVersion,
      seed: seed ?? this.seed,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      mapCatalogVersion: mapCatalogVersion ?? this.mapCatalogVersion,
      mapId: mapId ?? this.mapId,
      targetsSolved: targetsSolved ?? this.targetsSolved,
      rating: rating ?? this.rating,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playedAtMs.present) {
      map['played_at_ms'] = Variable<int>(playedAtMs.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (equations.present) {
      map['equations'] = Variable<int>(equations.value);
    }
    if (bestCombo.present) {
      map['best_combo'] = Variable<int>(bestCombo.value);
    }
    if (levelReached.present) {
      map['level_reached'] = Variable<int>(levelReached.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (rulesetVersion.present) {
      map['ruleset_version'] = Variable<String>(rulesetVersion.value);
    }
    if (seed.present) {
      map['seed'] = Variable<String>(seed.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<String>(protocolVersion.value);
    }
    if (mapCatalogVersion.present) {
      map['map_catalog_version'] = Variable<String>(mapCatalogVersion.value);
    }
    if (mapId.present) {
      map['map_id'] = Variable<String>(mapId.value);
    }
    if (targetsSolved.present) {
      map['targets_solved'] = Variable<int>(targetsSolved.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('playedAtMs: $playedAtMs, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('equations: $equations, ')
          ..write('bestCombo: $bestCombo, ')
          ..write('levelReached: $levelReached, ')
          ..write('durationMs: $durationMs, ')
          ..write('rulesetVersion: $rulesetVersion, ')
          ..write('seed: $seed, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('mapCatalogVersion: $mapCatalogVersion, ')
          ..write('mapId: $mapId, ')
          ..write('targetsSolved: $targetsSolved, ')
          ..write('rating: $rating')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAt = GeneratedColumn<int>(
    'next_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 24,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    operationType,
    payloadVersion,
    payload,
    idempotencyKey,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadVersionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  OutboxItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItemRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxItemRow extends DataClass implements Insertable<OutboxItemRow> {
  final int localId;
  final String operationType;
  final int payloadVersion;

  /// The JSON request body (already mapped), stored as text.
  final String payload;
  final String idempotencyKey;

  /// Epoch ms the item was enqueued.
  final int createdAt;
  final int attemptCount;

  /// Epoch ms before which the item should not be retried (backoff); null = due now.
  final int? nextAttemptAt;
  final String? lastErrorCode;
  final String status;
  const OutboxItemRow({
    required this.localId,
    required this.operationType,
    required this.payloadVersion,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_version'] = Variable<int>(payloadVersion);
    map['payload'] = Variable<String>(payload);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<int>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      localId: Value(localId),
      operationType: Value(operationType),
      payloadVersion: Value(payloadVersion),
      payload: Value(payload),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      status: Value(status),
    );
  }

  factory OutboxItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItemRow(
      localId: serializer.fromJson<int>(json['localId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<int?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'payload': serializer.toJson<String>(payload),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<int>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<int?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'status': serializer.toJson<String>(status),
    };
  }

  OutboxItemRow copyWith({
    int? localId,
    String? operationType,
    int? payloadVersion,
    String? payload,
    String? idempotencyKey,
    int? createdAt,
    int? attemptCount,
    Value<int?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    String? status,
  }) => OutboxItemRow(
    localId: localId ?? this.localId,
    operationType: operationType ?? this.operationType,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    payload: payload ?? this.payload,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    status: status ?? this.status,
  );
  OutboxItemRow copyWithCompanion(OutboxCompanion data) {
    return OutboxItemRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemRow(')
          ..write('localId: $localId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    operationType,
    payloadVersion,
    payload,
    idempotencyKey,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItemRow &&
          other.localId == this.localId &&
          other.operationType == this.operationType &&
          other.payloadVersion == this.payloadVersion &&
          other.payload == this.payload &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.status == this.status);
}

class OutboxCompanion extends UpdateCompanion<OutboxItemRow> {
  final Value<int> localId;
  final Value<String> operationType;
  final Value<int> payloadVersion;
  final Value<String> payload;
  final Value<String> idempotencyKey;
  final Value<int> createdAt;
  final Value<int> attemptCount;
  final Value<int?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<String> status;
  const OutboxCompanion({
    this.localId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.status = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.localId = const Value.absent(),
    required String operationType,
    required int payloadVersion,
    required String payload,
    required String idempotencyKey,
    required int createdAt,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required String status,
  }) : operationType = Value(operationType),
       payloadVersion = Value(payloadVersion),
       payload = Value(payload),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt),
       status = Value(status);
  static Insertable<OutboxItemRow> custom({
    Expression<int>? localId,
    Expression<String>? operationType,
    Expression<int>? payloadVersion,
    Expression<String>? payload,
    Expression<String>? idempotencyKey,
    Expression<int>? createdAt,
    Expression<int>? attemptCount,
    Expression<int>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (payload != null) 'payload': payload,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (status != null) 'status': status,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? localId,
    Value<String>? operationType,
    Value<int>? payloadVersion,
    Value<String>? payload,
    Value<String>? idempotencyKey,
    Value<int>? createdAt,
    Value<int>? attemptCount,
    Value<int?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<String>? status,
  }) {
    return OutboxCompanion(
      localId: localId ?? this.localId,
      operationType: operationType ?? this.operationType,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('localId: $localId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RankedRunsTable extends RankedRuns
    with TableInfo<$RankedRunsTable, RankedRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RankedRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientScoreMeta = const VerificationMeta(
    'clientScore',
  );
  @override
  late final GeneratedColumn<int> clientScore = GeneratedColumn<int>(
    'client_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedScoreMeta = const VerificationMeta(
    'verifiedScore',
  );
  @override
  late final GeneratedColumn<int> verifiedScore = GeneratedColumn<int>(
    'verified_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectionReasonMeta = const VerificationMeta(
    'rejectionReason',
  );
  @override
  late final GeneratedColumn<String> rejectionReason = GeneratedColumn<String>(
    'rejection_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureCodeMeta = const VerificationMeta(
    'failureCode',
  );
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
    'failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    mode,
    status,
    clientScore,
    verifiedScore,
    rejectionReason,
    failureCode,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranked_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RankedRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('client_score')) {
      context.handle(
        _clientScoreMeta,
        clientScore.isAcceptableOrUnknown(
          data['client_score']!,
          _clientScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientScoreMeta);
    }
    if (data.containsKey('verified_score')) {
      context.handle(
        _verifiedScoreMeta,
        verifiedScore.isAcceptableOrUnknown(
          data['verified_score']!,
          _verifiedScoreMeta,
        ),
      );
    }
    if (data.containsKey('rejection_reason')) {
      context.handle(
        _rejectionReasonMeta,
        rejectionReason.isAcceptableOrUnknown(
          data['rejection_reason']!,
          _rejectionReasonMeta,
        ),
      );
    }
    if (data.containsKey('failure_code')) {
      context.handle(
        _failureCodeMeta,
        failureCode.isAcceptableOrUnknown(
          data['failure_code']!,
          _failureCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId};
  @override
  RankedRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RankedRunRow(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      clientScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_score'],
      )!,
      verifiedScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verified_score'],
      ),
      rejectionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejection_reason'],
      ),
      failureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_code'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $RankedRunsTable createAlias(String alias) {
    return $RankedRunsTable(attachedDatabase, alias);
  }
}

class RankedRunRow extends DataClass implements Insertable<RankedRunRow> {
  final String runId;
  final String mode;
  final String status;
  final int clientScore;
  final int? verifiedScore;
  final String? rejectionReason;
  final String? failureCode;
  final int createdAtMs;
  final int updatedAtMs;
  const RankedRunRow({
    required this.runId,
    required this.mode,
    required this.status,
    required this.clientScore,
    this.verifiedScore,
    this.rejectionReason,
    this.failureCode,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    map['client_score'] = Variable<int>(clientScore);
    if (!nullToAbsent || verifiedScore != null) {
      map['verified_score'] = Variable<int>(verifiedScore);
    }
    if (!nullToAbsent || rejectionReason != null) {
      map['rejection_reason'] = Variable<String>(rejectionReason);
    }
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  RankedRunsCompanion toCompanion(bool nullToAbsent) {
    return RankedRunsCompanion(
      runId: Value(runId),
      mode: Value(mode),
      status: Value(status),
      clientScore: Value(clientScore),
      verifiedScore: verifiedScore == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedScore),
      rejectionReason: rejectionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReason),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory RankedRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RankedRunRow(
      runId: serializer.fromJson<String>(json['runId']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      clientScore: serializer.fromJson<int>(json['clientScore']),
      verifiedScore: serializer.fromJson<int?>(json['verifiedScore']),
      rejectionReason: serializer.fromJson<String?>(json['rejectionReason']),
      failureCode: serializer.fromJson<String?>(json['failureCode']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'clientScore': serializer.toJson<int>(clientScore),
      'verifiedScore': serializer.toJson<int?>(verifiedScore),
      'rejectionReason': serializer.toJson<String?>(rejectionReason),
      'failureCode': serializer.toJson<String?>(failureCode),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  RankedRunRow copyWith({
    String? runId,
    String? mode,
    String? status,
    int? clientScore,
    Value<int?> verifiedScore = const Value.absent(),
    Value<String?> rejectionReason = const Value.absent(),
    Value<String?> failureCode = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => RankedRunRow(
    runId: runId ?? this.runId,
    mode: mode ?? this.mode,
    status: status ?? this.status,
    clientScore: clientScore ?? this.clientScore,
    verifiedScore: verifiedScore.present
        ? verifiedScore.value
        : this.verifiedScore,
    rejectionReason: rejectionReason.present
        ? rejectionReason.value
        : this.rejectionReason,
    failureCode: failureCode.present ? failureCode.value : this.failureCode,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  RankedRunRow copyWithCompanion(RankedRunsCompanion data) {
    return RankedRunRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      clientScore: data.clientScore.present
          ? data.clientScore.value
          : this.clientScore,
      verifiedScore: data.verifiedScore.present
          ? data.verifiedScore.value
          : this.verifiedScore,
      rejectionReason: data.rejectionReason.present
          ? data.rejectionReason.value
          : this.rejectionReason,
      failureCode: data.failureCode.present
          ? data.failureCode.value
          : this.failureCode,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RankedRunRow(')
          ..write('runId: $runId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('clientScore: $clientScore, ')
          ..write('verifiedScore: $verifiedScore, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    runId,
    mode,
    status,
    clientScore,
    verifiedScore,
    rejectionReason,
    failureCode,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RankedRunRow &&
          other.runId == this.runId &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.clientScore == this.clientScore &&
          other.verifiedScore == this.verifiedScore &&
          other.rejectionReason == this.rejectionReason &&
          other.failureCode == this.failureCode &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class RankedRunsCompanion extends UpdateCompanion<RankedRunRow> {
  final Value<String> runId;
  final Value<String> mode;
  final Value<String> status;
  final Value<int> clientScore;
  final Value<int?> verifiedScore;
  final Value<String?> rejectionReason;
  final Value<String?> failureCode;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const RankedRunsCompanion({
    this.runId = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.clientScore = const Value.absent(),
    this.verifiedScore = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RankedRunsCompanion.insert({
    required String runId,
    required String mode,
    required String status,
    required int clientScore,
    this.verifiedScore = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.failureCode = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       mode = Value(mode),
       status = Value(status),
       clientScore = Value(clientScore),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<RankedRunRow> custom({
    Expression<String>? runId,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<int>? clientScore,
    Expression<int>? verifiedScore,
    Expression<String>? rejectionReason,
    Expression<String>? failureCode,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (clientScore != null) 'client_score': clientScore,
      if (verifiedScore != null) 'verified_score': verifiedScore,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (failureCode != null) 'failure_code': failureCode,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RankedRunsCompanion copyWith({
    Value<String>? runId,
    Value<String>? mode,
    Value<String>? status,
    Value<int>? clientScore,
    Value<int?>? verifiedScore,
    Value<String?>? rejectionReason,
    Value<String?>? failureCode,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return RankedRunsCompanion(
      runId: runId ?? this.runId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      clientScore: clientScore ?? this.clientScore,
      verifiedScore: verifiedScore ?? this.verifiedScore,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      failureCode: failureCode ?? this.failureCode,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (clientScore.present) {
      map['client_score'] = Variable<int>(clientScore.value);
    }
    if (verifiedScore.present) {
      map['verified_score'] = Variable<int>(verifiedScore.value);
    }
    if (rejectionReason.present) {
      map['rejection_reason'] = Variable<String>(rejectionReason.value);
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RankedRunsCompanion(')
          ..write('runId: $runId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('clientScore: $clientScore, ')
          ..write('verifiedScore: $verifiedScore, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaderboardCacheTable extends LeaderboardCache
    with TableInfo<$LeaderboardCacheTable, LeaderboardCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaderboardCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMsMeta = const VerificationMeta(
    'fetchedAtMs',
  );
  @override
  late final GeneratedColumn<int> fetchedAtMs = GeneratedColumn<int>(
    'fetched_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, payload, fetchedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at_ms')) {
      context.handle(
        _fetchedAtMsMeta,
        fetchedAtMs.isAcceptableOrUnknown(
          data['fetched_at_ms']!,
          _fetchedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  LeaderboardCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardCacheRow(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_ms'],
      )!,
    );
  }

  @override
  $LeaderboardCacheTable createAlias(String alias) {
    return $LeaderboardCacheTable(attachedDatabase, alias);
  }
}

class LeaderboardCacheRow extends DataClass
    implements Insertable<LeaderboardCacheRow> {
  final String cacheKey;

  /// The full response body as JSON text (parsed back into a DTO on read).
  final String payload;

  /// Epoch ms the cached value was fetched from the server (freshness stamp).
  final int fetchedAtMs;
  const LeaderboardCacheRow({
    required this.cacheKey,
    required this.payload,
    required this.fetchedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload'] = Variable<String>(payload);
    map['fetched_at_ms'] = Variable<int>(fetchedAtMs);
    return map;
  }

  LeaderboardCacheCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardCacheCompanion(
      cacheKey: Value(cacheKey),
      payload: Value(payload),
      fetchedAtMs: Value(fetchedAtMs),
    );
  }

  factory LeaderboardCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardCacheRow(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAtMs: serializer.fromJson<int>(json['fetchedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payload': serializer.toJson<String>(payload),
      'fetchedAtMs': serializer.toJson<int>(fetchedAtMs),
    };
  }

  LeaderboardCacheRow copyWith({
    String? cacheKey,
    String? payload,
    int? fetchedAtMs,
  }) => LeaderboardCacheRow(
    cacheKey: cacheKey ?? this.cacheKey,
    payload: payload ?? this.payload,
    fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
  );
  LeaderboardCacheRow copyWithCompanion(LeaderboardCacheCompanion data) {
    return LeaderboardCacheRow(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAtMs: data.fetchedAtMs.present
          ? data.fetchedAtMs.value
          : this.fetchedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheRow(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAtMs: $fetchedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payload, fetchedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardCacheRow &&
          other.cacheKey == this.cacheKey &&
          other.payload == this.payload &&
          other.fetchedAtMs == this.fetchedAtMs);
}

class LeaderboardCacheCompanion extends UpdateCompanion<LeaderboardCacheRow> {
  final Value<String> cacheKey;
  final Value<String> payload;
  final Value<int> fetchedAtMs;
  final Value<int> rowid;
  const LeaderboardCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaderboardCacheCompanion.insert({
    required String cacheKey,
    required String payload,
    required int fetchedAtMs,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payload = Value(payload),
       fetchedAtMs = Value(fetchedAtMs);
  static Insertable<LeaderboardCacheRow> custom({
    Expression<String>? cacheKey,
    Expression<String>? payload,
    Expression<int>? fetchedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payload != null) 'payload': payload,
      if (fetchedAtMs != null) 'fetched_at_ms': fetchedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaderboardCacheCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? payload,
    Value<int>? fetchedAtMs,
    Value<int>? rowid,
  }) {
    return LeaderboardCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payload: payload ?? this.payload,
      fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAtMs.present) {
      map['fetched_at_ms'] = Variable<int>(fetchedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAtMs: $fetchedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MapProgressEntriesTable extends MapProgressEntries
    with TableInfo<$MapProgressEntriesTable, MapProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<String> catalogVersion = GeneratedColumn<String>(
    'catalog_version',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mapIdMeta = const VerificationMeta('mapId');
  @override
  late final GeneratedColumn<String> mapId = GeneratedColumn<String>(
    'map_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestRatingMeta = const VerificationMeta(
    'bestRating',
  );
  @override
  late final GeneratedColumn<int> bestRating = GeneratedColumn<int>(
    'best_rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    catalogVersion,
    mapId,
    bestRating,
    bestScore,
    attempts,
    completedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogVersionMeta);
    }
    if (data.containsKey('map_id')) {
      context.handle(
        _mapIdMeta,
        mapId.isAcceptableOrUnknown(data['map_id']!, _mapIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mapIdMeta);
    }
    if (data.containsKey('best_rating')) {
      context.handle(
        _bestRatingMeta,
        bestRating.isAcceptableOrUnknown(data['best_rating']!, _bestRatingMeta),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {catalogVersion, mapId};
  @override
  MapProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapProgressRow(
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_version'],
      )!,
      mapId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_id'],
      )!,
      bestRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_rating'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      ),
    );
  }

  @override
  $MapProgressEntriesTable createAlias(String alias) {
    return $MapProgressEntriesTable(attachedDatabase, alias);
  }
}

class MapProgressRow extends DataClass implements Insertable<MapProgressRow> {
  final String catalogVersion;
  final String mapId;
  final int bestRating;
  final int bestScore;
  final int attempts;
  final int? completedAtMs;
  const MapProgressRow({
    required this.catalogVersion,
    required this.mapId,
    required this.bestRating,
    required this.bestScore,
    required this.attempts,
    this.completedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['catalog_version'] = Variable<String>(catalogVersion);
    map['map_id'] = Variable<String>(mapId);
    map['best_rating'] = Variable<int>(bestRating);
    map['best_score'] = Variable<int>(bestScore);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || completedAtMs != null) {
      map['completed_at_ms'] = Variable<int>(completedAtMs);
    }
    return map;
  }

  MapProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return MapProgressEntriesCompanion(
      catalogVersion: Value(catalogVersion),
      mapId: Value(mapId),
      bestRating: Value(bestRating),
      bestScore: Value(bestScore),
      attempts: Value(attempts),
      completedAtMs: completedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMs),
    );
  }

  factory MapProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapProgressRow(
      catalogVersion: serializer.fromJson<String>(json['catalogVersion']),
      mapId: serializer.fromJson<String>(json['mapId']),
      bestRating: serializer.fromJson<int>(json['bestRating']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      attempts: serializer.fromJson<int>(json['attempts']),
      completedAtMs: serializer.fromJson<int?>(json['completedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'catalogVersion': serializer.toJson<String>(catalogVersion),
      'mapId': serializer.toJson<String>(mapId),
      'bestRating': serializer.toJson<int>(bestRating),
      'bestScore': serializer.toJson<int>(bestScore),
      'attempts': serializer.toJson<int>(attempts),
      'completedAtMs': serializer.toJson<int?>(completedAtMs),
    };
  }

  MapProgressRow copyWith({
    String? catalogVersion,
    String? mapId,
    int? bestRating,
    int? bestScore,
    int? attempts,
    Value<int?> completedAtMs = const Value.absent(),
  }) => MapProgressRow(
    catalogVersion: catalogVersion ?? this.catalogVersion,
    mapId: mapId ?? this.mapId,
    bestRating: bestRating ?? this.bestRating,
    bestScore: bestScore ?? this.bestScore,
    attempts: attempts ?? this.attempts,
    completedAtMs: completedAtMs.present
        ? completedAtMs.value
        : this.completedAtMs,
  );
  MapProgressRow copyWithCompanion(MapProgressEntriesCompanion data) {
    return MapProgressRow(
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
      mapId: data.mapId.present ? data.mapId.value : this.mapId,
      bestRating: data.bestRating.present
          ? data.bestRating.value
          : this.bestRating,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapProgressRow(')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('mapId: $mapId, ')
          ..write('bestRating: $bestRating, ')
          ..write('bestScore: $bestScore, ')
          ..write('attempts: $attempts, ')
          ..write('completedAtMs: $completedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    catalogVersion,
    mapId,
    bestRating,
    bestScore,
    attempts,
    completedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapProgressRow &&
          other.catalogVersion == this.catalogVersion &&
          other.mapId == this.mapId &&
          other.bestRating == this.bestRating &&
          other.bestScore == this.bestScore &&
          other.attempts == this.attempts &&
          other.completedAtMs == this.completedAtMs);
}

class MapProgressEntriesCompanion extends UpdateCompanion<MapProgressRow> {
  final Value<String> catalogVersion;
  final Value<String> mapId;
  final Value<int> bestRating;
  final Value<int> bestScore;
  final Value<int> attempts;
  final Value<int?> completedAtMs;
  final Value<int> rowid;
  const MapProgressEntriesCompanion({
    this.catalogVersion = const Value.absent(),
    this.mapId = const Value.absent(),
    this.bestRating = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MapProgressEntriesCompanion.insert({
    required String catalogVersion,
    required String mapId,
    this.bestRating = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : catalogVersion = Value(catalogVersion),
       mapId = Value(mapId);
  static Insertable<MapProgressRow> custom({
    Expression<String>? catalogVersion,
    Expression<String>? mapId,
    Expression<int>? bestRating,
    Expression<int>? bestScore,
    Expression<int>? attempts,
    Expression<int>? completedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (mapId != null) 'map_id': mapId,
      if (bestRating != null) 'best_rating': bestRating,
      if (bestScore != null) 'best_score': bestScore,
      if (attempts != null) 'attempts': attempts,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MapProgressEntriesCompanion copyWith({
    Value<String>? catalogVersion,
    Value<String>? mapId,
    Value<int>? bestRating,
    Value<int>? bestScore,
    Value<int>? attempts,
    Value<int?>? completedAtMs,
    Value<int>? rowid,
  }) {
    return MapProgressEntriesCompanion(
      catalogVersion: catalogVersion ?? this.catalogVersion,
      mapId: mapId ?? this.mapId,
      bestRating: bestRating ?? this.bestRating,
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<String>(catalogVersion.value);
    }
    if (mapId.present) {
      map['map_id'] = Variable<String>(mapId.value);
    }
    if (bestRating.present) {
      map['best_rating'] = Variable<int>(bestRating.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapProgressEntriesCompanion(')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('mapId: $mapId, ')
          ..write('bestRating: $bestRating, ')
          ..write('bestScore: $bestScore, ')
          ..write('attempts: $attempts, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $RankedRunsTable rankedRuns = $RankedRunsTable(this);
  late final $LeaderboardCacheTable leaderboardCache = $LeaderboardCacheTable(
    this,
  );
  late final $MapProgressEntriesTable mapProgressEntries =
      $MapProgressEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runs,
    outbox,
    rankedRuns,
    leaderboardCache,
    mapProgressEntries,
  ];
}

typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      Value<int> id,
      required int playedAtMs,
      required String mode,
      required int score,
      required int equations,
      required int bestCombo,
      required int levelReached,
      required int durationMs,
      required String rulesetVersion,
      required String seed,
      Value<String?> protocolVersion,
      Value<String?> mapCatalogVersion,
      Value<String?> mapId,
      Value<int> targetsSolved,
      Value<int?> rating,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<int> id,
      Value<int> playedAtMs,
      Value<String> mode,
      Value<int> score,
      Value<int> equations,
      Value<int> bestCombo,
      Value<int> levelReached,
      Value<int> durationMs,
      Value<String> rulesetVersion,
      Value<String> seed,
      Value<String?> protocolVersion,
      Value<String?> mapCatalogVersion,
      Value<String?> mapId,
      Value<int> targetsSolved,
      Value<int?> rating,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
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

  ColumnFilters<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get equations => $composableBuilder(
    column: $table.equations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestCombo => $composableBuilder(
    column: $table.bestCombo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelReached => $composableBuilder(
    column: $table.levelReached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapCatalogVersion => $composableBuilder(
    column: $table.mapCatalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapId => $composableBuilder(
    column: $table.mapId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetsSolved => $composableBuilder(
    column: $table.targetsSolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
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

  ColumnOrderings<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get equations => $composableBuilder(
    column: $table.equations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestCombo => $composableBuilder(
    column: $table.bestCombo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelReached => $composableBuilder(
    column: $table.levelReached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapCatalogVersion => $composableBuilder(
    column: $table.mapCatalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapId => $composableBuilder(
    column: $table.mapId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetsSolved => $composableBuilder(
    column: $table.targetsSolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get equations =>
      $composableBuilder(column: $table.equations, builder: (column) => column);

  GeneratedColumn<int> get bestCombo =>
      $composableBuilder(column: $table.bestCombo, builder: (column) => column);

  GeneratedColumn<int> get levelReached => $composableBuilder(
    column: $table.levelReached,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rulesetVersion => $composableBuilder(
    column: $table.rulesetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<String> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mapCatalogVersion => $composableBuilder(
    column: $table.mapCatalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mapId =>
      $composableBuilder(column: $table.mapId, builder: (column) => column);

  GeneratedColumn<int> get targetsSolved => $composableBuilder(
    column: $table.targetsSolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          Run,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
          Run,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playedAtMs = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> equations = const Value.absent(),
                Value<int> bestCombo = const Value.absent(),
                Value<int> levelReached = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> rulesetVersion = const Value.absent(),
                Value<String> seed = const Value.absent(),
                Value<String?> protocolVersion = const Value.absent(),
                Value<String?> mapCatalogVersion = const Value.absent(),
                Value<String?> mapId = const Value.absent(),
                Value<int> targetsSolved = const Value.absent(),
                Value<int?> rating = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                playedAtMs: playedAtMs,
                mode: mode,
                score: score,
                equations: equations,
                bestCombo: bestCombo,
                levelReached: levelReached,
                durationMs: durationMs,
                rulesetVersion: rulesetVersion,
                seed: seed,
                protocolVersion: protocolVersion,
                mapCatalogVersion: mapCatalogVersion,
                mapId: mapId,
                targetsSolved: targetsSolved,
                rating: rating,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playedAtMs,
                required String mode,
                required int score,
                required int equations,
                required int bestCombo,
                required int levelReached,
                required int durationMs,
                required String rulesetVersion,
                required String seed,
                Value<String?> protocolVersion = const Value.absent(),
                Value<String?> mapCatalogVersion = const Value.absent(),
                Value<String?> mapId = const Value.absent(),
                Value<int> targetsSolved = const Value.absent(),
                Value<int?> rating = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                playedAtMs: playedAtMs,
                mode: mode,
                score: score,
                equations: equations,
                bestCombo: bestCombo,
                levelReached: levelReached,
                durationMs: durationMs,
                rulesetVersion: rulesetVersion,
                seed: seed,
                protocolVersion: protocolVersion,
                mapCatalogVersion: mapCatalogVersion,
                mapId: mapId,
                targetsSolved: targetsSolved,
                rating: rating,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      Run,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
      Run,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> localId,
      required String operationType,
      required int payloadVersion,
      required String payload,
      required String idempotencyKey,
      required int createdAt,
      Value<int> attemptCount,
      Value<int?> nextAttemptAt,
      Value<String?> lastErrorCode,
      required String status,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> localId,
      Value<String> operationType,
      Value<int> payloadVersion,
      Value<String> payload,
      Value<String> idempotencyKey,
      Value<int> createdAt,
      Value<int> attemptCount,
      Value<int?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<String> status,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxItemRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxItemRow,
            BaseReferences<_$AppDatabase, $OutboxTable, OutboxItemRow>,
          ),
          OutboxItemRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboxCompanion(
                localId: localId,
                operationType: operationType,
                payloadVersion: payloadVersion,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String operationType,
                required int payloadVersion,
                required String payload,
                required String idempotencyKey,
                required int createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required String status,
              }) => OutboxCompanion.insert(
                localId: localId,
                operationType: operationType,
                payloadVersion: payloadVersion,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxItemRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (
        OutboxItemRow,
        BaseReferences<_$AppDatabase, $OutboxTable, OutboxItemRow>,
      ),
      OutboxItemRow,
      PrefetchHooks Function()
    >;
typedef $$RankedRunsTableCreateCompanionBuilder =
    RankedRunsCompanion Function({
      required String runId,
      required String mode,
      required String status,
      required int clientScore,
      Value<int?> verifiedScore,
      Value<String?> rejectionReason,
      Value<String?> failureCode,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$RankedRunsTableUpdateCompanionBuilder =
    RankedRunsCompanion Function({
      Value<String> runId,
      Value<String> mode,
      Value<String> status,
      Value<int> clientScore,
      Value<int?> verifiedScore,
      Value<String?> rejectionReason,
      Value<String?> failureCode,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$RankedRunsTableFilterComposer
    extends Composer<_$AppDatabase, $RankedRunsTable> {
  $$RankedRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientScore => $composableBuilder(
    column: $table.clientScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verifiedScore => $composableBuilder(
    column: $table.verifiedScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RankedRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $RankedRunsTable> {
  $$RankedRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientScore => $composableBuilder(
    column: $table.clientScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verifiedScore => $composableBuilder(
    column: $table.verifiedScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RankedRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RankedRunsTable> {
  $$RankedRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get clientScore => $composableBuilder(
    column: $table.clientScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verifiedScore => $composableBuilder(
    column: $table.verifiedScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$RankedRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RankedRunsTable,
          RankedRunRow,
          $$RankedRunsTableFilterComposer,
          $$RankedRunsTableOrderingComposer,
          $$RankedRunsTableAnnotationComposer,
          $$RankedRunsTableCreateCompanionBuilder,
          $$RankedRunsTableUpdateCompanionBuilder,
          (
            RankedRunRow,
            BaseReferences<_$AppDatabase, $RankedRunsTable, RankedRunRow>,
          ),
          RankedRunRow,
          PrefetchHooks Function()
        > {
  $$RankedRunsTableTableManager(_$AppDatabase db, $RankedRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RankedRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RankedRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RankedRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> clientScore = const Value.absent(),
                Value<int?> verifiedScore = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RankedRunsCompanion(
                runId: runId,
                mode: mode,
                status: status,
                clientScore: clientScore,
                verifiedScore: verifiedScore,
                rejectionReason: rejectionReason,
                failureCode: failureCode,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required String mode,
                required String status,
                required int clientScore,
                Value<int?> verifiedScore = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => RankedRunsCompanion.insert(
                runId: runId,
                mode: mode,
                status: status,
                clientScore: clientScore,
                verifiedScore: verifiedScore,
                rejectionReason: rejectionReason,
                failureCode: failureCode,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RankedRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RankedRunsTable,
      RankedRunRow,
      $$RankedRunsTableFilterComposer,
      $$RankedRunsTableOrderingComposer,
      $$RankedRunsTableAnnotationComposer,
      $$RankedRunsTableCreateCompanionBuilder,
      $$RankedRunsTableUpdateCompanionBuilder,
      (
        RankedRunRow,
        BaseReferences<_$AppDatabase, $RankedRunsTable, RankedRunRow>,
      ),
      RankedRunRow,
      PrefetchHooks Function()
    >;
typedef $$LeaderboardCacheTableCreateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      required String cacheKey,
      required String payload,
      required int fetchedAtMs,
      Value<int> rowid,
    });
typedef $$LeaderboardCacheTableUpdateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      Value<String> cacheKey,
      Value<String> payload,
      Value<int> fetchedAtMs,
      Value<int> rowid,
    });

class $$LeaderboardCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaderboardCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaderboardCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheTable> {
  $$LeaderboardCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => column,
  );
}

class $$LeaderboardCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaderboardCacheTable,
          LeaderboardCacheRow,
          $$LeaderboardCacheTableFilterComposer,
          $$LeaderboardCacheTableOrderingComposer,
          $$LeaderboardCacheTableAnnotationComposer,
          $$LeaderboardCacheTableCreateCompanionBuilder,
          $$LeaderboardCacheTableUpdateCompanionBuilder,
          (
            LeaderboardCacheRow,
            BaseReferences<
              _$AppDatabase,
              $LeaderboardCacheTable,
              LeaderboardCacheRow
            >,
          ),
          LeaderboardCacheRow,
          PrefetchHooks Function()
        > {
  $$LeaderboardCacheTableTableManager(
    _$AppDatabase db,
    $LeaderboardCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaderboardCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaderboardCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaderboardCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> fetchedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheCompanion(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAtMs: fetchedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String payload,
                required int fetchedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheCompanion.insert(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAtMs: fetchedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaderboardCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaderboardCacheTable,
      LeaderboardCacheRow,
      $$LeaderboardCacheTableFilterComposer,
      $$LeaderboardCacheTableOrderingComposer,
      $$LeaderboardCacheTableAnnotationComposer,
      $$LeaderboardCacheTableCreateCompanionBuilder,
      $$LeaderboardCacheTableUpdateCompanionBuilder,
      (
        LeaderboardCacheRow,
        BaseReferences<
          _$AppDatabase,
          $LeaderboardCacheTable,
          LeaderboardCacheRow
        >,
      ),
      LeaderboardCacheRow,
      PrefetchHooks Function()
    >;
typedef $$MapProgressEntriesTableCreateCompanionBuilder =
    MapProgressEntriesCompanion Function({
      required String catalogVersion,
      required String mapId,
      Value<int> bestRating,
      Value<int> bestScore,
      Value<int> attempts,
      Value<int?> completedAtMs,
      Value<int> rowid,
    });
typedef $$MapProgressEntriesTableUpdateCompanionBuilder =
    MapProgressEntriesCompanion Function({
      Value<String> catalogVersion,
      Value<String> mapId,
      Value<int> bestRating,
      Value<int> bestScore,
      Value<int> attempts,
      Value<int?> completedAtMs,
      Value<int> rowid,
    });

class $$MapProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MapProgressEntriesTable> {
  $$MapProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapId => $composableBuilder(
    column: $table.mapId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestRating => $composableBuilder(
    column: $table.bestRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MapProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapProgressEntriesTable> {
  $$MapProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapId => $composableBuilder(
    column: $table.mapId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestRating => $composableBuilder(
    column: $table.bestRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MapProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapProgressEntriesTable> {
  $$MapProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mapId =>
      $composableBuilder(column: $table.mapId, builder: (column) => column);

  GeneratedColumn<int> get bestRating => $composableBuilder(
    column: $table.bestRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );
}

class $$MapProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapProgressEntriesTable,
          MapProgressRow,
          $$MapProgressEntriesTableFilterComposer,
          $$MapProgressEntriesTableOrderingComposer,
          $$MapProgressEntriesTableAnnotationComposer,
          $$MapProgressEntriesTableCreateCompanionBuilder,
          $$MapProgressEntriesTableUpdateCompanionBuilder,
          (
            MapProgressRow,
            BaseReferences<
              _$AppDatabase,
              $MapProgressEntriesTable,
              MapProgressRow
            >,
          ),
          MapProgressRow,
          PrefetchHooks Function()
        > {
  $$MapProgressEntriesTableTableManager(
    _$AppDatabase db,
    $MapProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapProgressEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> catalogVersion = const Value.absent(),
                Value<String> mapId = const Value.absent(),
                Value<int> bestRating = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MapProgressEntriesCompanion(
                catalogVersion: catalogVersion,
                mapId: mapId,
                bestRating: bestRating,
                bestScore: bestScore,
                attempts: attempts,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String catalogVersion,
                required String mapId,
                Value<int> bestRating = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MapProgressEntriesCompanion.insert(
                catalogVersion: catalogVersion,
                mapId: mapId,
                bestRating: bestRating,
                bestScore: bestScore,
                attempts: attempts,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MapProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapProgressEntriesTable,
      MapProgressRow,
      $$MapProgressEntriesTableFilterComposer,
      $$MapProgressEntriesTableOrderingComposer,
      $$MapProgressEntriesTableAnnotationComposer,
      $$MapProgressEntriesTableCreateCompanionBuilder,
      $$MapProgressEntriesTableUpdateCompanionBuilder,
      (
        MapProgressRow,
        BaseReferences<_$AppDatabase, $MapProgressEntriesTable, MapProgressRow>,
      ),
      MapProgressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$RankedRunsTableTableManager get rankedRuns =>
      $$RankedRunsTableTableManager(_db, _db.rankedRuns);
  $$LeaderboardCacheTableTableManager get leaderboardCache =>
      $$LeaderboardCacheTableTableManager(_db, _db.leaderboardCache);
  $$MapProgressEntriesTableTableManager get mapProgressEntries =>
      $$MapProgressEntriesTableTableManager(_db, _db.mapProgressEntries);
}
