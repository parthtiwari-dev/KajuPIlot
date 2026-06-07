// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessNameMeta =
      const VerificationMeta('businessName');
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
      'business_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceTokenMeta =
      const VerificationMeta('deviceToken');
  @override
  late final GeneratedColumn<String> deviceToken = GeneratedColumn<String>(
      'device_token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OWNER'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, businessName, deviceToken, role, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
          _businessNameMeta,
          businessName.isAcceptableOrUnknown(
              data['business_name']!, _businessNameMeta));
    }
    if (data.containsKey('device_token')) {
      context.handle(
          _deviceTokenMeta,
          deviceToken.isAcceptableOrUnknown(
              data['device_token']!, _deviceTokenMeta));
    } else if (isInserting) {
      context.missing(_deviceTokenMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      businessName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_name']),
      deviceToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_token'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String name;
  final String? businessName;
  final String deviceToken;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUser(
      {required this.id,
      required this.name,
      this.businessName,
      required this.deviceToken,
      required this.role,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || businessName != null) {
      map['business_name'] = Variable<String>(businessName);
    }
    map['device_token'] = Variable<String>(deviceToken);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      businessName: businessName == null && nullToAbsent
          ? const Value.absent()
          : Value(businessName),
      deviceToken: Value(deviceToken),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      businessName: serializer.fromJson<String?>(json['businessName']),
      deviceToken: serializer.fromJson<String>(json['deviceToken']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'businessName': serializer.toJson<String?>(businessName),
      'deviceToken': serializer.toJson<String>(deviceToken),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUser copyWith(
          {String? id,
          String? name,
          Value<String?> businessName = const Value.absent(),
          String? deviceToken,
          String? role,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalUser(
        id: id ?? this.id,
        name: name ?? this.name,
        businessName:
            businessName.present ? businessName.value : this.businessName,
        deviceToken: deviceToken ?? this.deviceToken,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      deviceToken:
          data.deviceToken.present ? data.deviceToken.value : this.deviceToken,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('businessName: $businessName, ')
          ..write('deviceToken: $deviceToken, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, businessName, deviceToken, role, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.businessName == this.businessName &&
          other.deviceToken == this.deviceToken &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> businessName;
  final Value<String> deviceToken;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.businessName = const Value.absent(),
    this.deviceToken = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String name,
    this.businessName = const Value.absent(),
    required String deviceToken,
    this.role = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        deviceToken = Value(deviceToken),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? businessName,
    Expression<String>? deviceToken,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (businessName != null) 'business_name': businessName,
      if (deviceToken != null) 'device_token': deviceToken,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? businessName,
      Value<String>? deviceToken,
      Value<String>? role,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      deviceToken: deviceToken ?? this.deviceToken,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (deviceToken.present) {
      map['device_token'] = Variable<String>(deviceToken.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('businessName: $businessName, ')
          ..write('deviceToken: $deviceToken, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('CUSTOMER'));
  static const VerificationMeta _trustTagMeta =
      const VerificationMeta('trustTag');
  @override
  late final GeneratedColumn<String> trustTag = GeneratedColumn<String>(
      'trust_tag', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('NEW'));
  static const VerificationMeta _trustTagManualOverrideMeta =
      const VerificationMeta('trustTagManualOverride');
  @override
  late final GeneratedColumn<bool> trustTagManualOverride =
      GeneratedColumn<bool>('trust_tag_manual_override', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("trust_tag_manual_override" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        phone,
        type,
        trustTag,
        trustTagManualOverride,
        notes,
        syncId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(Insertable<Party> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('trust_tag')) {
      context.handle(_trustTagMeta,
          trustTag.isAcceptableOrUnknown(data['trust_tag']!, _trustTagMeta));
    }
    if (data.containsKey('trust_tag_manual_override')) {
      context.handle(
          _trustTagManualOverrideMeta,
          trustTagManualOverride.isAcceptableOrUnknown(
              data['trust_tag_manual_override']!, _trustTagManualOverrideMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      trustTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trust_tag'])!,
      trustTagManualOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}trust_tag_manual_override'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String userId;
  final String name;
  final String? phone;
  final String type;
  final String trustTag;
  final bool trustTagManualOverride;
  final String? notes;
  final String syncId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Party(
      {required this.id,
      required this.userId,
      required this.name,
      this.phone,
      required this.type,
      required this.trustTag,
      required this.trustTagManualOverride,
      this.notes,
      required this.syncId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['type'] = Variable<String>(type);
    map['trust_tag'] = Variable<String>(trustTag);
    map['trust_tag_manual_override'] = Variable<bool>(trustTagManualOverride);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      type: Value(type),
      trustTag: Value(trustTag),
      trustTagManualOverride: Value(trustTagManualOverride),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Party.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      type: serializer.fromJson<String>(json['type']),
      trustTag: serializer.fromJson<String>(json['trustTag']),
      trustTagManualOverride:
          serializer.fromJson<bool>(json['trustTagManualOverride']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'type': serializer.toJson<String>(type),
      'trustTag': serializer.toJson<String>(trustTag),
      'trustTagManualOverride': serializer.toJson<bool>(trustTagManualOverride),
      'notes': serializer.toJson<String?>(notes),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Party copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> phone = const Value.absent(),
          String? type,
          String? trustTag,
          bool? trustTagManualOverride,
          Value<String?> notes = const Value.absent(),
          String? syncId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Party(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        type: type ?? this.type,
        trustTag: trustTag ?? this.trustTag,
        trustTagManualOverride:
            trustTagManualOverride ?? this.trustTagManualOverride,
        notes: notes.present ? notes.value : this.notes,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      type: data.type.present ? data.type.value : this.type,
      trustTag: data.trustTag.present ? data.trustTag.value : this.trustTag,
      trustTagManualOverride: data.trustTagManualOverride.present
          ? data.trustTagManualOverride.value
          : this.trustTagManualOverride,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('type: $type, ')
          ..write('trustTag: $trustTag, ')
          ..write('trustTagManualOverride: $trustTagManualOverride, ')
          ..write('notes: $notes, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, phone, type, trustTag,
      trustTagManualOverride, notes, syncId, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.type == this.type &&
          other.trustTag == this.trustTag &&
          other.trustTagManualOverride == this.trustTagManualOverride &&
          other.notes == this.notes &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String> type;
  final Value<String> trustTag;
  final Value<bool> trustTagManualOverride;
  final Value<String?> notes;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.type = const Value.absent(),
    this.trustTag = const Value.absent(),
    this.trustTagManualOverride = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.phone = const Value.absent(),
    this.type = const Value.absent(),
    this.trustTag = const Value.absent(),
    this.trustTagManualOverride = const Value.absent(),
    this.notes = const Value.absent(),
    required String syncId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? type,
    Expression<String>? trustTag,
    Expression<bool>? trustTagManualOverride,
    Expression<String>? notes,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (type != null) 'type': type,
      if (trustTag != null) 'trust_tag': trustTag,
      if (trustTagManualOverride != null)
        'trust_tag_manual_override': trustTagManualOverride,
      if (notes != null) 'notes': notes,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? phone,
      Value<String>? type,
      Value<String>? trustTag,
      Value<bool>? trustTagManualOverride,
      Value<String?>? notes,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return PartiesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      trustTag: trustTag ?? this.trustTag,
      trustTagManualOverride:
          trustTagManualOverride ?? this.trustTagManualOverride,
      notes: notes ?? this.notes,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (trustTag.present) {
      map['trust_tag'] = Variable<String>(trustTag.value);
    }
    if (trustTagManualOverride.present) {
      map['trust_tag_manual_override'] =
          Variable<bool>(trustTagManualOverride.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('type: $type, ')
          ..write('trustTag: $trustTag, ')
          ..write('trustTagManualOverride: $trustTagManualOverride, ')
          ..write('notes: $notes, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealsTable extends Deals with TableInfo<$DealsTable, Deal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('SALE'));
  static const VerificationMeta _cashewGradeMeta =
      const VerificationMeta('cashewGrade');
  @override
  late final GeneratedColumn<String> cashewGrade = GeneratedColumn<String>(
      'cashew_grade', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityGramsMeta =
      const VerificationMeta('quantityGrams');
  @override
  late final GeneratedColumn<int> quantityGrams = GeneratedColumn<int>(
      'quantity_grams', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ratePaisePerKgMeta =
      const VerificationMeta('ratePaisePerKg');
  @override
  late final GeneratedColumn<int> ratePaisePerKg = GeneratedColumn<int>(
      'rate_paise_per_kg', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalPaiseMeta =
      const VerificationMeta('totalPaise');
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
      'total_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paidPaiseMeta =
      const VerificationMeta('paidPaise');
  @override
  late final GeneratedColumn<int> paidPaise = GeneratedColumn<int>(
      'paid_paise', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('CONFIRMED'));
  static const VerificationMeta _deliveryDateMeta =
      const VerificationMeta('deliveryDate');
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
      'delivery_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _paymentDueMeta =
      const VerificationMeta('paymentDue');
  @override
  late final GeneratedColumn<DateTime> paymentDue = GeneratedColumn<DateTime>(
      'payment_due', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        partyId,
        type,
        cashewGrade,
        quantityGrams,
        ratePaisePerKg,
        totalPaise,
        paidPaise,
        status,
        deliveryDate,
        paymentDue,
        notes,
        syncId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deals';
  @override
  VerificationContext validateIntegrity(Insertable<Deal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('cashew_grade')) {
      context.handle(
          _cashewGradeMeta,
          cashewGrade.isAcceptableOrUnknown(
              data['cashew_grade']!, _cashewGradeMeta));
    } else if (isInserting) {
      context.missing(_cashewGradeMeta);
    }
    if (data.containsKey('quantity_grams')) {
      context.handle(
          _quantityGramsMeta,
          quantityGrams.isAcceptableOrUnknown(
              data['quantity_grams']!, _quantityGramsMeta));
    } else if (isInserting) {
      context.missing(_quantityGramsMeta);
    }
    if (data.containsKey('rate_paise_per_kg')) {
      context.handle(
          _ratePaisePerKgMeta,
          ratePaisePerKg.isAcceptableOrUnknown(
              data['rate_paise_per_kg']!, _ratePaisePerKgMeta));
    } else if (isInserting) {
      context.missing(_ratePaisePerKgMeta);
    }
    if (data.containsKey('total_paise')) {
      context.handle(
          _totalPaiseMeta,
          totalPaise.isAcceptableOrUnknown(
              data['total_paise']!, _totalPaiseMeta));
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('paid_paise')) {
      context.handle(_paidPaiseMeta,
          paidPaise.isAcceptableOrUnknown(data['paid_paise']!, _paidPaiseMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
          _deliveryDateMeta,
          deliveryDate.isAcceptableOrUnknown(
              data['delivery_date']!, _deliveryDateMeta));
    }
    if (data.containsKey('payment_due')) {
      context.handle(
          _paymentDueMeta,
          paymentDue.isAcceptableOrUnknown(
              data['payment_due']!, _paymentDueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      cashewGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cashew_grade'])!,
      quantityGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_grams'])!,
      ratePaisePerKg: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rate_paise_per_kg'])!,
      totalPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_paise'])!,
      paidPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_paise'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      deliveryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}delivery_date']),
      paymentDue: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_due']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DealsTable createAlias(String alias) {
    return $DealsTable(attachedDatabase, alias);
  }
}

class Deal extends DataClass implements Insertable<Deal> {
  final String id;
  final String userId;
  final String partyId;
  final String type;
  final String cashewGrade;
  final int quantityGrams;
  final int ratePaisePerKg;
  final int totalPaise;
  final int paidPaise;
  final String status;
  final DateTime? deliveryDate;
  final DateTime? paymentDue;
  final String? notes;
  final String syncId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Deal(
      {required this.id,
      required this.userId,
      required this.partyId,
      required this.type,
      required this.cashewGrade,
      required this.quantityGrams,
      required this.ratePaisePerKg,
      required this.totalPaise,
      required this.paidPaise,
      required this.status,
      this.deliveryDate,
      this.paymentDue,
      this.notes,
      required this.syncId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['party_id'] = Variable<String>(partyId);
    map['type'] = Variable<String>(type);
    map['cashew_grade'] = Variable<String>(cashewGrade);
    map['quantity_grams'] = Variable<int>(quantityGrams);
    map['rate_paise_per_kg'] = Variable<int>(ratePaisePerKg);
    map['total_paise'] = Variable<int>(totalPaise);
    map['paid_paise'] = Variable<int>(paidPaise);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deliveryDate != null) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate);
    }
    if (!nullToAbsent || paymentDue != null) {
      map['payment_due'] = Variable<DateTime>(paymentDue);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DealsCompanion toCompanion(bool nullToAbsent) {
    return DealsCompanion(
      id: Value(id),
      userId: Value(userId),
      partyId: Value(partyId),
      type: Value(type),
      cashewGrade: Value(cashewGrade),
      quantityGrams: Value(quantityGrams),
      ratePaisePerKg: Value(ratePaisePerKg),
      totalPaise: Value(totalPaise),
      paidPaise: Value(paidPaise),
      status: Value(status),
      deliveryDate: deliveryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDate),
      paymentDue: paymentDue == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Deal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deal(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      partyId: serializer.fromJson<String>(json['partyId']),
      type: serializer.fromJson<String>(json['type']),
      cashewGrade: serializer.fromJson<String>(json['cashewGrade']),
      quantityGrams: serializer.fromJson<int>(json['quantityGrams']),
      ratePaisePerKg: serializer.fromJson<int>(json['ratePaisePerKg']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      paidPaise: serializer.fromJson<int>(json['paidPaise']),
      status: serializer.fromJson<String>(json['status']),
      deliveryDate: serializer.fromJson<DateTime?>(json['deliveryDate']),
      paymentDue: serializer.fromJson<DateTime?>(json['paymentDue']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'partyId': serializer.toJson<String>(partyId),
      'type': serializer.toJson<String>(type),
      'cashewGrade': serializer.toJson<String>(cashewGrade),
      'quantityGrams': serializer.toJson<int>(quantityGrams),
      'ratePaisePerKg': serializer.toJson<int>(ratePaisePerKg),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'paidPaise': serializer.toJson<int>(paidPaise),
      'status': serializer.toJson<String>(status),
      'deliveryDate': serializer.toJson<DateTime?>(deliveryDate),
      'paymentDue': serializer.toJson<DateTime?>(paymentDue),
      'notes': serializer.toJson<String?>(notes),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Deal copyWith(
          {String? id,
          String? userId,
          String? partyId,
          String? type,
          String? cashewGrade,
          int? quantityGrams,
          int? ratePaisePerKg,
          int? totalPaise,
          int? paidPaise,
          String? status,
          Value<DateTime?> deliveryDate = const Value.absent(),
          Value<DateTime?> paymentDue = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? syncId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Deal(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        partyId: partyId ?? this.partyId,
        type: type ?? this.type,
        cashewGrade: cashewGrade ?? this.cashewGrade,
        quantityGrams: quantityGrams ?? this.quantityGrams,
        ratePaisePerKg: ratePaisePerKg ?? this.ratePaisePerKg,
        totalPaise: totalPaise ?? this.totalPaise,
        paidPaise: paidPaise ?? this.paidPaise,
        status: status ?? this.status,
        deliveryDate:
            deliveryDate.present ? deliveryDate.value : this.deliveryDate,
        paymentDue: paymentDue.present ? paymentDue.value : this.paymentDue,
        notes: notes.present ? notes.value : this.notes,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Deal copyWithCompanion(DealsCompanion data) {
    return Deal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      type: data.type.present ? data.type.value : this.type,
      cashewGrade:
          data.cashewGrade.present ? data.cashewGrade.value : this.cashewGrade,
      quantityGrams: data.quantityGrams.present
          ? data.quantityGrams.value
          : this.quantityGrams,
      ratePaisePerKg: data.ratePaisePerKg.present
          ? data.ratePaisePerKg.value
          : this.ratePaisePerKg,
      totalPaise:
          data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      paidPaise: data.paidPaise.present ? data.paidPaise.value : this.paidPaise,
      status: data.status.present ? data.status.value : this.status,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      paymentDue:
          data.paymentDue.present ? data.paymentDue.value : this.paymentDue,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('type: $type, ')
          ..write('cashewGrade: $cashewGrade, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('ratePaisePerKg: $ratePaisePerKg, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('paymentDue: $paymentDue, ')
          ..write('notes: $notes, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      partyId,
      type,
      cashewGrade,
      quantityGrams,
      ratePaisePerKg,
      totalPaise,
      paidPaise,
      status,
      deliveryDate,
      paymentDue,
      notes,
      syncId,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.partyId == this.partyId &&
          other.type == this.type &&
          other.cashewGrade == this.cashewGrade &&
          other.quantityGrams == this.quantityGrams &&
          other.ratePaisePerKg == this.ratePaisePerKg &&
          other.totalPaise == this.totalPaise &&
          other.paidPaise == this.paidPaise &&
          other.status == this.status &&
          other.deliveryDate == this.deliveryDate &&
          other.paymentDue == this.paymentDue &&
          other.notes == this.notes &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DealsCompanion extends UpdateCompanion<Deal> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> partyId;
  final Value<String> type;
  final Value<String> cashewGrade;
  final Value<int> quantityGrams;
  final Value<int> ratePaisePerKg;
  final Value<int> totalPaise;
  final Value<int> paidPaise;
  final Value<String> status;
  final Value<DateTime?> deliveryDate;
  final Value<DateTime?> paymentDue;
  final Value<String?> notes;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DealsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.type = const Value.absent(),
    this.cashewGrade = const Value.absent(),
    this.quantityGrams = const Value.absent(),
    this.ratePaisePerKg = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.paymentDue = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealsCompanion.insert({
    required String id,
    required String userId,
    required String partyId,
    this.type = const Value.absent(),
    required String cashewGrade,
    required int quantityGrams,
    required int ratePaisePerKg,
    required int totalPaise,
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.paymentDue = const Value.absent(),
    this.notes = const Value.absent(),
    required String syncId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        partyId = Value(partyId),
        cashewGrade = Value(cashewGrade),
        quantityGrams = Value(quantityGrams),
        ratePaisePerKg = Value(ratePaisePerKg),
        totalPaise = Value(totalPaise),
        syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Deal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? partyId,
    Expression<String>? type,
    Expression<String>? cashewGrade,
    Expression<int>? quantityGrams,
    Expression<int>? ratePaisePerKg,
    Expression<int>? totalPaise,
    Expression<int>? paidPaise,
    Expression<String>? status,
    Expression<DateTime>? deliveryDate,
    Expression<DateTime>? paymentDue,
    Expression<String>? notes,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (partyId != null) 'party_id': partyId,
      if (type != null) 'type': type,
      if (cashewGrade != null) 'cashew_grade': cashewGrade,
      if (quantityGrams != null) 'quantity_grams': quantityGrams,
      if (ratePaisePerKg != null) 'rate_paise_per_kg': ratePaisePerKg,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (paidPaise != null) 'paid_paise': paidPaise,
      if (status != null) 'status': status,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (paymentDue != null) 'payment_due': paymentDue,
      if (notes != null) 'notes': notes,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? partyId,
      Value<String>? type,
      Value<String>? cashewGrade,
      Value<int>? quantityGrams,
      Value<int>? ratePaisePerKg,
      Value<int>? totalPaise,
      Value<int>? paidPaise,
      Value<String>? status,
      Value<DateTime?>? deliveryDate,
      Value<DateTime?>? paymentDue,
      Value<String?>? notes,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return DealsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyId: partyId ?? this.partyId,
      type: type ?? this.type,
      cashewGrade: cashewGrade ?? this.cashewGrade,
      quantityGrams: quantityGrams ?? this.quantityGrams,
      ratePaisePerKg: ratePaisePerKg ?? this.ratePaisePerKg,
      totalPaise: totalPaise ?? this.totalPaise,
      paidPaise: paidPaise ?? this.paidPaise,
      status: status ?? this.status,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentDue: paymentDue ?? this.paymentDue,
      notes: notes ?? this.notes,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cashewGrade.present) {
      map['cashew_grade'] = Variable<String>(cashewGrade.value);
    }
    if (quantityGrams.present) {
      map['quantity_grams'] = Variable<int>(quantityGrams.value);
    }
    if (ratePaisePerKg.present) {
      map['rate_paise_per_kg'] = Variable<int>(ratePaisePerKg.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (paidPaise.present) {
      map['paid_paise'] = Variable<int>(paidPaise.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (paymentDue.present) {
      map['payment_due'] = Variable<DateTime>(paymentDue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('type: $type, ')
          ..write('cashewGrade: $cashewGrade, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('ratePaisePerKg: $ratePaisePerKg, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('paymentDue: $paymentDue, ')
          ..write('notes: $notes, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealItemsTable extends DealItems
    with TableInfo<$DealItemsTable, DealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
      'deal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityTextMeta =
      const VerificationMeta('quantityText');
  @override
  late final GeneratedColumn<String> quantityText = GeneratedColumn<String>(
      'quantity_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateTextMeta =
      const VerificationMeta('rateText');
  @override
  late final GeneratedColumn<String> rateText = GeneratedColumn<String>(
      'rate_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lineTotalPaiseMeta =
      const VerificationMeta('lineTotalPaise');
  @override
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
      'line_total_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dealId,
        grade,
        quantityText,
        rateText,
        lineTotalPaise,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deal_items';
  @override
  VerificationContext validateIntegrity(Insertable<DealItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deal_id')) {
      context.handle(_dealIdMeta,
          dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta));
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('quantity_text')) {
      context.handle(
          _quantityTextMeta,
          quantityText.isAcceptableOrUnknown(
              data['quantity_text']!, _quantityTextMeta));
    } else if (isInserting) {
      context.missing(_quantityTextMeta);
    }
    if (data.containsKey('rate_text')) {
      context.handle(_rateTextMeta,
          rateText.isAcceptableOrUnknown(data['rate_text']!, _rateTextMeta));
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
          _lineTotalPaiseMeta,
          lineTotalPaise.isAcceptableOrUnknown(
              data['line_total_paise']!, _lineTotalPaiseMeta));
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dealId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deal_id'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade'])!,
      quantityText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity_text'])!,
      rateText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_text']),
      lineTotalPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_total_paise'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DealItemsTable createAlias(String alias) {
    return $DealItemsTable(attachedDatabase, alias);
  }
}

class DealItem extends DataClass implements Insertable<DealItem> {
  final String id;
  final String dealId;
  final String grade;
  final String quantityText;
  final String? rateText;
  final int lineTotalPaise;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DealItem(
      {required this.id,
      required this.dealId,
      required this.grade,
      required this.quantityText,
      this.rateText,
      required this.lineTotalPaise,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deal_id'] = Variable<String>(dealId);
    map['grade'] = Variable<String>(grade);
    map['quantity_text'] = Variable<String>(quantityText);
    if (!nullToAbsent || rateText != null) {
      map['rate_text'] = Variable<String>(rateText);
    }
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DealItemsCompanion toCompanion(bool nullToAbsent) {
    return DealItemsCompanion(
      id: Value(id),
      dealId: Value(dealId),
      grade: Value(grade),
      quantityText: Value(quantityText),
      rateText: rateText == null && nullToAbsent
          ? const Value.absent()
          : Value(rateText),
      lineTotalPaise: Value(lineTotalPaise),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DealItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealItem(
      id: serializer.fromJson<String>(json['id']),
      dealId: serializer.fromJson<String>(json['dealId']),
      grade: serializer.fromJson<String>(json['grade']),
      quantityText: serializer.fromJson<String>(json['quantityText']),
      rateText: serializer.fromJson<String?>(json['rateText']),
      lineTotalPaise: serializer.fromJson<int>(json['lineTotalPaise']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dealId': serializer.toJson<String>(dealId),
      'grade': serializer.toJson<String>(grade),
      'quantityText': serializer.toJson<String>(quantityText),
      'rateText': serializer.toJson<String?>(rateText),
      'lineTotalPaise': serializer.toJson<int>(lineTotalPaise),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DealItem copyWith(
          {String? id,
          String? dealId,
          String? grade,
          String? quantityText,
          Value<String?> rateText = const Value.absent(),
          int? lineTotalPaise,
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DealItem(
        id: id ?? this.id,
        dealId: dealId ?? this.dealId,
        grade: grade ?? this.grade,
        quantityText: quantityText ?? this.quantityText,
        rateText: rateText.present ? rateText.value : this.rateText,
        lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DealItem copyWithCompanion(DealItemsCompanion data) {
    return DealItem(
      id: data.id.present ? data.id.value : this.id,
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      grade: data.grade.present ? data.grade.value : this.grade,
      quantityText: data.quantityText.present
          ? data.quantityText.value
          : this.quantityText,
      rateText: data.rateText.present ? data.rateText.value : this.rateText,
      lineTotalPaise: data.lineTotalPaise.present
          ? data.lineTotalPaise.value
          : this.lineTotalPaise,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealItem(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('grade: $grade, ')
          ..write('quantityText: $quantityText, ')
          ..write('rateText: $rateText, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dealId, grade, quantityText, rateText,
      lineTotalPaise, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealItem &&
          other.id == this.id &&
          other.dealId == this.dealId &&
          other.grade == this.grade &&
          other.quantityText == this.quantityText &&
          other.rateText == this.rateText &&
          other.lineTotalPaise == this.lineTotalPaise &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DealItemsCompanion extends UpdateCompanion<DealItem> {
  final Value<String> id;
  final Value<String> dealId;
  final Value<String> grade;
  final Value<String> quantityText;
  final Value<String?> rateText;
  final Value<int> lineTotalPaise;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DealItemsCompanion({
    this.id = const Value.absent(),
    this.dealId = const Value.absent(),
    this.grade = const Value.absent(),
    this.quantityText = const Value.absent(),
    this.rateText = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealItemsCompanion.insert({
    required String id,
    required String dealId,
    required String grade,
    required String quantityText,
    this.rateText = const Value.absent(),
    required int lineTotalPaise,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dealId = Value(dealId),
        grade = Value(grade),
        quantityText = Value(quantityText),
        lineTotalPaise = Value(lineTotalPaise),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DealItem> custom({
    Expression<String>? id,
    Expression<String>? dealId,
    Expression<String>? grade,
    Expression<String>? quantityText,
    Expression<String>? rateText,
    Expression<int>? lineTotalPaise,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dealId != null) 'deal_id': dealId,
      if (grade != null) 'grade': grade,
      if (quantityText != null) 'quantity_text': quantityText,
      if (rateText != null) 'rate_text': rateText,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dealId,
      Value<String>? grade,
      Value<String>? quantityText,
      Value<String?>? rateText,
      Value<int>? lineTotalPaise,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DealItemsCompanion(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      grade: grade ?? this.grade,
      quantityText: quantityText ?? this.quantityText,
      rateText: rateText ?? this.rateText,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (quantityText.present) {
      map['quantity_text'] = Variable<String>(quantityText.value);
    }
    if (rateText.present) {
      map['rate_text'] = Variable<String>(rateText.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealItemsCompanion(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('grade: $grade, ')
          ..write('quantityText: $quantityText, ')
          ..write('rateText: $rateText, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
      'deal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPaiseMeta =
      const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
      'amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        partyId,
        dealId,
        type,
        amountPaise,
        method,
        notes,
        paymentDate,
        syncId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('deal_id')) {
      context.handle(_dealIdMeta,
          dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
          _amountPaiseMeta,
          amountPaise.isAcceptableOrUnknown(
              data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id'])!,
      dealId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deal_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String userId;
  final String partyId;
  final String? dealId;
  final String type;
  final int amountPaise;
  final String? method;
  final String? notes;
  final DateTime paymentDate;
  final String syncId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Payment(
      {required this.id,
      required this.userId,
      required this.partyId,
      this.dealId,
      required this.type,
      required this.amountPaise,
      this.method,
      this.notes,
      required this.paymentDate,
      required this.syncId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['party_id'] = Variable<String>(partyId);
    if (!nullToAbsent || dealId != null) {
      map['deal_id'] = Variable<String>(dealId);
    }
    map['type'] = Variable<String>(type);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      userId: Value(userId),
      partyId: Value(partyId),
      dealId:
          dealId == null && nullToAbsent ? const Value.absent() : Value(dealId),
      type: Value(type),
      amountPaise: Value(amountPaise),
      method:
          method == null && nullToAbsent ? const Value.absent() : Value(method),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      paymentDate: Value(paymentDate),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      partyId: serializer.fromJson<String>(json['partyId']),
      dealId: serializer.fromJson<String?>(json['dealId']),
      type: serializer.fromJson<String>(json['type']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      method: serializer.fromJson<String?>(json['method']),
      notes: serializer.fromJson<String?>(json['notes']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'partyId': serializer.toJson<String>(partyId),
      'dealId': serializer.toJson<String?>(dealId),
      'type': serializer.toJson<String>(type),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'method': serializer.toJson<String?>(method),
      'notes': serializer.toJson<String?>(notes),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Payment copyWith(
          {String? id,
          String? userId,
          String? partyId,
          Value<String?> dealId = const Value.absent(),
          String? type,
          int? amountPaise,
          Value<String?> method = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? paymentDate,
          String? syncId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        partyId: partyId ?? this.partyId,
        dealId: dealId.present ? dealId.value : this.dealId,
        type: type ?? this.type,
        amountPaise: amountPaise ?? this.amountPaise,
        method: method.present ? method.value : this.method,
        notes: notes.present ? notes.value : this.notes,
        paymentDate: paymentDate ?? this.paymentDate,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      type: data.type.present ? data.type.value : this.type,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      method: data.method.present ? data.method.value : this.method,
      notes: data.notes.present ? data.notes.value : this.notes,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('dealId: $dealId, ')
          ..write('type: $type, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('notes: $notes, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      partyId,
      dealId,
      type,
      amountPaise,
      method,
      notes,
      paymentDate,
      syncId,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.partyId == this.partyId &&
          other.dealId == this.dealId &&
          other.type == this.type &&
          other.amountPaise == this.amountPaise &&
          other.method == this.method &&
          other.notes == this.notes &&
          other.paymentDate == this.paymentDate &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> partyId;
  final Value<String?> dealId;
  final Value<String> type;
  final Value<int> amountPaise;
  final Value<String?> method;
  final Value<String?> notes;
  final Value<DateTime> paymentDate;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.dealId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.method = const Value.absent(),
    this.notes = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String userId,
    required String partyId,
    this.dealId = const Value.absent(),
    required String type,
    required int amountPaise,
    this.method = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime paymentDate,
    required String syncId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        partyId = Value(partyId),
        type = Value(type),
        amountPaise = Value(amountPaise),
        paymentDate = Value(paymentDate),
        syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? partyId,
    Expression<String>? dealId,
    Expression<String>? type,
    Expression<int>? amountPaise,
    Expression<String>? method,
    Expression<String>? notes,
    Expression<DateTime>? paymentDate,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (partyId != null) 'party_id': partyId,
      if (dealId != null) 'deal_id': dealId,
      if (type != null) 'type': type,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (method != null) 'method': method,
      if (notes != null) 'notes': notes,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? partyId,
      Value<String?>? dealId,
      Value<String>? type,
      Value<int>? amountPaise,
      Value<String?>? method,
      Value<String?>? notes,
      Value<DateTime>? paymentDate,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyId: partyId ?? this.partyId,
      dealId: dealId ?? this.dealId,
      type: type ?? this.type,
      amountPaise: amountPaise ?? this.amountPaise,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('dealId: $dealId, ')
          ..write('type: $type, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('notes: $notes, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('BUSINESS'));
  static const VerificationMeta _amountPaiseMeta =
      const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
      'amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        category,
        scope,
        amountPaise,
        notes,
        expenseDate,
        syncId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
          _amountPaiseMeta,
          amountPaise.isAcceptableOrUnknown(
              data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      amountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String userId;
  final String category;
  final String scope;
  final int amountPaise;
  final String? notes;
  final DateTime expenseDate;
  final String syncId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Expense(
      {required this.id,
      required this.userId,
      required this.category,
      required this.scope,
      required this.amountPaise,
      this.notes,
      required this.expenseDate,
      required this.syncId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['category'] = Variable<String>(category);
    map['scope'] = Variable<String>(scope);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['expense_date'] = Variable<DateTime>(expenseDate);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      userId: Value(userId),
      category: Value(category),
      scope: Value(scope),
      amountPaise: Value(amountPaise),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      expenseDate: Value(expenseDate),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      category: serializer.fromJson<String>(json['category']),
      scope: serializer.fromJson<String>(json['scope']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      notes: serializer.fromJson<String?>(json['notes']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'category': serializer.toJson<String>(category),
      'scope': serializer.toJson<String>(scope),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'notes': serializer.toJson<String?>(notes),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Expense copyWith(
          {String? id,
          String? userId,
          String? category,
          String? scope,
          int? amountPaise,
          Value<String?> notes = const Value.absent(),
          DateTime? expenseDate,
          String? syncId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        category: category ?? this.category,
        scope: scope ?? this.scope,
        amountPaise: amountPaise ?? this.amountPaise,
        notes: notes.present ? notes.value : this.notes,
        expenseDate: expenseDate ?? this.expenseDate,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      category: data.category.present ? data.category.value : this.category,
      scope: data.scope.present ? data.scope.value : this.scope,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      notes: data.notes.present ? data.notes.value : this.notes,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('scope: $scope, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('notes: $notes, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, category, scope, amountPaise,
      notes, expenseDate, syncId, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.category == this.category &&
          other.scope == this.scope &&
          other.amountPaise == this.amountPaise &&
          other.notes == this.notes &&
          other.expenseDate == this.expenseDate &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> category;
  final Value<String> scope;
  final Value<int> amountPaise;
  final Value<String?> notes;
  final Value<DateTime> expenseDate;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.scope = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String userId,
    required String category,
    this.scope = const Value.absent(),
    required int amountPaise,
    this.notes = const Value.absent(),
    required DateTime expenseDate,
    required String syncId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        category = Value(category),
        amountPaise = Value(amountPaise),
        expenseDate = Value(expenseDate),
        syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? category,
    Expression<String>? scope,
    Expression<int>? amountPaise,
    Expression<String>? notes,
    Expression<DateTime>? expenseDate,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (category != null) 'category': category,
      if (scope != null) 'scope': scope,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (notes != null) 'notes': notes,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? category,
      Value<String>? scope,
      Value<int>? amountPaise,
      Value<String?>? notes,
      Value<DateTime>? expenseDate,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      scope: scope ?? this.scope,
      amountPaise: amountPaise ?? this.amountPaise,
      notes: notes ?? this.notes,
      expenseDate: expenseDate ?? this.expenseDate,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('scope: $scope, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('notes: $notes, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        partyId,
        type,
        title,
        notes,
        scheduledAt,
        completedAt,
        status,
        priority,
        syncId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String userId;
  final String? partyId;
  final String type;
  final String title;
  final String? notes;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final String status;
  final int priority;
  final String syncId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Task(
      {required this.id,
      required this.userId,
      this.partyId,
      required this.type,
      required this.title,
      this.notes,
      required this.scheduledAt,
      this.completedAt,
      required this.status,
      required this.priority,
      required this.syncId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      type: Value(type),
      title: Value(title),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      scheduledAt: Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      priority: Value(priority),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'partyId': serializer.toJson<String?>(partyId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Task copyWith(
          {String? id,
          String? userId,
          Value<String?> partyId = const Value.absent(),
          String? type,
          String? title,
          Value<String?> notes = const Value.absent(),
          DateTime? scheduledAt,
          Value<DateTime?> completedAt = const Value.absent(),
          String? status,
          int? priority,
          String? syncId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        partyId: partyId.present ? partyId.value : this.partyId,
        type: type ?? this.type,
        title: title ?? this.title,
        notes: notes.present ? notes.value : this.notes,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      partyId,
      type,
      title,
      notes,
      scheduledAt,
      completedAt,
      status,
      priority,
      syncId,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.partyId == this.partyId &&
          other.type == this.type &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> partyId;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> notes;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> completedAt;
  final Value<String> status;
  final Value<int> priority;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String userId,
    this.partyId = const Value.absent(),
    required String type,
    required String title,
    this.notes = const Value.absent(),
    required DateTime scheduledAt,
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    required String syncId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        type = Value(type),
        title = Value(title),
        scheduledAt = Value(scheduledAt),
        syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? partyId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (partyId != null) 'party_id': partyId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? partyId,
      Value<String>? type,
      Value<String>? title,
      Value<String?>? notes,
      Value<DateTime>? scheduledAt,
      Value<DateTime?>? completedAt,
      Value<String>? status,
      Value<int>? priority,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyId: partyId ?? this.partyId,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('partyId: $partyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallLogsTable extends CallLogs with TableInfo<$CallLogsTable, CallLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _promisedDateMeta =
      const VerificationMeta('promisedDate');
  @override
  late final GeneratedColumn<DateTime> promisedDate = GeneratedColumn<DateTime>(
      'promised_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _promisedAmountPaiseMeta =
      const VerificationMeta('promisedAmountPaise');
  @override
  late final GeneratedColumn<int> promisedAmountPaise = GeneratedColumn<int>(
      'promised_amount_paise', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nextFollowupMeta =
      const VerificationMeta('nextFollowup');
  @override
  late final GeneratedColumn<DateTime> nextFollowup = GeneratedColumn<DateTime>(
      'next_followup', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        taskId,
        partyId,
        outcome,
        notes,
        promisedDate,
        promisedAmountPaise,
        nextFollowup,
        syncId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_logs';
  @override
  VerificationContext validateIntegrity(Insertable<CallLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('promised_date')) {
      context.handle(
          _promisedDateMeta,
          promisedDate.isAcceptableOrUnknown(
              data['promised_date']!, _promisedDateMeta));
    }
    if (data.containsKey('promised_amount_paise')) {
      context.handle(
          _promisedAmountPaiseMeta,
          promisedAmountPaise.isAcceptableOrUnknown(
              data['promised_amount_paise']!, _promisedAmountPaiseMeta));
    }
    if (data.containsKey('next_followup')) {
      context.handle(
          _nextFollowupMeta,
          nextFollowup.isAcceptableOrUnknown(
              data['next_followup']!, _nextFollowupMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id']),
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      promisedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}promised_date']),
      promisedAmountPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}promised_amount_paise']),
      nextFollowup: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_followup']),
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CallLogsTable createAlias(String alias) {
    return $CallLogsTable(attachedDatabase, alias);
  }
}

class CallLog extends DataClass implements Insertable<CallLog> {
  final String id;
  final String userId;
  final String? taskId;
  final String? partyId;
  final String outcome;
  final String? notes;
  final DateTime? promisedDate;
  final int? promisedAmountPaise;
  final DateTime? nextFollowup;
  final String syncId;
  final DateTime createdAt;
  const CallLog(
      {required this.id,
      required this.userId,
      this.taskId,
      this.partyId,
      required this.outcome,
      this.notes,
      this.promisedDate,
      this.promisedAmountPaise,
      this.nextFollowup,
      required this.syncId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || promisedDate != null) {
      map['promised_date'] = Variable<DateTime>(promisedDate);
    }
    if (!nullToAbsent || promisedAmountPaise != null) {
      map['promised_amount_paise'] = Variable<int>(promisedAmountPaise);
    }
    if (!nullToAbsent || nextFollowup != null) {
      map['next_followup'] = Variable<DateTime>(nextFollowup);
    }
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CallLogsCompanion toCompanion(bool nullToAbsent) {
    return CallLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      outcome: Value(outcome),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      promisedDate: promisedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(promisedDate),
      promisedAmountPaise: promisedAmountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(promisedAmountPaise),
      nextFollowup: nextFollowup == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowup),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
    );
  }

  factory CallLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      outcome: serializer.fromJson<String>(json['outcome']),
      notes: serializer.fromJson<String?>(json['notes']),
      promisedDate: serializer.fromJson<DateTime?>(json['promisedDate']),
      promisedAmountPaise:
          serializer.fromJson<int?>(json['promisedAmountPaise']),
      nextFollowup: serializer.fromJson<DateTime?>(json['nextFollowup']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String?>(taskId),
      'partyId': serializer.toJson<String?>(partyId),
      'outcome': serializer.toJson<String>(outcome),
      'notes': serializer.toJson<String?>(notes),
      'promisedDate': serializer.toJson<DateTime?>(promisedDate),
      'promisedAmountPaise': serializer.toJson<int?>(promisedAmountPaise),
      'nextFollowup': serializer.toJson<DateTime?>(nextFollowup),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CallLog copyWith(
          {String? id,
          String? userId,
          Value<String?> taskId = const Value.absent(),
          Value<String?> partyId = const Value.absent(),
          String? outcome,
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> promisedDate = const Value.absent(),
          Value<int?> promisedAmountPaise = const Value.absent(),
          Value<DateTime?> nextFollowup = const Value.absent(),
          String? syncId,
          DateTime? createdAt}) =>
      CallLog(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        taskId: taskId.present ? taskId.value : this.taskId,
        partyId: partyId.present ? partyId.value : this.partyId,
        outcome: outcome ?? this.outcome,
        notes: notes.present ? notes.value : this.notes,
        promisedDate:
            promisedDate.present ? promisedDate.value : this.promisedDate,
        promisedAmountPaise: promisedAmountPaise.present
            ? promisedAmountPaise.value
            : this.promisedAmountPaise,
        nextFollowup:
            nextFollowup.present ? nextFollowup.value : this.nextFollowup,
        syncId: syncId ?? this.syncId,
        createdAt: createdAt ?? this.createdAt,
      );
  CallLog copyWithCompanion(CallLogsCompanion data) {
    return CallLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      notes: data.notes.present ? data.notes.value : this.notes,
      promisedDate: data.promisedDate.present
          ? data.promisedDate.value
          : this.promisedDate,
      promisedAmountPaise: data.promisedAmountPaise.present
          ? data.promisedAmountPaise.value
          : this.promisedAmountPaise,
      nextFollowup: data.nextFollowup.present
          ? data.nextFollowup.value
          : this.nextFollowup,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('partyId: $partyId, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes, ')
          ..write('promisedDate: $promisedDate, ')
          ..write('promisedAmountPaise: $promisedAmountPaise, ')
          ..write('nextFollowup: $nextFollowup, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, taskId, partyId, outcome, notes,
      promisedDate, promisedAmountPaise, nextFollowup, syncId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.partyId == this.partyId &&
          other.outcome == this.outcome &&
          other.notes == this.notes &&
          other.promisedDate == this.promisedDate &&
          other.promisedAmountPaise == this.promisedAmountPaise &&
          other.nextFollowup == this.nextFollowup &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt);
}

class CallLogsCompanion extends UpdateCompanion<CallLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> taskId;
  final Value<String?> partyId;
  final Value<String> outcome;
  final Value<String?> notes;
  final Value<DateTime?> promisedDate;
  final Value<int?> promisedAmountPaise;
  final Value<DateTime?> nextFollowup;
  final Value<String> syncId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CallLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.outcome = const Value.absent(),
    this.notes = const Value.absent(),
    this.promisedDate = const Value.absent(),
    this.promisedAmountPaise = const Value.absent(),
    this.nextFollowup = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallLogsCompanion.insert({
    required String id,
    required String userId,
    this.taskId = const Value.absent(),
    this.partyId = const Value.absent(),
    required String outcome,
    this.notes = const Value.absent(),
    this.promisedDate = const Value.absent(),
    this.promisedAmountPaise = const Value.absent(),
    this.nextFollowup = const Value.absent(),
    required String syncId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        outcome = Value(outcome),
        syncId = Value(syncId),
        createdAt = Value(createdAt);
  static Insertable<CallLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<String>? partyId,
    Expression<String>? outcome,
    Expression<String>? notes,
    Expression<DateTime>? promisedDate,
    Expression<int>? promisedAmountPaise,
    Expression<DateTime>? nextFollowup,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (partyId != null) 'party_id': partyId,
      if (outcome != null) 'outcome': outcome,
      if (notes != null) 'notes': notes,
      if (promisedDate != null) 'promised_date': promisedDate,
      if (promisedAmountPaise != null)
        'promised_amount_paise': promisedAmountPaise,
      if (nextFollowup != null) 'next_followup': nextFollowup,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? taskId,
      Value<String?>? partyId,
      Value<String>? outcome,
      Value<String?>? notes,
      Value<DateTime?>? promisedDate,
      Value<int?>? promisedAmountPaise,
      Value<DateTime?>? nextFollowup,
      Value<String>? syncId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CallLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      partyId: partyId ?? this.partyId,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      promisedDate: promisedDate ?? this.promisedDate,
      promisedAmountPaise: promisedAmountPaise ?? this.promisedAmountPaise,
      nextFollowup: nextFollowup ?? this.nextFollowup,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (promisedDate.present) {
      map['promised_date'] = Variable<DateTime>(promisedDate.value);
    }
    if (promisedAmountPaise.present) {
      map['promised_amount_paise'] = Variable<int>(promisedAmountPaise.value);
    }
    if (nextFollowup.present) {
      map['next_followup'] = Variable<DateTime>(nextFollowup.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('partyId: $partyId, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes, ')
          ..write('promisedDate: $promisedDate, ')
          ..write('promisedAmountPaise: $promisedAmountPaise, ')
          ..write('nextFollowup: $nextFollowup, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiParseLogsTable extends AiParseLogs
    with TableInfo<$AiParseLogsTable, AiParseLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiParseLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawInputMeta =
      const VerificationMeta('rawInput');
  @override
  late final GeneratedColumn<String> rawInput = GeneratedColumn<String>(
      'raw_input', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parsedJsonMeta =
      const VerificationMeta('parsedJson');
  @override
  late final GeneratedColumn<String> parsedJson = GeneratedColumn<String>(
      'parsed_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confirmedMeta =
      const VerificationMeta('confirmed');
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
      'confirmed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("confirmed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _confirmedAtMeta =
      const VerificationMeta('confirmedAt');
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
      'confirmed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, rawInput, parsedJson, confirmed, confirmedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_parse_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AiParseLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_input')) {
      context.handle(_rawInputMeta,
          rawInput.isAcceptableOrUnknown(data['raw_input']!, _rawInputMeta));
    } else if (isInserting) {
      context.missing(_rawInputMeta);
    }
    if (data.containsKey('parsed_json')) {
      context.handle(
          _parsedJsonMeta,
          parsedJson.isAcceptableOrUnknown(
              data['parsed_json']!, _parsedJsonMeta));
    } else if (isInserting) {
      context.missing(_parsedJsonMeta);
    }
    if (data.containsKey('confirmed')) {
      context.handle(_confirmedMeta,
          confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta));
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
          _confirmedAtMeta,
          confirmedAt.isAcceptableOrUnknown(
              data['confirmed_at']!, _confirmedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiParseLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiParseLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      rawInput: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_input'])!,
      parsedJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parsed_json'])!,
      confirmed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}confirmed'])!,
      confirmedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}confirmed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AiParseLogsTable createAlias(String alias) {
    return $AiParseLogsTable(attachedDatabase, alias);
  }
}

class AiParseLog extends DataClass implements Insertable<AiParseLog> {
  final String id;
  final String userId;
  final String rawInput;
  final String parsedJson;
  final bool confirmed;
  final DateTime? confirmedAt;
  final DateTime createdAt;
  const AiParseLog(
      {required this.id,
      required this.userId,
      required this.rawInput,
      required this.parsedJson,
      required this.confirmed,
      this.confirmedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_input'] = Variable<String>(rawInput);
    map['parsed_json'] = Variable<String>(parsedJson);
    map['confirmed'] = Variable<bool>(confirmed);
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiParseLogsCompanion toCompanion(bool nullToAbsent) {
    return AiParseLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      rawInput: Value(rawInput),
      parsedJson: Value(parsedJson),
      confirmed: Value(confirmed),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
      createdAt: Value(createdAt),
    );
  }

  factory AiParseLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiParseLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawInput: serializer.fromJson<String>(json['rawInput']),
      parsedJson: serializer.fromJson<String>(json['parsedJson']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      confirmedAt: serializer.fromJson<DateTime?>(json['confirmedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'rawInput': serializer.toJson<String>(rawInput),
      'parsedJson': serializer.toJson<String>(parsedJson),
      'confirmed': serializer.toJson<bool>(confirmed),
      'confirmedAt': serializer.toJson<DateTime?>(confirmedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiParseLog copyWith(
          {String? id,
          String? userId,
          String? rawInput,
          String? parsedJson,
          bool? confirmed,
          Value<DateTime?> confirmedAt = const Value.absent(),
          DateTime? createdAt}) =>
      AiParseLog(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        rawInput: rawInput ?? this.rawInput,
        parsedJson: parsedJson ?? this.parsedJson,
        confirmed: confirmed ?? this.confirmed,
        confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  AiParseLog copyWithCompanion(AiParseLogsCompanion data) {
    return AiParseLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawInput: data.rawInput.present ? data.rawInput.value : this.rawInput,
      parsedJson:
          data.parsedJson.present ? data.parsedJson.value : this.parsedJson,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      confirmedAt:
          data.confirmedAt.present ? data.confirmedAt.value : this.confirmedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiParseLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawInput: $rawInput, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('confirmed: $confirmed, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, rawInput, parsedJson, confirmed, confirmedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiParseLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawInput == this.rawInput &&
          other.parsedJson == this.parsedJson &&
          other.confirmed == this.confirmed &&
          other.confirmedAt == this.confirmedAt &&
          other.createdAt == this.createdAt);
}

class AiParseLogsCompanion extends UpdateCompanion<AiParseLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> rawInput;
  final Value<String> parsedJson;
  final Value<bool> confirmed;
  final Value<DateTime?> confirmedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiParseLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawInput = const Value.absent(),
    this.parsedJson = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiParseLogsCompanion.insert({
    required String id,
    required String userId,
    required String rawInput,
    required String parsedJson,
    this.confirmed = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        rawInput = Value(rawInput),
        parsedJson = Value(parsedJson),
        createdAt = Value(createdAt);
  static Insertable<AiParseLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? rawInput,
    Expression<String>? parsedJson,
    Expression<bool>? confirmed,
    Expression<DateTime>? confirmedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawInput != null) 'raw_input': rawInput,
      if (parsedJson != null) 'parsed_json': parsedJson,
      if (confirmed != null) 'confirmed': confirmed,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiParseLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? rawInput,
      Value<String>? parsedJson,
      Value<bool>? confirmed,
      Value<DateTime?>? confirmedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AiParseLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawInput: rawInput ?? this.rawInput,
      parsedJson: parsedJson ?? this.parsedJson,
      confirmed: confirmed ?? this.confirmed,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawInput.present) {
      map['raw_input'] = Variable<String>(rawInput.value);
    }
    if (parsedJson.present) {
      map['parsed_json'] = Variable<String>(parsedJson.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiParseLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawInput: $rawInput, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('confirmed: $confirmed, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncTable extends PendingSync
    with TableInfo<$PendingSyncTable, PendingSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        action,
        payloadJson,
        attemptCount,
        createdAt,
        lastAttemptAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync';
  @override
  VerificationContext validateIntegrity(Insertable<PendingSyncData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
    );
  }

  @override
  $PendingSyncTable createAlias(String alias) {
    return $PendingSyncTable(attachedDatabase, alias);
  }
}

class PendingSyncData extends DataClass implements Insertable<PendingSyncData> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  const PendingSyncData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payloadJson,
      required this.attemptCount,
      required this.createdAt,
      this.lastAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  PendingSyncCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      attemptCount: Value(attemptCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory PendingSyncData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  PendingSyncData copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? action,
          String? payloadJson,
          int? attemptCount,
          DateTime? createdAt,
          Value<DateTime?> lastAttemptAt = const Value.absent()}) =>
      PendingSyncData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        attemptCount: attemptCount ?? this.attemptCount,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
      );
  PendingSyncData copyWithCompanion(PendingSyncCompanion data) {
    return PendingSyncData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, action, payloadJson,
      attemptCount, createdAt, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class PendingSyncCompanion extends UpdateCompanion<PendingSyncData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<int> attemptCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<int> rowid;
  const PendingSyncCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingSyncCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String payloadJson,
    this.attemptCount = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<PendingSyncData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingSyncCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<int>? attemptCount,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptAt,
      Value<int>? rowid}) {
    return PendingSyncCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $DealsTable deals = $DealsTable(this);
  late final $DealItemsTable dealItems = $DealItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $CallLogsTable callLogs = $CallLogsTable(this);
  late final $AiParseLogsTable aiParseLogs = $AiParseLogsTable(this);
  late final $PendingSyncTable pendingSync = $PendingSyncTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localUsers,
        parties,
        deals,
        dealItems,
        payments,
        expenses,
        tasks,
        callLogs,
        aiParseLogs,
        pendingSync
      ];
}

typedef $$LocalUsersTableCreateCompanionBuilder = LocalUsersCompanion Function({
  required String id,
  required String name,
  Value<String?> businessName,
  required String deviceToken,
  Value<String> role,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalUsersTableUpdateCompanionBuilder = LocalUsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> businessName,
  Value<String> deviceToken,
  Value<String> role,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceToken => $composableBuilder(
      column: $table.deviceToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessName => $composableBuilder(
      column: $table.businessName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceToken => $composableBuilder(
      column: $table.deviceToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
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

  GeneratedColumn<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => column);

  GeneratedColumn<String> get deviceToken => $composableBuilder(
      column: $table.deviceToken, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()> {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> businessName = const Value.absent(),
            Value<String> deviceToken = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion(
            id: id,
            name: name,
            businessName: businessName,
            deviceToken: deviceToken,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> businessName = const Value.absent(),
            required String deviceToken,
            Value<String> role = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion.insert(
            id: id,
            name: name,
            businessName: businessName,
            deviceToken: deviceToken,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()>;
typedef $$PartiesTableCreateCompanionBuilder = PartiesCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<String?> phone,
  Value<String> type,
  Value<String> trustTag,
  Value<bool> trustTagManualOverride,
  Value<String?> notes,
  required String syncId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$PartiesTableUpdateCompanionBuilder = PartiesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String?> phone,
  Value<String> type,
  Value<String> trustTag,
  Value<bool> trustTagManualOverride,
  Value<String?> notes,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trustTag => $composableBuilder(
      column: $table.trustTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get trustTagManualOverride => $composableBuilder(
      column: $table.trustTagManualOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trustTag => $composableBuilder(
      column: $table.trustTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get trustTagManualOverride => $composableBuilder(
      column: $table.trustTagManualOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get trustTag =>
      $composableBuilder(column: $table.trustTag, builder: (column) => column);

  GeneratedColumn<bool> get trustTagManualOverride => $composableBuilder(
      column: $table.trustTagManualOverride, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PartiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartiesTable,
    Party,
    $$PartiesTableFilterComposer,
    $$PartiesTableOrderingComposer,
    $$PartiesTableAnnotationComposer,
    $$PartiesTableCreateCompanionBuilder,
    $$PartiesTableUpdateCompanionBuilder,
    (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
    Party,
    PrefetchHooks Function()> {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> trustTag = const Value.absent(),
            Value<bool> trustTagManualOverride = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartiesCompanion(
            id: id,
            userId: userId,
            name: name,
            phone: phone,
            type: type,
            trustTag: trustTag,
            trustTagManualOverride: trustTagManualOverride,
            notes: notes,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> trustTag = const Value.absent(),
            Value<bool> trustTagManualOverride = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String syncId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartiesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            phone: phone,
            type: type,
            trustTag: trustTag,
            trustTagManualOverride: trustTagManualOverride,
            notes: notes,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PartiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartiesTable,
    Party,
    $$PartiesTableFilterComposer,
    $$PartiesTableOrderingComposer,
    $$PartiesTableAnnotationComposer,
    $$PartiesTableCreateCompanionBuilder,
    $$PartiesTableUpdateCompanionBuilder,
    (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
    Party,
    PrefetchHooks Function()>;
typedef $$DealsTableCreateCompanionBuilder = DealsCompanion Function({
  required String id,
  required String userId,
  required String partyId,
  Value<String> type,
  required String cashewGrade,
  required int quantityGrams,
  required int ratePaisePerKg,
  required int totalPaise,
  Value<int> paidPaise,
  Value<String> status,
  Value<DateTime?> deliveryDate,
  Value<DateTime?> paymentDue,
  Value<String?> notes,
  required String syncId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$DealsTableUpdateCompanionBuilder = DealsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> partyId,
  Value<String> type,
  Value<String> cashewGrade,
  Value<int> quantityGrams,
  Value<int> ratePaisePerKg,
  Value<int> totalPaise,
  Value<int> paidPaise,
  Value<String> status,
  Value<DateTime?> deliveryDate,
  Value<DateTime?> paymentDue,
  Value<String?> notes,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$DealsTableFilterComposer extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cashewGrade => $composableBuilder(
      column: $table.cashewGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityGrams => $composableBuilder(
      column: $table.quantityGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ratePaisePerKg => $composableBuilder(
      column: $table.ratePaisePerKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidPaise => $composableBuilder(
      column: $table.paidPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDue => $composableBuilder(
      column: $table.paymentDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DealsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cashewGrade => $composableBuilder(
      column: $table.cashewGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityGrams => $composableBuilder(
      column: $table.quantityGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ratePaisePerKg => $composableBuilder(
      column: $table.ratePaisePerKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidPaise => $composableBuilder(
      column: $table.paidPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDue => $composableBuilder(
      column: $table.paymentDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get cashewGrade => $composableBuilder(
      column: $table.cashewGrade, builder: (column) => column);

  GeneratedColumn<int> get quantityGrams => $composableBuilder(
      column: $table.quantityGrams, builder: (column) => column);

  GeneratedColumn<int> get ratePaisePerKg => $composableBuilder(
      column: $table.ratePaisePerKg, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => column);

  GeneratedColumn<int> get paidPaise =>
      $composableBuilder(column: $table.paidPaise, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDue => $composableBuilder(
      column: $table.paymentDue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DealsTable,
    Deal,
    $$DealsTableFilterComposer,
    $$DealsTableOrderingComposer,
    $$DealsTableAnnotationComposer,
    $$DealsTableCreateCompanionBuilder,
    $$DealsTableUpdateCompanionBuilder,
    (Deal, BaseReferences<_$AppDatabase, $DealsTable, Deal>),
    Deal,
    PrefetchHooks Function()> {
  $$DealsTableTableManager(_$AppDatabase db, $DealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> partyId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> cashewGrade = const Value.absent(),
            Value<int> quantityGrams = const Value.absent(),
            Value<int> ratePaisePerKg = const Value.absent(),
            Value<int> totalPaise = const Value.absent(),
            Value<int> paidPaise = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deliveryDate = const Value.absent(),
            Value<DateTime?> paymentDue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DealsCompanion(
            id: id,
            userId: userId,
            partyId: partyId,
            type: type,
            cashewGrade: cashewGrade,
            quantityGrams: quantityGrams,
            ratePaisePerKg: ratePaisePerKg,
            totalPaise: totalPaise,
            paidPaise: paidPaise,
            status: status,
            deliveryDate: deliveryDate,
            paymentDue: paymentDue,
            notes: notes,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String partyId,
            Value<String> type = const Value.absent(),
            required String cashewGrade,
            required int quantityGrams,
            required int ratePaisePerKg,
            required int totalPaise,
            Value<int> paidPaise = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deliveryDate = const Value.absent(),
            Value<DateTime?> paymentDue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String syncId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DealsCompanion.insert(
            id: id,
            userId: userId,
            partyId: partyId,
            type: type,
            cashewGrade: cashewGrade,
            quantityGrams: quantityGrams,
            ratePaisePerKg: ratePaisePerKg,
            totalPaise: totalPaise,
            paidPaise: paidPaise,
            status: status,
            deliveryDate: deliveryDate,
            paymentDue: paymentDue,
            notes: notes,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DealsTable,
    Deal,
    $$DealsTableFilterComposer,
    $$DealsTableOrderingComposer,
    $$DealsTableAnnotationComposer,
    $$DealsTableCreateCompanionBuilder,
    $$DealsTableUpdateCompanionBuilder,
    (Deal, BaseReferences<_$AppDatabase, $DealsTable, Deal>),
    Deal,
    PrefetchHooks Function()>;
typedef $$DealItemsTableCreateCompanionBuilder = DealItemsCompanion Function({
  required String id,
  required String dealId,
  required String grade,
  required String quantityText,
  Value<String?> rateText,
  required int lineTotalPaise,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DealItemsTableUpdateCompanionBuilder = DealItemsCompanion Function({
  Value<String> id,
  Value<String> dealId,
  Value<String> grade,
  Value<String> quantityText,
  Value<String?> rateText,
  Value<int> lineTotalPaise,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DealItemsTable> {
  $$DealItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dealId => $composableBuilder(
      column: $table.dealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantityText => $composableBuilder(
      column: $table.quantityText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateText => $composableBuilder(
      column: $table.rateText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealItemsTable> {
  $$DealItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dealId => $composableBuilder(
      column: $table.dealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantityText => $composableBuilder(
      column: $table.quantityText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateText => $composableBuilder(
      column: $table.rateText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealItemsTable> {
  $$DealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get quantityText => $composableBuilder(
      column: $table.quantityText, builder: (column) => column);

  GeneratedColumn<String> get rateText =>
      $composableBuilder(column: $table.rateText, builder: (column) => column);

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DealItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DealItemsTable,
    DealItem,
    $$DealItemsTableFilterComposer,
    $$DealItemsTableOrderingComposer,
    $$DealItemsTableAnnotationComposer,
    $$DealItemsTableCreateCompanionBuilder,
    $$DealItemsTableUpdateCompanionBuilder,
    (DealItem, BaseReferences<_$AppDatabase, $DealItemsTable, DealItem>),
    DealItem,
    PrefetchHooks Function()> {
  $$DealItemsTableTableManager(_$AppDatabase db, $DealItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dealId = const Value.absent(),
            Value<String> grade = const Value.absent(),
            Value<String> quantityText = const Value.absent(),
            Value<String?> rateText = const Value.absent(),
            Value<int> lineTotalPaise = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DealItemsCompanion(
            id: id,
            dealId: dealId,
            grade: grade,
            quantityText: quantityText,
            rateText: rateText,
            lineTotalPaise: lineTotalPaise,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dealId,
            required String grade,
            required String quantityText,
            Value<String?> rateText = const Value.absent(),
            required int lineTotalPaise,
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DealItemsCompanion.insert(
            id: id,
            dealId: dealId,
            grade: grade,
            quantityText: quantityText,
            rateText: rateText,
            lineTotalPaise: lineTotalPaise,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DealItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DealItemsTable,
    DealItem,
    $$DealItemsTableFilterComposer,
    $$DealItemsTableOrderingComposer,
    $$DealItemsTableAnnotationComposer,
    $$DealItemsTableCreateCompanionBuilder,
    $$DealItemsTableUpdateCompanionBuilder,
    (DealItem, BaseReferences<_$AppDatabase, $DealItemsTable, DealItem>),
    DealItem,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String userId,
  required String partyId,
  Value<String?> dealId,
  required String type,
  required int amountPaise,
  Value<String?> method,
  Value<String?> notes,
  required DateTime paymentDate,
  required String syncId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> partyId,
  Value<String?> dealId,
  Value<String> type,
  Value<int> amountPaise,
  Value<String?> method,
  Value<String?> notes,
  Value<DateTime> paymentDate,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dealId => $composableBuilder(
      column: $table.dealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dealId => $composableBuilder(
      column: $table.dealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> partyId = const Value.absent(),
            Value<String?> dealId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amountPaise = const Value.absent(),
            Value<String?> method = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            userId: userId,
            partyId: partyId,
            dealId: dealId,
            type: type,
            amountPaise: amountPaise,
            method: method,
            notes: notes,
            paymentDate: paymentDate,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String partyId,
            Value<String?> dealId = const Value.absent(),
            required String type,
            required int amountPaise,
            Value<String?> method = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime paymentDate,
            required String syncId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            userId: userId,
            partyId: partyId,
            dealId: dealId,
            type: type,
            amountPaise: amountPaise,
            method: method,
            notes: notes,
            paymentDate: paymentDate,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String userId,
  required String category,
  Value<String> scope,
  required int amountPaise,
  Value<String?> notes,
  required DateTime expenseDate,
  required String syncId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> category,
  Value<String> scope,
  Value<int> amountPaise,
  Value<String?> notes,
  Value<DateTime> expenseDate,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<int> amountPaise = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            userId: userId,
            category: category,
            scope: scope,
            amountPaise: amountPaise,
            notes: notes,
            expenseDate: expenseDate,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String category,
            Value<String> scope = const Value.absent(),
            required int amountPaise,
            Value<String?> notes = const Value.absent(),
            required DateTime expenseDate,
            required String syncId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            userId: userId,
            category: category,
            scope: scope,
            amountPaise: amountPaise,
            notes: notes,
            expenseDate: expenseDate,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String userId,
  Value<String?> partyId,
  required String type,
  required String title,
  Value<String?> notes,
  required DateTime scheduledAt,
  Value<DateTime?> completedAt,
  Value<String> status,
  Value<int> priority,
  required String syncId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> partyId,
  Value<String> type,
  Value<String> title,
  Value<String?> notes,
  Value<DateTime> scheduledAt,
  Value<DateTime?> completedAt,
  Value<String> status,
  Value<int> priority,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            userId: userId,
            partyId: partyId,
            type: type,
            title: title,
            notes: notes,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            status: status,
            priority: priority,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> partyId = const Value.absent(),
            required String type,
            required String title,
            Value<String?> notes = const Value.absent(),
            required DateTime scheduledAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            required String syncId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            userId: userId,
            partyId: partyId,
            type: type,
            title: title,
            notes: notes,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            status: status,
            priority: priority,
            syncId: syncId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;
typedef $$CallLogsTableCreateCompanionBuilder = CallLogsCompanion Function({
  required String id,
  required String userId,
  Value<String?> taskId,
  Value<String?> partyId,
  required String outcome,
  Value<String?> notes,
  Value<DateTime?> promisedDate,
  Value<int?> promisedAmountPaise,
  Value<DateTime?> nextFollowup,
  required String syncId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CallLogsTableUpdateCompanionBuilder = CallLogsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> taskId,
  Value<String?> partyId,
  Value<String> outcome,
  Value<String?> notes,
  Value<DateTime?> promisedDate,
  Value<int?> promisedAmountPaise,
  Value<DateTime?> nextFollowup,
  Value<String> syncId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get promisedDate => $composableBuilder(
      column: $table.promisedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promisedAmountPaise => $composableBuilder(
      column: $table.promisedAmountPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextFollowup => $composableBuilder(
      column: $table.nextFollowup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get promisedDate => $composableBuilder(
      column: $table.promisedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promisedAmountPaise => $composableBuilder(
      column: $table.promisedAmountPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextFollowup => $composableBuilder(
      column: $table.nextFollowup,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get promisedDate => $composableBuilder(
      column: $table.promisedDate, builder: (column) => column);

  GeneratedColumn<int> get promisedAmountPaise => $composableBuilder(
      column: $table.promisedAmountPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get nextFollowup => $composableBuilder(
      column: $table.nextFollowup, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CallLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CallLogsTable,
    CallLog,
    $$CallLogsTableFilterComposer,
    $$CallLogsTableOrderingComposer,
    $$CallLogsTableAnnotationComposer,
    $$CallLogsTableCreateCompanionBuilder,
    $$CallLogsTableUpdateCompanionBuilder,
    (CallLog, BaseReferences<_$AppDatabase, $CallLogsTable, CallLog>),
    CallLog,
    PrefetchHooks Function()> {
  $$CallLogsTableTableManager(_$AppDatabase db, $CallLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> promisedDate = const Value.absent(),
            Value<int?> promisedAmountPaise = const Value.absent(),
            Value<DateTime?> nextFollowup = const Value.absent(),
            Value<String> syncId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CallLogsCompanion(
            id: id,
            userId: userId,
            taskId: taskId,
            partyId: partyId,
            outcome: outcome,
            notes: notes,
            promisedDate: promisedDate,
            promisedAmountPaise: promisedAmountPaise,
            nextFollowup: nextFollowup,
            syncId: syncId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> taskId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            required String outcome,
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> promisedDate = const Value.absent(),
            Value<int?> promisedAmountPaise = const Value.absent(),
            Value<DateTime?> nextFollowup = const Value.absent(),
            required String syncId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CallLogsCompanion.insert(
            id: id,
            userId: userId,
            taskId: taskId,
            partyId: partyId,
            outcome: outcome,
            notes: notes,
            promisedDate: promisedDate,
            promisedAmountPaise: promisedAmountPaise,
            nextFollowup: nextFollowup,
            syncId: syncId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CallLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CallLogsTable,
    CallLog,
    $$CallLogsTableFilterComposer,
    $$CallLogsTableOrderingComposer,
    $$CallLogsTableAnnotationComposer,
    $$CallLogsTableCreateCompanionBuilder,
    $$CallLogsTableUpdateCompanionBuilder,
    (CallLog, BaseReferences<_$AppDatabase, $CallLogsTable, CallLog>),
    CallLog,
    PrefetchHooks Function()>;
typedef $$AiParseLogsTableCreateCompanionBuilder = AiParseLogsCompanion
    Function({
  required String id,
  required String userId,
  required String rawInput,
  required String parsedJson,
  Value<bool> confirmed,
  Value<DateTime?> confirmedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AiParseLogsTableUpdateCompanionBuilder = AiParseLogsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> rawInput,
  Value<String> parsedJson,
  Value<bool> confirmed,
  Value<DateTime?> confirmedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AiParseLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AiParseLogsTable> {
  $$AiParseLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawInput => $composableBuilder(
      column: $table.rawInput, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get confirmed => $composableBuilder(
      column: $table.confirmed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AiParseLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiParseLogsTable> {
  $$AiParseLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawInput => $composableBuilder(
      column: $table.rawInput, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get confirmed => $composableBuilder(
      column: $table.confirmed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AiParseLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiParseLogsTable> {
  $$AiParseLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawInput =>
      $composableBuilder(column: $table.rawInput, builder: (column) => column);

  GeneratedColumn<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
      column: $table.confirmedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiParseLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiParseLogsTable,
    AiParseLog,
    $$AiParseLogsTableFilterComposer,
    $$AiParseLogsTableOrderingComposer,
    $$AiParseLogsTableAnnotationComposer,
    $$AiParseLogsTableCreateCompanionBuilder,
    $$AiParseLogsTableUpdateCompanionBuilder,
    (AiParseLog, BaseReferences<_$AppDatabase, $AiParseLogsTable, AiParseLog>),
    AiParseLog,
    PrefetchHooks Function()> {
  $$AiParseLogsTableTableManager(_$AppDatabase db, $AiParseLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiParseLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiParseLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiParseLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> rawInput = const Value.absent(),
            Value<String> parsedJson = const Value.absent(),
            Value<bool> confirmed = const Value.absent(),
            Value<DateTime?> confirmedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiParseLogsCompanion(
            id: id,
            userId: userId,
            rawInput: rawInput,
            parsedJson: parsedJson,
            confirmed: confirmed,
            confirmedAt: confirmedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String rawInput,
            required String parsedJson,
            Value<bool> confirmed = const Value.absent(),
            Value<DateTime?> confirmedAt = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiParseLogsCompanion.insert(
            id: id,
            userId: userId,
            rawInput: rawInput,
            parsedJson: parsedJson,
            confirmed: confirmed,
            confirmedAt: confirmedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiParseLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiParseLogsTable,
    AiParseLog,
    $$AiParseLogsTableFilterComposer,
    $$AiParseLogsTableOrderingComposer,
    $$AiParseLogsTableAnnotationComposer,
    $$AiParseLogsTableCreateCompanionBuilder,
    $$AiParseLogsTableUpdateCompanionBuilder,
    (AiParseLog, BaseReferences<_$AppDatabase, $AiParseLogsTable, AiParseLog>),
    AiParseLog,
    PrefetchHooks Function()>;
typedef $$PendingSyncTableCreateCompanionBuilder = PendingSyncCompanion
    Function({
  required String id,
  required String entityType,
  required String entityId,
  required String action,
  required String payloadJson,
  Value<int> attemptCount,
  required DateTime createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<int> rowid,
});
typedef $$PendingSyncTableUpdateCompanionBuilder = PendingSyncCompanion
    Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payloadJson,
  Value<int> attemptCount,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<int> rowid,
});

class $$PendingSyncTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncTable> {
  $$PendingSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$PendingSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncTable> {
  $$PendingSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$PendingSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncTable> {
  $$PendingSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);
}

class $$PendingSyncTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingSyncTable,
    PendingSyncData,
    $$PendingSyncTableFilterComposer,
    $$PendingSyncTableOrderingComposer,
    $$PendingSyncTableAnnotationComposer,
    $$PendingSyncTableCreateCompanionBuilder,
    $$PendingSyncTableUpdateCompanionBuilder,
    (
      PendingSyncData,
      BaseReferences<_$AppDatabase, $PendingSyncTable, PendingSyncData>
    ),
    PendingSyncData,
    PrefetchHooks Function()> {
  $$PendingSyncTableTableManager(_$AppDatabase db, $PendingSyncTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingSyncCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            attemptCount: attemptCount,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String action,
            required String payloadJson,
            Value<int> attemptCount = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingSyncCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            attemptCount: attemptCount,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingSyncTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingSyncTable,
    PendingSyncData,
    $$PendingSyncTableFilterComposer,
    $$PendingSyncTableOrderingComposer,
    $$PendingSyncTableAnnotationComposer,
    $$PendingSyncTableCreateCompanionBuilder,
    $$PendingSyncTableUpdateCompanionBuilder,
    (
      PendingSyncData,
      BaseReferences<_$AppDatabase, $PendingSyncTable, PendingSyncData>
    ),
    PendingSyncData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$DealsTableTableManager get deals =>
      $$DealsTableTableManager(_db, _db.deals);
  $$DealItemsTableTableManager get dealItems =>
      $$DealItemsTableTableManager(_db, _db.dealItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$CallLogsTableTableManager get callLogs =>
      $$CallLogsTableTableManager(_db, _db.callLogs);
  $$AiParseLogsTableTableManager get aiParseLogs =>
      $$AiParseLogsTableTableManager(_db, _db.aiParseLogs);
  $$PendingSyncTableTableManager get pendingSync =>
      $$PendingSyncTableTableManager(_db, _db.pendingSync);
}
