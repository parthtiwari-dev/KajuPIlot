import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pending_sync_service.dart';
import '../../../core/utils/currency.dart';
import 'call_logs_api.dart';
import 'today_models.dart';

final callLogsApiProvider = Provider<CallLogsApi>((ref) {
  return CallLogsApi(ref.watch(apiClientProvider));
});

final callLogsRepositoryProvider = Provider<CallLogsRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return CallLogsRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(callLogsApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final callLogListProvider =
    StreamProvider.family<List<CallLogListItem>, CallLogListQuery>(
  (ref, query) {
    return ref.watch(callLogsRepositoryProvider).watchCallLogs(query);
  },
);

class CallLogsRepository {
  CallLogsRepository({
    required AppDatabase database,
    required CallLogsApi api,
    required PendingSyncService pendingSync,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _pendingSync = pendingSync,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final CallLogsApi _api;
  final PendingSyncService _pendingSync;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<CallLogListItem>> watchCallLogs(CallLogListQuery query) {
    return (_database.select(_database.callLogs)
          ..where((row) {
            Expression<bool> expression = const Constant(true);
            if (query.partyId != null) {
              expression = expression & row.partyId.equals(query.partyId!);
            }
            if (query.from != null) {
              expression = expression &
                  row.createdAt.isBiggerOrEqualValue(query.from!.toUtc());
            }
            if (query.to != null) {
              expression = expression &
                  row.createdAt.isSmallerOrEqualValue(query.to!.toUtc());
            }
            return expression;
          })
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .watch()
        .asyncMap(_toListItems);
  }

  Future<CallLog> create(CreateCallLogInput rawInput) async {
    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final input = await _withFollowUp(rawInput);
    final callLog = CallLog(
      id: id,
      userId: _currentUserId,
      taskId: input.taskId,
      partyId: input.partyId,
      outcome: input.outcome.apiValue,
      notes: _clean(input.notes),
      promisedDate: input.promisedDate?.toUtc(),
      promisedAmountPaise: input.promisedAmountPaise,
      nextFollowup: input.followUpTask?.scheduledAt.toUtc(),
      syncId: syncId,
      createdAt: now,
    );

    await _database.transaction(() async {
      await _upsertCallLog(callLog);
      if (input.taskId != null) {
        await (_database.update(_database.tasks)
              ..where((row) => row.id.equals(input.taskId!)))
            .write(
          TasksCompanion(
            status: Value(TaskStatusValue.done.apiValue),
            completedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
      final followUpTask = input.followUpTask;
      if (followUpTask != null) {
        await _upsertFollowUpTask(input, followUpTask, now);
      }
    });

    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.callLog,
      entityId: id,
      action: PendingSyncAction.create,
      payload: callLogCreatePayload(id: id, syncId: syncId, input: input),
      now: now,
    );
    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: input,
    );

    return callLog;
  }

  Future<void> refresh({
    CallLogListQuery query = const CallLogListQuery(),
    bool flushPending = true,
  }) async {
    if (flushPending) {
      await flushPendingCallLogSync();
    }
    final remote = await _api.list(query);
    for (final item in remote) {
      await _upsertCallLog(item.callLog);
    }
  }

  Future<void> flushPendingCallLogSync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.callLog.name;
    })) {
      try {
        final payload = await _pendingSync.decodedPayload(entry);
        await _tryCreateOnApi(
          pendingId: entry.id,
          id: payload['id'] as String,
          syncId: payload['syncId'] as String,
          input: _inputFromPayload(payload),
          markAttemptOnFailure: true,
        );
      } catch (_) {
        await _pendingSync.markAttempted(entry.id);
      }
    }
  }

  Future<CreateCallLogInput> _withFollowUp(CreateCallLogInput input) async {
    if (input.followUpTask != null ||
        input.outcome == CallOutcomeValue.notInterested ||
        input.outcome == CallOutcomeValue.deliveryUpdate ||
        input.outcome == CallOutcomeValue.other) {
      return input;
    }

    final task = input.taskId == null ? null : await _task(input.taskId!);
    final party = input.partyId == null ? null : await _party(input.partyId!);
    final followUpAt = switch (input.outcome) {
      CallOutcomeValue.paymentPromised => input.promisedDate,
      CallOutcomeValue.noAnswer => _tomorrowAtOriginalTime(task),
      CallOutcomeValue.newOrder => _tomorrowAtTen(),
      _ => null,
    };
    if (followUpAt == null) {
      return input;
    }

    return CreateCallLogInput(
      taskId: input.taskId,
      partyId: input.partyId,
      outcome: input.outcome,
      notes: input.notes,
      promisedDate: input.promisedDate,
      promisedAmountPaise: input.promisedAmountPaise,
      followUpTask: FollowUpTaskInput(
        id: _idGenerator(),
        syncId: _idGenerator(),
        scheduledAt: followUpAt,
        title: _followUpTitle(input, party, task),
      ),
    );
  }

  Future<void> _upsertFollowUpTask(
    CreateCallLogInput input,
    FollowUpTaskInput followUp,
    DateTime now,
  ) {
    final type = input.outcome == CallOutcomeValue.paymentPromised
        ? TaskTypeValue.paymentCollection
        : TaskTypeValue.call;
    return _database.into(_database.tasks).insertOnConflictUpdate(
          Task(
            id: followUp.id,
            userId: _currentUserId,
            partyId: input.partyId,
            type: type.apiValue,
            title: followUp.title,
            notes: _clean(input.notes),
            scheduledAt: followUp.scheduledAt.toUtc(),
            completedAt: null,
            status: TaskStatusValue.pending.apiValue,
            priority: input.outcome == CallOutcomeValue.paymentPromised ? 2 : 1,
            syncId: followUp.syncId,
            createdAt: now,
            updatedAt: now,
            deletedAt: null,
          ),
        );
  }

  Future<List<CallLogListItem>> _toListItems(List<CallLog> callLogs) async {
    final partyIds = callLogs
        .map((callLog) => callLog.partyId)
        .whereType<String>()
        .toSet()
        .toList();
    final taskIds = callLogs
        .map((callLog) => callLog.taskId)
        .whereType<String>()
        .toSet()
        .toList();
    final parties = partyIds.isEmpty
        ? <Party>[]
        : await (_database.select(_database.parties)
              ..where((row) => row.id.isIn(partyIds)))
            .get();
    final tasks = taskIds.isEmpty
        ? <Task>[]
        : await (_database.select(_database.tasks)
              ..where((row) => row.id.isIn(taskIds)))
            .get();
    final partyById = {for (final party in parties) party.id: party};
    final taskById = {for (final task in tasks) task.id: task};

    return callLogs.map((callLog) {
      final party = callLog.partyId == null ? null : partyById[callLog.partyId];
      final task = callLog.taskId == null ? null : taskById[callLog.taskId];
      return CallLogListItem(
        callLog: callLog,
        party: party == null ? null : TaskPartySummary.fromParty(party),
        taskTitle: task?.title,
      );
    }).toList();
  }

  Future<void> _upsertCallLog(CallLog callLog) {
    return _database.into(_database.callLogs).insertOnConflictUpdate(callLog);
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreateCallLogInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final remote = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertCallLog(remote.item.callLog);
      if (remote.nextTask != null) {
        await _database
            .into(_database.tasks)
            .insertOnConflictUpdate(remote.nextTask!.task);
      }
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  CreateCallLogInput _inputFromPayload(Map<String, dynamic> payload) {
    final followUp = payload['followUpTask'] as Map<String, dynamic>?;
    return CreateCallLogInput(
      taskId: payload['taskId'] as String?,
      partyId: payload['partyId'] as String?,
      outcome: CallOutcomeValue.fromApi(payload['outcome'] as String),
      notes: payload['notes'] as String?,
      promisedDate: payload['promisedDate'] == null
          ? null
          : DateTime.parse(payload['promisedDate'] as String),
      promisedAmountPaise: payload['promisedAmount'] == null
          ? null
          : decimalRupeesToPaise(payload['promisedAmount']),
      followUpTask: followUp == null
          ? null
          : FollowUpTaskInput(
              id: followUp['id'] as String,
              syncId: followUp['syncId'] as String,
              scheduledAt: DateTime.parse(followUp['scheduledAt'] as String),
              title: followUp['title'] as String,
            ),
    );
  }

  Future<Task?> _task(String id) {
    return (_database.select(_database.tasks)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Party?> _party(String id) {
    return (_database.select(_database.parties)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  DateTime _tomorrowAtOriginalTime(Task? task) {
    final base = task?.scheduledAt.toLocal() ?? DateTime.now();
    return DateTime(
      base.year,
      base.month,
      base.day + 1,
      task == null ? 10 : base.hour,
      task == null ? 0 : base.minute,
    );
  }

  DateTime _tomorrowAtTen() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 10);
  }

  String _followUpTitle(
    CreateCallLogInput input,
    Party? party,
    Task? task,
  ) {
    final name = party?.name;
    return switch (input.outcome) {
      CallOutcomeValue.paymentPromised => name == null
          ? 'Collect promised payment'
          : 'Collect payment from $name',
      CallOutcomeValue.newOrder => name == null
          ? 'Follow up on new order'
          : 'Follow up on new order from $name',
      CallOutcomeValue.noAnswer =>
        task?.title ?? (name == null ? 'Follow up call' : 'Call $name'),
      _ => task?.title ?? 'Follow up',
    };
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
