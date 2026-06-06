import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/notifications/kaju_notification_service.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/today/data/tasks_api.dart';
import 'package:kajupilot/features/today/data/tasks_repository.dart';
import 'package:kajupilot/features/today/data/today_insights_api.dart';
import 'package:kajupilot/features/today/data/today_models.dart';

void main() {
  group('TasksRepository', () {
    late AppDatabase database;
    late FakeTasksApi api;
    late TasksRepository repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      await seedParty(database);
      api = FakeTasksApi();
      final ids = ['task-1', 'sync-1'];
      var pendingIndex = 0;
      repository = TasksRepository(
        database: database,
        api: api,
        insightsApi: FakeTodayInsightsApi(),
        pendingSync: PendingSyncService(
          database,
          idGenerator: () => 'pending-${++pendingIndex}',
        ),
        notifications: FakeNotificationService(),
        currentUserId: 'local-owner',
        idGenerator: () => ids.removeAt(0),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('creates locally and leaves pending sync when API fails', () async {
      api.failCreate = true;

      await repository.create(
        CreateTaskInput(
          partyId: 'party-1',
          type: TaskTypeValue.call,
          title: 'Call Amit',
          scheduledAt: DateTime.utc(2026, 6, 7, 10),
          priority: 2,
        ),
      );

      final task = await database.select(database.tasks).getSingle();
      final pending = await database.select(database.pendingSync).get();

      expect(task.title, 'Call Amit');
      expect(task.type, TaskTypeValue.call.apiValue);
      expect(pending.single.entityType, PendingSyncEntityType.task.name);
      expect(pending.single.payloadJson, contains('Call Amit'));
    });

    test('complete and postpone update local task immediately', () async {
      await seedTask(database);

      await repository.complete('task-1');
      var task = await database.select(database.tasks).getSingle();
      expect(task.status, TaskStatusValue.done.apiValue);
      expect(task.completedAt, isNotNull);

      await repository.postpone('task-1', DateTime.utc(2026, 6, 8, 11));
      task = await database.select(database.tasks).getSingle();
      expect(task.status, TaskStatusValue.postponed.apiValue);
      expect(
        task.scheduledAt.isAtSameMomentAs(DateTime.utc(2026, 6, 8, 11)),
        isTrue,
      );
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
          syncId: 'party-sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> seedTask(AppDatabase database) {
  final now = DateTime.utc(2026, 6, 7);
  return database.into(database.tasks).insert(
        TasksCompanion.insert(
          id: 'task-1',
          userId: 'local-owner',
          partyId: const drift.Value('party-1'),
          type: TaskTypeValue.call.apiValue,
          title: 'Call Amit',
          scheduledAt: now,
          syncId: 'task-sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class FakeTasksApi extends TasksApi {
  FakeTasksApi() : super(KajuApiClient(Dio()));

  bool failCreate = false;

  @override
  Future<TaskListItem> create({
    required String id,
    required String syncId,
    required CreateTaskInput input,
  }) async {
    if (failCreate) {
      throw StateError('offline');
    }
    final now = DateTime.utc(2026, 6, 7);
    return TaskListItem(
      task: Task(
        id: id,
        userId: 'server-user',
        partyId: input.partyId,
        type: input.type.apiValue,
        title: input.title,
        notes: input.notes,
        scheduledAt: input.scheduledAt.toUtc(),
        completedAt: null,
        status: TaskStatusValue.pending.apiValue,
        priority: input.priority,
        syncId: syncId,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      party: null,
    );
  }

  @override
  Future<TaskListItem> complete(String id) async {
    throw StateError('offline');
  }

  @override
  Future<TaskListItem> postpone(String id, DateTime scheduledAt) async {
    throw StateError('offline');
  }
}

class FakeTodayInsightsApi extends TodayInsightsApi {
  FakeTodayInsightsApi() : super(KajuApiClient(Dio()));

  @override
  Future<TodayInsights> today(DateTime date) async => TodayInsights.empty();
}

class FakeNotificationService extends KajuNotificationService {
  @override
  Future<void> reschedule({
    required List<TaskListItem> tasks,
    TodayInsights? insights,
    DateTime? now,
  }) async {}
}
