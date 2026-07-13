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
          ..write('seed: $seed')
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
          other.seed == this.seed);
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
          ..write('seed: $seed')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $RankedRunsTable rankedRuns = $RankedRunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runs,
    outbox,
    rankedRuns,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$RankedRunsTableTableManager get rankedRuns =>
      $$RankedRunsTableTableManager(_db, _db.rankedRuns);
}
