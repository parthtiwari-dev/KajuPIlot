import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/notifications/kaju_notification_service.dart';
import '../../../core/sync/pending_sync_service.dart';
import '../../../core/utils/dates.dart';
import '../data/today_insights_api.dart';
import 'tasks_api.dart';
import 'today_models.dart';

final tasksApiProvider = Provider<TasksApi>((ref) {
  return TasksApi(ref.watch(apiClientProvider));
});

final todayInsightsApiProvider = Provider<TodayInsightsApi>((ref) {
  return TodayInsightsApi(ref.watch(apiClientProvider));
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return TasksRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(tasksApiProvider),
    insightsApi: ref.watch(todayInsightsApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    notifications: ref.watch(kajuNotificationServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final todayTasksProvider =
    StreamProvider.family<List<TaskListItem>, DateTime>((ref, date) {
  return ref.watch(tasksRepositoryProvider).watchToday(date);
});

final taskListProvider =
    StreamProvider.family<List<TaskListItem>, TaskListQuery>((ref, query) {
  return ref.watch(tasksRepositoryProvider).watchTasks(query);
});

final todayInsightsProvider =
    FutureProvider.family<TodayInsights, DateTime>((ref, date) {
  return ref.watch(tasksRepositoryProvider).todayInsights(date);
});

class TasksRepository {
  TasksRepository({
    required AppDatabase database,
    required TasksApi api,
    required TodayInsightsApi insightsApi,
    required PendingSyncService pendingSync,
    required KajuNotificationService notifications,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _insightsApi = insightsApi,
        _pendingSync = pendingSync,
        _notifications = notifications,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final TasksApi _api;
  final TodayInsightsApi _insightsApi;
  final PendingSyncService _pendingSync;
  final KajuNotificationService _notifications;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<TaskListItem>> watchTasks(TaskListQuery query) {
    return (_database.select(_database.tasks)
          ..where((row) {
            var expression = row.deletedAt.isNull();
            if (query.status != null) {
              expression =
                  expression & row.status.equals(query.status!.apiValue);
            }
            if (query.type != null) {
              expression = expression & row.type.equals(query.type!.apiValue);
            }
            if (query.partyId != null) {
              expression = expression & row.partyId.equals(query.partyId!);
            }
            if (query.from != null) {
              expression = expression &
                  row.scheduledAt.isBiggerOrEqualValue(query.from!.toUtc());
            }
            if (query.to != null) {
              expression = expression &
                  row.scheduledAt.isSmallerOrEqualValue(query.to!.toUtc());
            }
            return expression;
          })
          ..orderBy([
            (row) => OrderingTerm.asc(row.scheduledAt),
            (row) => OrderingTerm.desc(row.priority),
          ]))
        .watch()
        .asyncMap(_toListItems);
  }

  Stream<List<TaskListItem>> watchToday(DateTime date) {
    final end = dateOnly(date).add(const Duration(days: 1)).toUtc();
    return (_database.select(_database.tasks)
          ..where((row) {
            return row.deletedAt.isNull() &
                row.scheduledAt.isSmallerThanValue(end) &
                row.status.isIn([
                  TaskStatusValue.pending.apiValue,
                  TaskStatusValue.postponed.apiValue,
                ]);
          })
          ..orderBy([
            (row) => OrderingTerm.asc(row.scheduledAt),
            (row) => OrderingTerm.desc(row.priority),
          ]))
        .watch()
        .asyncMap((tasks) async {
      final items = await _toListItems(tasks);
      items.sort(_todaySort);
      return items;
    });
  }

  Future<Task?> getTask(String taskId) {
    return (_database.select(_database.tasks)
          ..where((row) => row.id.equals(taskId) & row.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<TaskListItem>> localToday(DateTime date) async {
    final end = dateOnly(date).add(const Duration(days: 1)).toUtc();
    final tasks = await (_database.select(_database.tasks)
          ..where((row) {
            return row.deletedAt.isNull() &
                row.scheduledAt.isSmallerThanValue(end) &
                row.status.isIn([
                  TaskStatusValue.pending.apiValue,
                  TaskStatusValue.postponed.apiValue,
                ]);
          }))
        .get();
    final items = await _toListItems(tasks);
    items.sort(_todaySort);
    return items;
  }

  Future<Task> create(CreateTaskInput input) async {
    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final task = Task(
      id: id,
      userId: _currentUserId,
      partyId: input.partyId,
      type: input.type.apiValue,
      title: input.title.trim(),
      notes: _clean(input.notes),
      scheduledAt: input.scheduledAt.toUtc(),
      completedAt: null,
      status: TaskStatusValue.pending.apiValue,
      priority: input.priority,
      syncId: syncId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    await _upsertTask(task);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: id,
      action: PendingSyncAction.create,
      payload: taskCreatePayload(id: id, syncId: syncId, input: input),
      now: now,
    );
    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: input,
    );
    unawaited(rescheduleNotificationsForToday());
    return task;
  }

  Future<Task?> update(String taskId, UpdateTaskInput input) async {
    final existing = await getTask(taskId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      partyId: input.clearParty
          ? const Value(null)
          : input.partyId == null
              ? const Value.absent()
              : Value(input.partyId),
      type: input.type?.apiValue,
      title: input.title?.trim(),
      notes: input.clearNotes
          ? const Value(null)
          : input.notes == null
              ? const Value.absent()
              : Value(_clean(input.notes)),
      scheduledAt: input.scheduledAt?.toUtc(),
      status: input.status?.apiValue,
      priority: input.priority,
      updatedAt: now,
    );

    await _upsertTask(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: taskId,
      action: PendingSyncAction.update,
      payload: taskUpdatePayload(input),
      now: now,
    );
    await _tryUpdateOnApi(pendingId: pendingId, id: taskId, input: input);
    unawaited(rescheduleNotificationsForToday());
    return updated;
  }

  Future<Task?> complete(String taskId) async {
    final existing = await getTask(taskId);
    if (existing == null) {
      return null;
    }
    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      status: TaskStatusValue.done.apiValue,
      completedAt: Value(now),
      updatedAt: now,
    );
    await _upsertTask(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: taskId,
      action: PendingSyncAction.update,
      payload: {'complete': true},
      now: now,
    );
    await _tryCompleteOnApi(pendingId: pendingId, id: taskId);
    unawaited(rescheduleNotificationsForToday());
    return updated;
  }

  Future<Task?> postpone(String taskId, DateTime scheduledAt) async {
    final existing = await getTask(taskId);
    if (existing == null) {
      return null;
    }
    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      status: TaskStatusValue.postponed.apiValue,
      completedAt: const Value(null),
      scheduledAt: scheduledAt.toUtc(),
      updatedAt: now,
    );
    await _upsertTask(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: taskId,
      action: PendingSyncAction.update,
      payload: {
        'postpone': true,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      },
      now: now,
    );
    await _tryPostponeOnApi(
      pendingId: pendingId,
      id: taskId,
      scheduledAt: scheduledAt,
    );
    unawaited(rescheduleNotificationsForToday());
    return updated;
  }

  Future<Task?> softDelete(String taskId) async {
    final existing = await getTask(taskId);
    if (existing == null) {
      return null;
    }
    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );
    await _upsertTask(deleted);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: taskId,
      action: PendingSyncAction.delete,
      payload: {'id': taskId},
      now: now,
    );
    await _tryDeleteOnApi(pendingId: pendingId, id: taskId);
    unawaited(rescheduleNotificationsForToday());
    return deleted;
  }

  Future<void> restore(Task task) async {
    final now = DateTime.now().toUtc();
    final restored = task.copyWith(
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await _upsertTask(restored);
    final pendingEntries = await _pendingSync.pending(limit: 100);
    for (final entry in pendingEntries.where((entry) {
      return entry.entityType == PendingSyncEntityType.task.name &&
          entry.entityId == task.id &&
          entry.action == PendingSyncAction.delete.name;
    })) {
      await _pendingSync.remove(entry.id);
    }

    final input = CreateTaskInput(
      partyId: restored.partyId,
      type: TaskTypeValue.fromApi(restored.type),
      title: restored.title,
      notes: restored.notes,
      scheduledAt: restored.scheduledAt,
      priority: restored.priority,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.task,
      entityId: restored.id,
      action: PendingSyncAction.create,
      payload: taskCreatePayload(
        id: restored.id,
        syncId: restored.syncId,
        input: input,
      ),
      now: now,
    );
    await _tryCreateOnApi(
      pendingId: pendingId,
      id: restored.id,
      syncId: restored.syncId,
      input: input,
    );
    unawaited(rescheduleNotificationsForToday());
  }

  Future<void> refreshToday(DateTime date, {bool flushPending = true}) async {
    if (flushPending) {
      await flushPendingTaskSync();
    }
    final remoteTasks = await _api.today(date);
    for (final item in remoteTasks) {
      await _upsertTaskItem(item);
    }
    unawaited(rescheduleNotificationsForToday());
  }

  Future<void> refresh({
    TaskListQuery query = const TaskListQuery(),
    bool flushPending = true,
  }) async {
    if (flushPending) {
      await flushPendingTaskSync();
    }
    final remoteTasks = await _api.list(query);
    for (final item in remoteTasks) {
      await _upsertTaskItem(item);
    }
    unawaited(rescheduleNotificationsForToday());
  }

  Future<TodayInsights> todayInsights(DateTime date) async {
    try {
      return await _insightsApi.today(date);
    } catch (_) {
      return TodayInsights.empty();
    }
  }

  Future<void> rescheduleNotificationsForToday() async {
    final today = DateTime.now();
    final tasks = await _localPendingReminderTasks(today);
    final insights = await todayInsights(today);
    await _notifications.reschedule(tasks: tasks, insights: insights);
  }

  Future<List<TaskListItem>> _localPendingReminderTasks(DateTime now) async {
    final tasks = await (_database.select(_database.tasks)
          ..where((row) {
            return row.deletedAt.isNull() &
                row.scheduledAt.isBiggerThanValue(now.toUtc()) &
                row.status.isIn([
                  TaskStatusValue.pending.apiValue,
                  TaskStatusValue.postponed.apiValue,
                ]);
          })
          ..orderBy([
            (row) => OrderingTerm.asc(row.scheduledAt),
            (row) => OrderingTerm.desc(row.priority),
          ]))
        .get();
    return _toListItems(tasks);
  }

  Future<void> flushPendingTaskSync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.task.name;
    })) {
      try {
        final payload = await _pendingSync.decodedPayload(entry);
        switch (entry.action) {
          case 'create':
            await _tryCreateOnApi(
              pendingId: entry.id,
              id: payload['id'] as String,
              syncId: payload['syncId'] as String,
              input: _createInputFromPayload(payload),
              markAttemptOnFailure: true,
            );
          case 'update':
            if (payload['complete'] == true) {
              await _tryCompleteOnApi(
                pendingId: entry.id,
                id: entry.entityId,
                markAttemptOnFailure: true,
              );
              continue;
            }
            if (payload['postpone'] == true) {
              await _tryPostponeOnApi(
                pendingId: entry.id,
                id: entry.entityId,
                scheduledAt: DateTime.parse(payload['scheduledAt'] as String),
                markAttemptOnFailure: true,
              );
              continue;
            }
            await _tryUpdateOnApi(
              pendingId: entry.id,
              id: entry.entityId,
              input: _updateInputFromPayload(payload),
              markAttemptOnFailure: true,
            );
          case 'delete':
            await _tryDeleteOnApi(
              pendingId: entry.id,
              id: entry.entityId,
              markAttemptOnFailure: true,
            );
        }
      } catch (_) {
        await _pendingSync.markAttempted(entry.id);
      }
    }
  }

  Future<List<TaskListItem>> _toListItems(List<Task> tasks) async {
    final partyIds =
        tasks.map((task) => task.partyId).whereType<String>().toSet().toList();
    final parties = partyIds.isEmpty
        ? <Party>[]
        : await (_database.select(_database.parties)
              ..where((row) => row.id.isIn(partyIds)))
            .get();
    final partyById = {for (final party in parties) party.id: party};
    return tasks.map((task) {
      final party = task.partyId == null ? null : partyById[task.partyId];
      return TaskListItem(
        task: task,
        party: party == null ? null : TaskPartySummary.fromParty(party),
      );
    }).toList();
  }

  int _todaySort(TaskListItem a, TaskListItem b) {
    final now = DateTime.now().toUtc();
    final aOverdue = a.isOverdue(now) ? 1 : 0;
    final bOverdue = b.isOverdue(now) ? 1 : 0;
    if (aOverdue != bOverdue) {
      return bOverdue - aOverdue;
    }
    if (a.task.priority != b.task.priority) {
      return b.task.priority - a.task.priority;
    }
    return a.task.scheduledAt.compareTo(b.task.scheduledAt);
  }

  Future<void> _upsertTask(Task task) {
    return _database.into(_database.tasks).insertOnConflictUpdate(task);
  }

  Future<void> _upsertTaskItem(TaskListItem item) {
    return _upsertTask(item.task);
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreateTaskInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final remote = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertTaskItem(remote);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _tryUpdateOnApi({
    required String pendingId,
    required String id,
    required UpdateTaskInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final remote = await _api.update(id, input);
      await _upsertTaskItem(remote);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _tryCompleteOnApi({
    required String pendingId,
    required String id,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final remote = await _api.complete(id);
      await _upsertTaskItem(remote);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _tryPostponeOnApi({
    required String pendingId,
    required String id,
    required DateTime scheduledAt,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final remote = await _api.postpone(id, scheduledAt);
      await _upsertTaskItem(remote);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _tryDeleteOnApi({
    required String pendingId,
    required String id,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      await _api.delete(id);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  CreateTaskInput _createInputFromPayload(Map<String, dynamic> payload) {
    return CreateTaskInput(
      partyId: payload['partyId'] as String?,
      type: TaskTypeValue.fromApi(payload['type'] as String),
      title: payload['title'] as String,
      notes: payload['notes'] as String?,
      scheduledAt: DateTime.parse(payload['scheduledAt'] as String),
      priority: (payload['priority'] as num?)?.toInt() ?? 0,
    );
  }

  UpdateTaskInput _updateInputFromPayload(Map<String, dynamic> payload) {
    return UpdateTaskInput(
      partyId: payload['partyId'] as String?,
      clearParty: payload.containsKey('partyId') && payload['partyId'] == null,
      type: payload['type'] == null
          ? null
          : TaskTypeValue.fromApi(payload['type'] as String),
      title: payload['title'] as String?,
      notes: payload['notes'] as String?,
      clearNotes: payload.containsKey('notes') && payload['notes'] == null,
      scheduledAt: payload['scheduledAt'] == null
          ? null
          : DateTime.parse(payload['scheduledAt'] as String),
      status: payload['status'] == null
          ? null
          : TaskStatusValue.fromApi(payload['status'] as String),
      priority: (payload['priority'] as num?)?.toInt(),
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
