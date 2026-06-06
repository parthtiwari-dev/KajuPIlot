import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/money/data/expenses_api.dart';
import 'package:kajupilot/features/money/data/expenses_repository.dart';
import 'package:kajupilot/features/money/data/money_models.dart';

void main() {
  group('ExpensesRepository', () {
    late AppDatabase database;
    late FakeExpensesApi api;
    late ExpensesRepository repository;
    var ids = <String>[];
    var pendingIndex = 0;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      api = FakeExpensesApi();
      ids = ['expense-1', 'sync-1'];
      pendingIndex = 0;
      repository = ExpensesRepository(
        database: database,
        api: api,
        pendingSync: PendingSyncService(
          database,
          idGenerator: () {
            pendingIndex += 1;
            return 'pending-$pendingIndex';
          },
        ),
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
        CreateExpenseInput(
          category: ExpenseCategoryValue.transport,
          amountPaise: 125000,
          expenseDate: DateTime.utc(2026, 6, 7),
          notes: 'Truck',
        ),
      );

      final expense = await database.select(database.expenses).getSingle();
      final pending = await database.select(database.pendingSync).get();
      final summary = await repository.localSummary(const ExpenseListQuery());

      expect(expense.category, 'TRANSPORT');
      expect(expense.amountPaise, 125000);
      expect(summary.totalPaise, 125000);
      expect(summary.byCategoryPaise[ExpenseCategoryValue.transport], 125000);
      expect(pending.single.entityType, PendingSyncEntityType.expense.name);
    });

    test('updates and soft deletes locally', () async {
      api.failUpdate = true;
      api.failDelete = true;
      await repository.create(
        CreateExpenseInput(
          category: ExpenseCategoryValue.transport,
          amountPaise: 125000,
          expenseDate: DateTime.utc(2026, 6, 7),
        ),
      );

      await repository.update(
        'expense-1',
        UpdateExpenseInput(
          category: ExpenseCategoryValue.labour,
          amountPaise: 220000,
          expenseDate: DateTime.utc(2026, 6, 8),
        ),
      );

      await repository.softDelete('expense-1');

      final expense = await database.select(database.expenses).getSingle();
      final pending = await database.select(database.pendingSync).get();

      expect(expense.category, 'LABOUR');
      expect(expense.amountPaise, 220000);
      expect(expense.deletedAt, isNotNull);
      expect(pending.map((entry) => entry.action), contains('update'));
      expect(pending.map((entry) => entry.action), contains('delete'));
    });
  });
}

class FakeExpensesApi extends ExpensesApi {
  FakeExpensesApi() : super(KajuApiClient(Dio()));

  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  @override
  Future<Expense> create({
    required String id,
    required String syncId,
    required CreateExpenseInput input,
  }) async {
    if (failCreate) {
      throw StateError('offline');
    }

    return testExpense(
      id: id,
      userId: 'server-user',
      syncId: syncId,
      category: input.category.apiValue,
      amountPaise: input.amountPaise,
      expenseDate: input.expenseDate,
      notes: input.notes,
    );
  }

  @override
  Future<Expense> update(String id, UpdateExpenseInput input) async {
    if (failUpdate) {
      throw StateError('offline');
    }

    return testExpense(
      id: id,
      userId: 'server-user',
      category: input.category.apiValue,
      amountPaise: input.amountPaise,
      expenseDate: input.expenseDate,
      notes: input.notes,
    );
  }

  @override
  Future<Expense> delete(String id) async {
    if (failDelete) {
      throw StateError('offline');
    }

    return testExpense(id: id, deletedAt: DateTime.utc(2026, 6, 8));
  }
}

Expense testExpense({
  String id = 'expense-1',
  String userId = 'local-owner',
  String syncId = 'sync-1',
  String category = 'TRANSPORT',
  int amountPaise = 125000,
  DateTime? expenseDate,
  String? notes,
  DateTime? deletedAt,
}) {
  final now = DateTime.utc(2026, 6, 7);
  return Expense(
    id: id,
    userId: userId,
    category: category,
    amountPaise: amountPaise,
    notes: notes,
    expenseDate: expenseDate ?? now,
    syncId: syncId,
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}
