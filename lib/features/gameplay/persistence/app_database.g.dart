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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [runs];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
}
