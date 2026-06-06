import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/today/data/call_logs_api.dart';
import 'package:kajupilot/features/today/data/call_logs_repository.dart';
import 'package:kajupilot/features/today/data/today_models.dart';

void main() {
  group('CallLogsRepository', () {
    late AppDatabase database;
    late CallLogsRepository repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      await seedParty(database);
      await seedTask(database);
      final ids = ['call-1', 'call-sync-1', 'follow-task-1', 'follow-sync-1'];
      var pendingIndex = 0;
      repository = CallLogsRepository(
        database: database,
        api: FakeCallLogsApi(),
        pendingSync: PendingSyncService(
          database,
          idGenerator: () => 'pending-${++pendingIndex}',
        ),
        currentUserId: 'local-owner',
        idGenerator: () => ids.removeAt(0),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('payment promised logs call, completes source task, adds follow-up',
        () async {
      await repository.create(
        CreateCallLogInput(
          taskId: 'task-1',
          partyId: 'party-1',
          outcome: CallOutcomeValue.paymentPromised,
          promisedDate: DateTime.utc(2026, 6, 8, 10),
          promisedAmountPaise: 8000000,
        ),
      );

      final callLog = await database.select(database.callLogs).getSingle();
      final tasks = await database.select(database.tasks).get();
      final pending = await database.select(database.pendingSync).get();

      expect(callLog.outcome, CallOutcomeValue.paymentPromised.apiValue);
      expect(tasks.firstWhere((task) => task.id == 'task-1').status,
          TaskStatusValue.done.apiValue);
      expect(tasks.firstWhere((task) => task.id == 'follow-task-1').type,
          TaskTypeValue.paymentCollection.apiValue);
      expect(pending.single.entityType, PendingSyncEntityType.callLog.name);
    });
  });
}

Future<void> seedParty(AppDatabase database) {
  final now = DateTime.utc(2026, 6, 7);
  return database.into(database.parties).insert(
        PartiesCompanion.insert(
          id: 'party-1',
          userId: 'local-owner',
          name: 'Amit Verma',
          phone: const Value('98765'),
          syncId: 'party-sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> seedTask(AppDatabase database) {
  final now = DateTime.utc(2026, 6, 7, 9);
  return database.into(database.tasks).insert(
        TasksCompanion.insert(
          id: 'task-1',
          userId: 'local-owner',
          partyId: const Value('party-1'),
          type: TaskTypeValue.call.apiValue,
          title: 'Call Amit',
          scheduledAt: now,
          syncId: 'task-sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class FakeCallLogsApi extends CallLogsApi {
  FakeCallLogsApi() : super(KajuApiClient(Dio()));

  @override
  Future<CallLogCreateResult> create({
    required String id,
    required String syncId,
    required CreateCallLogInput input,
  }) async {
    throw StateError('offline');
  }
}
