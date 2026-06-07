import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LocalUsers extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get businessName => text().nullable()();
  TextColumn get deviceToken => text().unique()();
  TextColumn get role => text().withDefault(const Constant('OWNER'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('CUSTOMER'))();
  TextColumn get trustTag => text().withDefault(const Constant('NEW'))();
  BoolColumn get trustTagManualOverride =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Deals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get partyId => text()();
  TextColumn get type => text().withDefault(const Constant('SALE'))();
  TextColumn get cashewGrade => text()();
  IntColumn get quantityGrams => integer()();
  IntColumn get ratePaisePerKg => integer()();
  IntColumn get totalPaise => integer()();
  IntColumn get paidPaise => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('CONFIRMED'))();
  DateTimeColumn get deliveryDate => dateTime().nullable()();
  DateTimeColumn get paymentDue => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DealItems extends Table {
  TextColumn get id => text()();
  TextColumn get dealId => text()();
  TextColumn get grade => text()();
  TextColumn get quantityText => text()();
  TextColumn get rateText => text().nullable()();
  IntColumn get lineTotalPaise => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get partyId => text()();
  TextColumn get dealId => text().nullable()();
  TextColumn get type => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get method => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get category => text()();
  TextColumn get scope => text().withDefault(const Constant('BUSINESS'))();
  IntColumn get amountPaise => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get partyId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CallLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text().nullable()();
  TextColumn get partyId => text().nullable()();
  TextColumn get outcome => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get promisedDate => dateTime().nullable()();
  IntColumn get promisedAmountPaise => integer().nullable()();
  DateTimeColumn get nextFollowup => dateTime().nullable()();
  TextColumn get syncId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AiParseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get rawInput => text()();
  TextColumn get parsedJson => text()();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingSync extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalUsers,
    Parties,
    Deals,
    DealItems,
    Payments,
    Expenses,
    Tasks,
    CallLogs,
    AiParseLogs,
    PendingSync,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'kajupilot'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(dealItems);
          }
          if (from < 3) {
            await migrator.addColumn(expenses, expenses.scope);
          }
          if (from < 4) {
            await migrator.addColumn(
              parties,
              parties.trustTagManualOverride,
            );
          }
        },
      );
}
