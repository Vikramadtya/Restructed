// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isDefault,
    icon,
    description,
    isActive,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final bool isDefault;
  final String? icon;
  final String? description;
  final bool isActive;
  final String syncStatus;
  const Category({
    required this.id,
    required this.name,
    required this.isDefault,
    this.icon,
    this.description,
    required this.isActive,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      icon: serializer.fromJson<String?>(json['icon']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'icon': serializer.toJson<String?>(icon),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    bool? isDefault,
    Value<String?> icon = const Value.absent(),
    Value<String?> description = const Value.absent(),
    bool? isActive,
    String? syncStatus,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    icon: icon.present ? icon.value : this.icon,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      icon: data.icon.present ? data.icon.value : this.icon,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('icon: $icon, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isDefault, icon, description, isActive, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.icon == this.icon &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<String?> icon;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.icon = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.isDefault = const Value.absent(),
    this.icon = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<String>? icon,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<String?>? icon,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('icon: $icon, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlockRulesTable extends BlockRules
    with TableInfo<$BlockRulesTable, BlockRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blockDurationSecondsMeta =
      const VerificationMeta('blockDurationSeconds');
  @override
  late final GeneratedColumn<int> blockDurationSeconds = GeneratedColumn<int>(
    'block_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastActivatedAtMeta = const VerificationMeta(
    'lastActivatedAt',
  );
  @override
  late final GeneratedColumn<int> lastActivatedAt = GeneratedColumn<int>(
    'last_activated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStrictModeMeta = const VerificationMeta(
    'isStrictMode',
  );
  @override
  late final GeneratedColumn<bool> isStrictMode = GeneratedColumn<bool>(
    'is_strict_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_strict_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAppRuleMeta = const VerificationMeta(
    'isAppRule',
  );
  @override
  late final GeneratedColumn<bool> isAppRule = GeneratedColumn<bool>(
    'is_app_rule',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_app_rule" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<String> scheduledDays = GeneratedColumn<String>(
    'scheduled_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    domain,
    blockDurationSeconds,
    isActive,
    lastActivatedAt,
    isStrictMode,
    isAppRule,
    scheduledDays,
    startTime,
    endTime,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('block_duration_seconds')) {
      context.handle(
        _blockDurationSecondsMeta,
        blockDurationSeconds.isAcceptableOrUnknown(
          data['block_duration_seconds']!,
          _blockDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_blockDurationSecondsMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_activated_at')) {
      context.handle(
        _lastActivatedAtMeta,
        lastActivatedAt.isAcceptableOrUnknown(
          data['last_activated_at']!,
          _lastActivatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_strict_mode')) {
      context.handle(
        _isStrictModeMeta,
        isStrictMode.isAcceptableOrUnknown(
          data['is_strict_mode']!,
          _isStrictModeMeta,
        ),
      );
    }
    if (data.containsKey('is_app_rule')) {
      context.handle(
        _isAppRuleMeta,
        isAppRule.isAcceptableOrUnknown(data['is_app_rule']!, _isAppRuleMeta),
      );
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      blockDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_duration_seconds'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastActivatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_activated_at'],
      ),
      isStrictMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_strict_mode'],
      )!,
      isAppRule: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_app_rule'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_days'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $BlockRulesTable createAlias(String alias) {
    return $BlockRulesTable(attachedDatabase, alias);
  }
}

class BlockRule extends DataClass implements Insertable<BlockRule> {
  final String id;
  final String categoryId;
  final String domain;
  final int blockDurationSeconds;
  final bool isActive;
  final int? lastActivatedAt;
  final bool isStrictMode;
  final bool isAppRule;
  final String? scheduledDays;
  final String? startTime;
  final String? endTime;
  final String syncStatus;
  const BlockRule({
    required this.id,
    required this.categoryId,
    required this.domain,
    required this.blockDurationSeconds,
    required this.isActive,
    this.lastActivatedAt,
    required this.isStrictMode,
    required this.isAppRule,
    this.scheduledDays,
    this.startTime,
    this.endTime,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['domain'] = Variable<String>(domain);
    map['block_duration_seconds'] = Variable<int>(blockDurationSeconds);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastActivatedAt != null) {
      map['last_activated_at'] = Variable<int>(lastActivatedAt);
    }
    map['is_strict_mode'] = Variable<bool>(isStrictMode);
    map['is_app_rule'] = Variable<bool>(isAppRule);
    if (!nullToAbsent || scheduledDays != null) {
      map['scheduled_days'] = Variable<String>(scheduledDays);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  BlockRulesCompanion toCompanion(bool nullToAbsent) {
    return BlockRulesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      domain: Value(domain),
      blockDurationSeconds: Value(blockDurationSeconds),
      isActive: Value(isActive),
      lastActivatedAt: lastActivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivatedAt),
      isStrictMode: Value(isStrictMode),
      isAppRule: Value(isAppRule),
      scheduledDays: scheduledDays == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDays),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      syncStatus: Value(syncStatus),
    );
  }

  factory BlockRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockRule(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      domain: serializer.fromJson<String>(json['domain']),
      blockDurationSeconds: serializer.fromJson<int>(
        json['blockDurationSeconds'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastActivatedAt: serializer.fromJson<int?>(json['lastActivatedAt']),
      isStrictMode: serializer.fromJson<bool>(json['isStrictMode']),
      isAppRule: serializer.fromJson<bool>(json['isAppRule']),
      scheduledDays: serializer.fromJson<String?>(json['scheduledDays']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'domain': serializer.toJson<String>(domain),
      'blockDurationSeconds': serializer.toJson<int>(blockDurationSeconds),
      'isActive': serializer.toJson<bool>(isActive),
      'lastActivatedAt': serializer.toJson<int?>(lastActivatedAt),
      'isStrictMode': serializer.toJson<bool>(isStrictMode),
      'isAppRule': serializer.toJson<bool>(isAppRule),
      'scheduledDays': serializer.toJson<String?>(scheduledDays),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  BlockRule copyWith({
    String? id,
    String? categoryId,
    String? domain,
    int? blockDurationSeconds,
    bool? isActive,
    Value<int?> lastActivatedAt = const Value.absent(),
    bool? isStrictMode,
    bool? isAppRule,
    Value<String?> scheduledDays = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    String? syncStatus,
  }) => BlockRule(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    domain: domain ?? this.domain,
    blockDurationSeconds: blockDurationSeconds ?? this.blockDurationSeconds,
    isActive: isActive ?? this.isActive,
    lastActivatedAt: lastActivatedAt.present
        ? lastActivatedAt.value
        : this.lastActivatedAt,
    isStrictMode: isStrictMode ?? this.isStrictMode,
    isAppRule: isAppRule ?? this.isAppRule,
    scheduledDays: scheduledDays.present
        ? scheduledDays.value
        : this.scheduledDays,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  BlockRule copyWithCompanion(BlockRulesCompanion data) {
    return BlockRule(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      domain: data.domain.present ? data.domain.value : this.domain,
      blockDurationSeconds: data.blockDurationSeconds.present
          ? data.blockDurationSeconds.value
          : this.blockDurationSeconds,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastActivatedAt: data.lastActivatedAt.present
          ? data.lastActivatedAt.value
          : this.lastActivatedAt,
      isStrictMode: data.isStrictMode.present
          ? data.isStrictMode.value
          : this.isStrictMode,
      isAppRule: data.isAppRule.present ? data.isAppRule.value : this.isAppRule,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockRule(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('domain: $domain, ')
          ..write('blockDurationSeconds: $blockDurationSeconds, ')
          ..write('isActive: $isActive, ')
          ..write('lastActivatedAt: $lastActivatedAt, ')
          ..write('isStrictMode: $isStrictMode, ')
          ..write('isAppRule: $isAppRule, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    domain,
    blockDurationSeconds,
    isActive,
    lastActivatedAt,
    isStrictMode,
    isAppRule,
    scheduledDays,
    startTime,
    endTime,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockRule &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.domain == this.domain &&
          other.blockDurationSeconds == this.blockDurationSeconds &&
          other.isActive == this.isActive &&
          other.lastActivatedAt == this.lastActivatedAt &&
          other.isStrictMode == this.isStrictMode &&
          other.isAppRule == this.isAppRule &&
          other.scheduledDays == this.scheduledDays &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.syncStatus == this.syncStatus);
}

class BlockRulesCompanion extends UpdateCompanion<BlockRule> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> domain;
  final Value<int> blockDurationSeconds;
  final Value<bool> isActive;
  final Value<int?> lastActivatedAt;
  final Value<bool> isStrictMode;
  final Value<bool> isAppRule;
  final Value<String?> scheduledDays;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const BlockRulesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.domain = const Value.absent(),
    this.blockDurationSeconds = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastActivatedAt = const Value.absent(),
    this.isStrictMode = const Value.absent(),
    this.isAppRule = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlockRulesCompanion.insert({
    required String id,
    required String categoryId,
    required String domain,
    required int blockDurationSeconds,
    this.isActive = const Value.absent(),
    this.lastActivatedAt = const Value.absent(),
    this.isStrictMode = const Value.absent(),
    this.isAppRule = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       domain = Value(domain),
       blockDurationSeconds = Value(blockDurationSeconds);
  static Insertable<BlockRule> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? domain,
    Expression<int>? blockDurationSeconds,
    Expression<bool>? isActive,
    Expression<int>? lastActivatedAt,
    Expression<bool>? isStrictMode,
    Expression<bool>? isAppRule,
    Expression<String>? scheduledDays,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (domain != null) 'domain': domain,
      if (blockDurationSeconds != null)
        'block_duration_seconds': blockDurationSeconds,
      if (isActive != null) 'is_active': isActive,
      if (lastActivatedAt != null) 'last_activated_at': lastActivatedAt,
      if (isStrictMode != null) 'is_strict_mode': isStrictMode,
      if (isAppRule != null) 'is_app_rule': isAppRule,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlockRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? domain,
    Value<int>? blockDurationSeconds,
    Value<bool>? isActive,
    Value<int?>? lastActivatedAt,
    Value<bool>? isStrictMode,
    Value<bool>? isAppRule,
    Value<String?>? scheduledDays,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return BlockRulesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      domain: domain ?? this.domain,
      blockDurationSeconds: blockDurationSeconds ?? this.blockDurationSeconds,
      isActive: isActive ?? this.isActive,
      lastActivatedAt: lastActivatedAt ?? this.lastActivatedAt,
      isStrictMode: isStrictMode ?? this.isStrictMode,
      isAppRule: isAppRule ?? this.isAppRule,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (blockDurationSeconds.present) {
      map['block_duration_seconds'] = Variable<int>(blockDurationSeconds.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastActivatedAt.present) {
      map['last_activated_at'] = Variable<int>(lastActivatedAt.value);
    }
    if (isStrictMode.present) {
      map['is_strict_mode'] = Variable<bool>(isStrictMode.value);
    }
    if (isAppRule.present) {
      map['is_app_rule'] = Variable<bool>(isAppRule.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<String>(scheduledDays.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockRulesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('domain: $domain, ')
          ..write('blockDurationSeconds: $blockDurationSeconds, ')
          ..write('isActive: $isActive, ')
          ..write('lastActivatedAt: $lastActivatedAt, ')
          ..write('isStrictMode: $isStrictMode, ')
          ..write('isAppRule: $isAppRule, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlockAttemptsTable extends BlockAttempts
    with TableInfo<$BlockAttemptsTable, BlockAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockAttemptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptedAtMeta = const VerificationMeta(
    'attemptedAt',
  );
  @override
  late final GeneratedColumn<int> attemptedAt = GeneratedColumn<int>(
    'attempted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, domain, attemptedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
        _attemptedAtMeta,
        attemptedAt.isAcceptableOrUnknown(
          data['attempted_at']!,
          _attemptedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      attemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempted_at'],
      )!,
    );
  }

  @override
  $BlockAttemptsTable createAlias(String alias) {
    return $BlockAttemptsTable(attachedDatabase, alias);
  }
}

class BlockAttempt extends DataClass implements Insertable<BlockAttempt> {
  final int id;
  final String domain;
  final int attemptedAt;
  const BlockAttempt({
    required this.id,
    required this.domain,
    required this.attemptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['domain'] = Variable<String>(domain);
    map['attempted_at'] = Variable<int>(attemptedAt);
    return map;
  }

  BlockAttemptsCompanion toCompanion(bool nullToAbsent) {
    return BlockAttemptsCompanion(
      id: Value(id),
      domain: Value(domain),
      attemptedAt: Value(attemptedAt),
    );
  }

  factory BlockAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockAttempt(
      id: serializer.fromJson<int>(json['id']),
      domain: serializer.fromJson<String>(json['domain']),
      attemptedAt: serializer.fromJson<int>(json['attemptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'domain': serializer.toJson<String>(domain),
      'attemptedAt': serializer.toJson<int>(attemptedAt),
    };
  }

  BlockAttempt copyWith({int? id, String? domain, int? attemptedAt}) =>
      BlockAttempt(
        id: id ?? this.id,
        domain: domain ?? this.domain,
        attemptedAt: attemptedAt ?? this.attemptedAt,
      );
  BlockAttempt copyWithCompanion(BlockAttemptsCompanion data) {
    return BlockAttempt(
      id: data.id.present ? data.id.value : this.id,
      domain: data.domain.present ? data.domain.value : this.domain,
      attemptedAt: data.attemptedAt.present
          ? data.attemptedAt.value
          : this.attemptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockAttempt(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, domain, attemptedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockAttempt &&
          other.id == this.id &&
          other.domain == this.domain &&
          other.attemptedAt == this.attemptedAt);
}

class BlockAttemptsCompanion extends UpdateCompanion<BlockAttempt> {
  final Value<int> id;
  final Value<String> domain;
  final Value<int> attemptedAt;
  const BlockAttemptsCompanion({
    this.id = const Value.absent(),
    this.domain = const Value.absent(),
    this.attemptedAt = const Value.absent(),
  });
  BlockAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String domain,
    required int attemptedAt,
  }) : domain = Value(domain),
       attemptedAt = Value(attemptedAt);
  static Insertable<BlockAttempt> custom({
    Expression<int>? id,
    Expression<String>? domain,
    Expression<int>? attemptedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (domain != null) 'domain': domain,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
    });
  }

  BlockAttemptsCompanion copyWith({
    Value<int>? id,
    Value<String>? domain,
    Value<int>? attemptedAt,
  }) {
    return BlockAttemptsCompanion(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<int>(attemptedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BlockRulesTable blockRules = $BlockRulesTable(this);
  late final $BlockAttemptsTable blockAttempts = $BlockAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    blockRules,
    blockAttempts,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<bool> isDefault,
      Value<String?> icon,
      Value<String?> description,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isDefault,
      Value<String?> icon,
      Value<String?> description,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BlockRulesTable, List<BlockRule>>
  _blockRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.blockRules,
    aliasName: 'categories__id__block_rules__category_id',
  );

  $$BlockRulesTableProcessedTableManager get blockRulesRefs {
    final manager = $$BlockRulesTableTableManager(
      $_db,
      $_db.blockRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_blockRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> blockRulesRefs(
    Expression<bool> Function($$BlockRulesTableFilterComposer f) f,
  ) {
    final $$BlockRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blockRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlockRulesTableFilterComposer(
            $db: $db,
            $table: $db.blockRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> blockRulesRefs<T extends Object>(
    Expression<T> Function($$BlockRulesTableAnnotationComposer a) f,
  ) {
    final $$BlockRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blockRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlockRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.blockRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool blockRulesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                icon: icon,
                description: description,
                isActive: isActive,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isDefault = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                icon: icon,
                description: description,
                isActive: isActive,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({blockRulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (blockRulesRefs) db.blockRules],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (blockRulesRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      BlockRule
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._blockRulesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).blockRulesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool blockRulesRefs})
    >;
typedef $$BlockRulesTableCreateCompanionBuilder =
    BlockRulesCompanion Function({
      required String id,
      required String categoryId,
      required String domain,
      required int blockDurationSeconds,
      Value<bool> isActive,
      Value<int?> lastActivatedAt,
      Value<bool> isStrictMode,
      Value<bool> isAppRule,
      Value<String?> scheduledDays,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$BlockRulesTableUpdateCompanionBuilder =
    BlockRulesCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> domain,
      Value<int> blockDurationSeconds,
      Value<bool> isActive,
      Value<int?> lastActivatedAt,
      Value<bool> isStrictMode,
      Value<bool> isAppRule,
      Value<String?> scheduledDays,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$BlockRulesTableReferences
    extends BaseReferences<_$AppDatabase, $BlockRulesTable, BlockRule> {
  $$BlockRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('block_rules__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BlockRulesTableFilterComposer
    extends Composer<_$AppDatabase, $BlockRulesTable> {
  $$BlockRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blockDurationSeconds => $composableBuilder(
    column: $table.blockDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastActivatedAt => $composableBuilder(
    column: $table.lastActivatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStrictMode => $composableBuilder(
    column: $table.isStrictMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAppRule => $composableBuilder(
    column: $table.isAppRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockRulesTable> {
  $$BlockRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blockDurationSeconds => $composableBuilder(
    column: $table.blockDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActivatedAt => $composableBuilder(
    column: $table.lastActivatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStrictMode => $composableBuilder(
    column: $table.isStrictMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAppRule => $composableBuilder(
    column: $table.isAppRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockRulesTable> {
  $$BlockRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<int> get blockDurationSeconds => $composableBuilder(
    column: $table.blockDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get lastActivatedAt => $composableBuilder(
    column: $table.lastActivatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStrictMode => $composableBuilder(
    column: $table.isStrictMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAppRule =>
      $composableBuilder(column: $table.isAppRule, builder: (column) => column);

  GeneratedColumn<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlockRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockRulesTable,
          BlockRule,
          $$BlockRulesTableFilterComposer,
          $$BlockRulesTableOrderingComposer,
          $$BlockRulesTableAnnotationComposer,
          $$BlockRulesTableCreateCompanionBuilder,
          $$BlockRulesTableUpdateCompanionBuilder,
          (BlockRule, $$BlockRulesTableReferences),
          BlockRule,
          PrefetchHooks Function({bool categoryId})
        > {
  $$BlockRulesTableTableManager(_$AppDatabase db, $BlockRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<int> blockDurationSeconds = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastActivatedAt = const Value.absent(),
                Value<bool> isStrictMode = const Value.absent(),
                Value<bool> isAppRule = const Value.absent(),
                Value<String?> scheduledDays = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockRulesCompanion(
                id: id,
                categoryId: categoryId,
                domain: domain,
                blockDurationSeconds: blockDurationSeconds,
                isActive: isActive,
                lastActivatedAt: lastActivatedAt,
                isStrictMode: isStrictMode,
                isAppRule: isAppRule,
                scheduledDays: scheduledDays,
                startTime: startTime,
                endTime: endTime,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String domain,
                required int blockDurationSeconds,
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastActivatedAt = const Value.absent(),
                Value<bool> isStrictMode = const Value.absent(),
                Value<bool> isAppRule = const Value.absent(),
                Value<String?> scheduledDays = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockRulesCompanion.insert(
                id: id,
                categoryId: categoryId,
                domain: domain,
                blockDurationSeconds: blockDurationSeconds,
                isActive: isActive,
                lastActivatedAt: lastActivatedAt,
                isStrictMode: isStrictMode,
                isAppRule: isAppRule,
                scheduledDays: scheduledDays,
                startTime: startTime,
                endTime: endTime,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BlockRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$BlockRulesTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$BlockRulesTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BlockRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockRulesTable,
      BlockRule,
      $$BlockRulesTableFilterComposer,
      $$BlockRulesTableOrderingComposer,
      $$BlockRulesTableAnnotationComposer,
      $$BlockRulesTableCreateCompanionBuilder,
      $$BlockRulesTableUpdateCompanionBuilder,
      (BlockRule, $$BlockRulesTableReferences),
      BlockRule,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$BlockAttemptsTableCreateCompanionBuilder =
    BlockAttemptsCompanion Function({
      Value<int> id,
      required String domain,
      required int attemptedAt,
    });
typedef $$BlockAttemptsTableUpdateCompanionBuilder =
    BlockAttemptsCompanion Function({
      Value<int> id,
      Value<String> domain,
      Value<int> attemptedAt,
    });

class $$BlockAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableFilterComposer({
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

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockAttemptsTable> {
  $$BlockAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => column,
  );
}

class $$BlockAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockAttemptsTable,
          BlockAttempt,
          $$BlockAttemptsTableFilterComposer,
          $$BlockAttemptsTableOrderingComposer,
          $$BlockAttemptsTableAnnotationComposer,
          $$BlockAttemptsTableCreateCompanionBuilder,
          $$BlockAttemptsTableUpdateCompanionBuilder,
          (
            BlockAttempt,
            BaseReferences<_$AppDatabase, $BlockAttemptsTable, BlockAttempt>,
          ),
          BlockAttempt,
          PrefetchHooks Function()
        > {
  $$BlockAttemptsTableTableManager(_$AppDatabase db, $BlockAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<int> attemptedAt = const Value.absent(),
              }) => BlockAttemptsCompanion(
                id: id,
                domain: domain,
                attemptedAt: attemptedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String domain,
                required int attemptedAt,
              }) => BlockAttemptsCompanion.insert(
                id: id,
                domain: domain,
                attemptedAt: attemptedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockAttemptsTable,
      BlockAttempt,
      $$BlockAttemptsTableFilterComposer,
      $$BlockAttemptsTableOrderingComposer,
      $$BlockAttemptsTableAnnotationComposer,
      $$BlockAttemptsTableCreateCompanionBuilder,
      $$BlockAttemptsTableUpdateCompanionBuilder,
      (
        BlockAttempt,
        BaseReferences<_$AppDatabase, $BlockAttemptsTable, BlockAttempt>,
      ),
      BlockAttempt,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BlockRulesTableTableManager get blockRules =>
      $$BlockRulesTableTableManager(_db, _db.blockRules);
  $$BlockAttemptsTableTableManager get blockAttempts =>
      $$BlockAttemptsTableTableManager(_db, _db.blockAttempts);
}
