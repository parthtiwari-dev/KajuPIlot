import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pending_sync_service.dart';
import 'expenses_api.dart';
import 'money_models.dart';

final expensesApiProvider = Provider<ExpensesApi>((ref) {
  return ExpensesApi(ref.watch(apiClientProvider));
});

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return ExpensesRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(expensesApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final expenseListProvider =
    StreamProvider.family<List<Expense>, ExpenseListQuery>((ref, query) {
  return ref.watch(expensesRepositoryProvider).watchExpenses(query);
});

final expenseSummaryProvider =
    StreamProvider.family<ExpenseSummary, ExpenseListQuery>((ref, query) {
  return ref.watch(expensesRepositoryProvider).watchSummary(query);
});

class ExpensesRepository {
  ExpensesRepository({
    required AppDatabase database,
    required ExpensesApi api,
    required PendingSyncService pendingSync,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _pendingSync = pendingSync,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final ExpensesApi _api;
  final PendingSyncService _pendingSync;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<Expense>> watchExpenses(ExpenseListQuery query) {
    return (_database.select(_database.expenses)
          ..where((row) {
            var expression = row.deletedAt.isNull();
            if (query.scope != null) {
              expression = expression & row.scope.equals(query.scope!.apiValue);
            }
            if (query.category != null) {
              expression =
                  expression & row.category.equals(query.category!.apiValue);
            }
            if (query.from != null) {
              expression = expression &
                  row.expenseDate.isBiggerOrEqualValue(query.from!.toUtc());
            }
            if (query.to != null) {
              expression = expression &
                  row.expenseDate.isSmallerOrEqualValue(query.to!.toUtc());
            }
            return expression;
          })
          ..orderBy([
            (row) => OrderingTerm.desc(row.expenseDate),
            (row) => OrderingTerm.desc(row.updatedAt),
          ]))
        .watch();
  }

  Stream<ExpenseSummary> watchSummary(ExpenseListQuery query) {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {_database.expenses},
        )
        .watch()
        .asyncMap((_) => localSummary(query));
  }

  Future<Expense?> getExpense(String expenseId) {
    return (_database.select(_database.expenses)
          ..where((row) => row.id.equals(expenseId) & row.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Expense> create(CreateExpenseInput input) async {
    if (input.amountPaise <= 0) {
      throw StateError('Enter expense amount');
    }

    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final expense = Expense(
      id: id,
      userId: _currentUserId,
      category: input.category.apiValue,
      scope: input.scope.apiValue,
      amountPaise: input.amountPaise,
      notes: _clean(input.notes),
      expenseDate: input.expenseDate.toUtc(),
      syncId: syncId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    await _upsertExpense(expense);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.expense,
      entityId: id,
      action: PendingSyncAction.create,
      payload: expenseCreatePayload(id: id, syncId: syncId, input: input),
      now: now,
    );

    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: input,
    );

    return expense;
  }

  Future<Expense?> update(String expenseId, UpdateExpenseInput input) async {
    if (input.amountPaise <= 0) {
      throw StateError('Enter expense amount');
    }

    final existing = await getExpense(expenseId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      category: input.category.apiValue,
      scope: input.scope.apiValue,
      amountPaise: input.amountPaise,
      notes: Value(_clean(input.notes)),
      expenseDate: input.expenseDate.toUtc(),
      updatedAt: now,
    );

    await _upsertExpense(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.expense,
      entityId: expenseId,
      action: PendingSyncAction.update,
      payload: expenseUpdatePayload(input),
      now: now,
    );

    await _tryUpdateOnApi(
      pendingId: pendingId,
      id: expenseId,
      input: input,
    );

    return updated;
  }

  Future<Expense?> softDelete(String expenseId) async {
    final existing = await getExpense(expenseId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );

    await _upsertExpense(deleted);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.expense,
      entityId: expenseId,
      action: PendingSyncAction.delete,
      payload: {'id': expenseId},
      now: now,
    );

    await _tryDeleteOnApi(pendingId: pendingId, id: expenseId);

    return deleted;
  }

  Future<void> restore(Expense expense) async {
    final now = DateTime.now().toUtc();
    final restored = expense.copyWith(
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await _upsertExpense(restored);

    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.expense.name &&
          entry.entityId == expense.id &&
          entry.action == PendingSyncAction.delete.name;
    })) {
      await _pendingSync.remove(entry.id);
    }

    final input = CreateExpenseInput(
      category: ExpenseCategoryValue.fromApi(restored.category),
      scope: ExpenseScopeValue.fromApi(restored.scope),
      amountPaise: restored.amountPaise,
      expenseDate: restored.expenseDate,
      notes: restored.notes,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.expense,
      entityId: restored.id,
      action: PendingSyncAction.create,
      payload: expenseCreatePayload(
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
  }

  Future<void> refresh({
    ExpenseListQuery query = const ExpenseListQuery(),
    bool flushPending = true,
  }) async {
    if (flushPending) {
      await flushPendingExpenseSync();
    }
    final remoteExpenses = await _api.list(
      scope: query.scope,
      category: query.category,
      from: query.from,
      to: query.to,
    );
    for (final expense in remoteExpenses) {
      await _upsertExpense(expense);
    }
  }

  Future<void> flushPendingExpenseSync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.expense.name;
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

  Future<ExpenseSummary> localSummary(ExpenseListQuery query) async {
    final expenses = await (_database.select(_database.expenses)
          ..where((row) {
            var expression = row.deletedAt.isNull();
            if (query.scope != null) {
              expression = expression & row.scope.equals(query.scope!.apiValue);
            }
            if (query.category != null) {
              expression =
                  expression & row.category.equals(query.category!.apiValue);
            }
            if (query.from != null) {
              expression = expression &
                  row.expenseDate.isBiggerOrEqualValue(query.from!.toUtc());
            }
            if (query.to != null) {
              expression = expression &
                  row.expenseDate.isSmallerOrEqualValue(query.to!.toUtc());
            }
            return expression;
          }))
        .get();

    final byCategory = {
      for (final category in ExpenseCategoryValue.values) category: 0,
    };
    final byScope = {
      for (final scope in ExpenseScopeValue.values) scope: 0,
    };
    var total = 0;
    for (final expense in expenses) {
      final category = ExpenseCategoryValue.fromApi(expense.category);
      final scope = ExpenseScopeValue.fromApi(expense.scope);
      byCategory[category] = byCategory[category]! + expense.amountPaise;
      byScope[scope] = byScope[scope]! + expense.amountPaise;
      total += expense.amountPaise;
    }

    return ExpenseSummary(
      byCategoryPaise: byCategory,
      byScopePaise: byScope,
      totalPaise: total,
      periodComparison: 0,
    );
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreateExpenseInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final created = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertExpense(created);
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
    required UpdateExpenseInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final updated = await _api.update(id, input);
      await _upsertExpense(updated);
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
      final deleted = await _api.delete(id);
      await _upsertExpense(deleted);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _upsertExpense(Expense expense) {
    return _database
        .into(_database.expenses)
        .insertOnConflictUpdate(expense.toCompanion(false));
  }

  CreateExpenseInput _createInputFromPayload(Map<String, dynamic> payload) {
    return CreateExpenseInput(
      category: ExpenseCategoryValue.fromApi(payload['category'] as String),
      scope: ExpenseScopeValue.fromApi(
        payload['scope'] as String? ?? ExpenseScopeValue.business.apiValue,
      ),
      amountPaise: moneyTextToPaise(payload['amount'] as String),
      expenseDate: DateTime.parse(payload['expenseDate'] as String).toUtc(),
      notes: payload['notes'] as String?,
    );
  }

  UpdateExpenseInput _updateInputFromPayload(Map<String, dynamic> payload) {
    return UpdateExpenseInput(
      category: ExpenseCategoryValue.fromApi(payload['category'] as String),
      scope: ExpenseScopeValue.fromApi(
        payload['scope'] as String? ?? ExpenseScopeValue.business.apiValue,
      ),
      amountPaise: moneyTextToPaise(payload['amount'] as String),
      expenseDate: DateTime.parse(payload['expenseDate'] as String).toUtc(),
      notes: payload['notes'] as String?,
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
