import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pending_sync_service.dart';
import '../../../core/utils/dates.dart';
import 'money_models.dart';
import 'payments_api.dart';

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  return PaymentsApi(ref.watch(apiClientProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return PaymentsRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(paymentsApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final paymentListProvider =
    StreamProvider.family<List<PaymentListItem>, PaymentListQuery>(
        (ref, query) {
  return ref.watch(paymentsRepositoryProvider).watchPayments(query);
});

final moneyLedgerProvider = StreamProvider<MoneyLedgerSnapshot>((ref) {
  return ref.watch(paymentsRepositoryProvider).watchLedger();
});

class PaymentsRepository {
  PaymentsRepository({
    required AppDatabase database,
    required PaymentsApi api,
    required PendingSyncService pendingSync,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _pendingSync = pendingSync,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final PaymentsApi _api;
  final PendingSyncService _pendingSync;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<PaymentListItem>> watchPayments(PaymentListQuery query) {
    return (_database.select(_database.payments)
          ..where((row) {
            var expression = row.deletedAt.isNull();
            if (query.partyId != null) {
              expression = expression & row.partyId.equals(query.partyId!);
            }
            if (query.dealId != null) {
              expression = expression & row.dealId.equals(query.dealId!);
            }
            if (query.type != null) {
              expression = expression & row.type.equals(query.type!.apiValue);
            }
            if (query.from != null) {
              expression = expression &
                  row.paymentDate.isBiggerOrEqualValue(query.from!.toUtc());
            }
            if (query.to != null) {
              expression = expression &
                  row.paymentDate.isSmallerOrEqualValue(query.to!.toUtc());
            }
            return expression;
          })
          ..orderBy([
            (row) => OrderingTerm.desc(row.paymentDate),
            (row) => OrderingTerm.desc(row.updatedAt),
          ]))
        .watch()
        .asyncMap((payments) async {
      final items = <PaymentListItem>[];
      for (final payment in payments) {
        items.add(await _toListItem(payment));
      }
      return items;
    });
  }

  Stream<MoneyLedgerSnapshot> watchLedger() {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.parties,
            _database.deals,
            _database.payments,
          },
        )
        .watch()
        .asyncMap((_) => localLedgerSnapshot());
  }

  Future<List<Party>> localParties() {
    return (_database.select(_database.parties)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
  }

  Future<List<PaymentDealOption>> localDealOptions({
    required String partyId,
    required PaymentTypeValue type,
  }) async {
    final requiredDealType =
        type == PaymentTypeValue.received ? 'SALE' : 'PURCHASE';
    final deals = await (_database.select(_database.deals)
          ..where((row) {
            return row.partyId.equals(partyId) &
                row.type.equals(requiredDealType) &
                row.deletedAt.isNull();
          })
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();

    return deals
        .where((deal) => deal.totalPaise - deal.paidPaise > 0)
        .map(
          (deal) => PaymentDealOption(
            id: deal.id,
            label: deal.cashewGrade,
            type: deal.type,
            totalPaise: deal.totalPaise,
            paidPaise: deal.paidPaise,
          ),
        )
        .toList();
  }

  Future<Payment?> getPayment(String paymentId) {
    return (_database.select(_database.payments)
          ..where((row) => row.id.equals(paymentId) & row.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Payment> create(CreatePaymentInput input) async {
    if (input.amountPaise <= 0) {
      throw StateError('Enter payment amount');
    }

    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final payment = Payment(
      id: id,
      userId: _currentUserId,
      partyId: input.partyId,
      dealId: input.dealId,
      type: input.type.apiValue,
      amountPaise: input.amountPaise,
      method: _clean(input.method),
      notes: _clean(input.notes),
      paymentDate: input.paymentDate.toUtc(),
      syncId: syncId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    await _database.transaction(() async {
      if (payment.dealId != null) {
        await _applyLinkedPaymentLocal(payment);
      }
      await _upsertPayment(payment);
    });

    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.payment,
      entityId: id,
      action: PendingSyncAction.create,
      payload: paymentCreatePayload(
        id: id,
        syncId: syncId,
        input: input,
      ),
      now: now,
    );

    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: input,
    );

    return payment;
  }

  Future<Payment?> update(String paymentId, UpdatePaymentInput input) async {
    if (input.amountPaise <= 0) {
      throw StateError('Enter payment amount');
    }

    final existing = await getPayment(paymentId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      partyId: input.partyId,
      dealId: Value(input.dealId),
      type: input.type.apiValue,
      amountPaise: input.amountPaise,
      method: Value(_clean(input.method)),
      notes: Value(_clean(input.notes)),
      paymentDate: input.paymentDate.toUtc(),
      updatedAt: now,
    );

    await _database.transaction(() async {
      if (existing.dealId != null) {
        await _reverseLinkedPaymentLocal(existing);
      }
      if (updated.dealId != null) {
        await _applyLinkedPaymentLocal(updated);
      }
      await _upsertPayment(updated);
    });

    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.payment,
      entityId: paymentId,
      action: PendingSyncAction.update,
      payload: paymentUpdatePayload(input),
      now: now,
    );

    await _tryUpdateOnApi(
      pendingId: pendingId,
      id: paymentId,
      input: input,
    );

    return updated;
  }

  Future<Payment?> softDelete(String paymentId) async {
    final existing = await getPayment(paymentId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );

    await _database.transaction(() async {
      if (existing.dealId != null) {
        await _reverseLinkedPaymentLocal(existing);
      }
      await _upsertPayment(deleted);
    });

    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.payment,
      entityId: paymentId,
      action: PendingSyncAction.delete,
      payload: {'id': paymentId},
      now: now,
    );

    await _tryDeleteOnApi(pendingId: pendingId, id: paymentId);

    return deleted;
  }

  Future<void> restore(Payment payment) async {
    final now = DateTime.now().toUtc();
    final restored = payment.copyWith(
      updatedAt: now,
      deletedAt: const Value(null),
    );

    await _database.transaction(() async {
      if (restored.dealId != null) {
        await _applyLinkedPaymentLocal(restored);
      }
      await _upsertPayment(restored);
    });

    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.payment.name &&
          entry.entityId == payment.id &&
          entry.action == PendingSyncAction.delete.name;
    })) {
      await _pendingSync.remove(entry.id);
    }

    final input = CreatePaymentInput(
      partyId: restored.partyId,
      dealId: restored.dealId,
      type: PaymentTypeValue.fromApi(restored.type),
      amountPaise: restored.amountPaise,
      method: restored.method,
      paymentDate: restored.paymentDate,
      notes: restored.notes,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.payment,
      entityId: restored.id,
      action: PendingSyncAction.create,
      payload: paymentCreatePayload(
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
    PaymentListQuery query = const PaymentListQuery(),
    bool flushPending = true,
  }) async {
    if (flushPending) {
      await flushPendingPaymentSync();
    }
    final remotePayments = await _api.list(
      partyId: query.partyId,
      dealId: query.dealId,
      type: query.type,
      from: query.from,
      to: query.to,
    );
    for (final item in remotePayments) {
      await _upsertPaymentItem(item);
    }
  }

  Future<void> flushPendingPaymentSync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.payment.name;
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

  Future<MoneyLedgerSnapshot> localLedgerSnapshot() async {
    final parties = await (_database.select(_database.parties)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    final allDeals = await (_database.select(_database.deals)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final allPayments = await (_database.select(_database.payments)
          ..where((row) => row.dealId.isNull() & row.deletedAt.isNull()))
        .get();
    final dealsByParty = _groupDealsByParty(allDeals);
    final paymentsByParty = _groupPaymentsByParty(allPayments);
    final rows = <MoneyLedgerParty>[];
    var totalReceivable = 0;
    var totalPayable = 0;

    for (final party in parties) {
      final deals = dealsByParty[party.id] ?? const <Deal>[];
      final payments = paymentsByParty[party.id] ?? const <Payment>[];
      final totals = _computePartyLedger(deals, payments);
      if (totals.receivablePaise == 0 &&
          totals.payablePaise == 0 &&
          totals.dealCount == 0) {
        continue;
      }

      totalReceivable += totals.receivablePaise;
      totalPayable += totals.payablePaise;
      rows.add(
        MoneyLedgerParty(
          partyId: party.id,
          name: party.name,
          phone: party.phone,
          type: party.type,
          receivablePaise: totals.receivablePaise,
          payablePaise: totals.payablePaise,
          overdueAmountPaise: totals.overdueAmountPaise,
          oldestOverdueDate: totals.oldestOverdueDate,
          dealCount: totals.dealCount,
          lastActivityAt: totals.lastActivityAt,
        ),
      );
    }

    rows.sort((a, b) {
      if (a.overdueAmountPaise != b.overdueAmountPaise) {
        return b.overdueAmountPaise.compareTo(a.overdueAmountPaise);
      }
      return (b.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(
              a.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    });

    return MoneyLedgerSnapshot(
      totalReceivablePaise: totalReceivable,
      totalPayablePaise: totalPayable,
      parties: rows,
    );
  }

  Future<PaymentListItem> _toListItem(Payment payment) async {
    final party = await (_database.select(_database.parties)
          ..where((row) => row.id.equals(payment.partyId)))
        .getSingleOrNull();
    final deal = payment.dealId == null
        ? null
        : await (_database.select(_database.deals)
              ..where((row) => row.id.equals(payment.dealId!)))
            .getSingleOrNull();

    return PaymentListItem(
      payment: payment,
      party: party == null
          ? PaymentPartySummary(
              id: payment.partyId,
              name: 'Unknown',
              type: 'CUSTOMER',
              trustTag: 'NEW',
            )
          : PaymentPartySummary.fromParty(party),
      deal: deal == null ? null : PaymentDealSummary.fromDeal(deal),
    );
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreatePaymentInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final created = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertPaymentItem(created);
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
    required UpdatePaymentInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final updated = await _api.update(id, input);
      await _upsertPaymentItem(updated);
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
      await _upsertPaymentItem(deleted);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _upsertPaymentItem(PaymentListItem item) async {
    await _upsertPayment(item.payment);
    final deal = item.deal;
    if (deal != null && deal.id.isNotEmpty) {
      await (_database.update(_database.deals)
            ..where((row) => row.id.equals(deal.id) & row.deletedAt.isNull()))
          .write(
        DealsCompanion(
          paidPaise: Value(deal.paidPaise),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }

  Map<String, List<Deal>> _groupDealsByParty(List<Deal> deals) {
    final grouped = <String, List<Deal>>{};
    for (final deal in deals) {
      (grouped[deal.partyId] ??= []).add(deal);
    }
    return grouped;
  }

  Map<String, List<Payment>> _groupPaymentsByParty(List<Payment> payments) {
    final grouped = <String, List<Payment>>{};
    for (final payment in payments) {
      (grouped[payment.partyId] ??= []).add(payment);
    }
    return grouped;
  }

  Future<void> _upsertPayment(Payment payment) {
    return _database
        .into(_database.payments)
        .insertOnConflictUpdate(payment.toCompanion(false));
  }

  Future<void> _applyLinkedPaymentLocal(Payment payment) async {
    final deal = await (_database.select(_database.deals)
          ..where((row) {
            return row.id.equals(payment.dealId!) &
                row.partyId.equals(payment.partyId) &
                row.deletedAt.isNull();
          }))
        .getSingleOrNull();

    if (deal == null) {
      throw StateError('Select a valid deal');
    }

    final paymentType = PaymentTypeValue.fromApi(payment.type);
    if (deal.type == 'SALE' && paymentType != PaymentTypeValue.received) {
      throw StateError('Sale deals need received payments');
    }
    if (deal.type == 'PURCHASE' && paymentType != PaymentTypeValue.paid) {
      throw StateError('Purchase deals need paid payments');
    }

    final nextPaid = deal.paidPaise + payment.amountPaise;
    if (nextPaid > deal.totalPaise) {
      throw StateError('Payment exceeds deal total');
    }

    await (_database.update(_database.deals)
          ..where((row) => row.id.equals(deal.id) & row.deletedAt.isNull()))
        .write(
      DealsCompanion(
        paidPaise: Value(nextPaid),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> _reverseLinkedPaymentLocal(Payment payment) async {
    final deal = await (_database.select(_database.deals)
          ..where(
            (row) => row.id.equals(payment.dealId!) & row.deletedAt.isNull(),
          ))
        .getSingleOrNull();
    if (deal == null) {
      return;
    }

    final nextPaid = _clampPositive(deal.paidPaise - payment.amountPaise);
    await (_database.update(_database.deals)
          ..where((row) => row.id.equals(deal.id) & row.deletedAt.isNull()))
        .write(
      DealsCompanion(
        paidPaise: Value(nextPaid),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  _PartyLedgerTotals _computePartyLedger(
    List<Deal> deals,
    List<Payment> unlinkedPayments,
  ) {
    var receivable = 0;
    var payable = 0;
    var overdueReceivable = 0;
    var overduePayable = 0;
    DateTime? oldestOverdueDate;
    DateTime? lastActivityAt;
    final todayOnly = dateOnly(DateTime.now());

    for (final deal in deals) {
      final remaining = deal.totalPaise - deal.paidPaise;
      if (deal.updatedAt
          .isAfter(lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0))) {
        lastActivityAt = deal.updatedAt;
      }
      if (remaining <= 0) {
        continue;
      }

      if (deal.type == 'SALE') {
        receivable += remaining;
      } else {
        payable += remaining;
      }

      final due = deal.paymentDue;
      if (due != null && dateOnly(due).isBefore(todayOnly)) {
        if (deal.type == 'SALE') {
          overdueReceivable += remaining;
        } else {
          overduePayable += remaining;
        }
        if (oldestOverdueDate == null || due.isBefore(oldestOverdueDate)) {
          oldestOverdueDate = due;
        }
      }
    }

    for (final payment in unlinkedPayments) {
      if (payment.paymentDate
          .isAfter(lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0))) {
        lastActivityAt = payment.paymentDate;
      }
      if (payment.type == PaymentTypeValue.received.apiValue) {
        receivable = _clampPositive(receivable - payment.amountPaise);
        overdueReceivable =
            _clampPositive(overdueReceivable - payment.amountPaise);
      } else {
        payable = _clampPositive(payable - payment.amountPaise);
        overduePayable = _clampPositive(overduePayable - payment.amountPaise);
      }
    }

    final overdue = overdueReceivable + overduePayable;
    return _PartyLedgerTotals(
      receivablePaise: receivable,
      payablePaise: payable,
      overdueAmountPaise: overdue,
      oldestOverdueDate: overdue > 0 ? oldestOverdueDate : null,
      dealCount: deals.length,
      lastActivityAt: lastActivityAt,
    );
  }

  CreatePaymentInput _createInputFromPayload(Map<String, dynamic> payload) {
    return CreatePaymentInput(
      partyId: payload['partyId'] as String,
      dealId: payload['dealId'] as String?,
      type: PaymentTypeValue.fromApi(payload['type'] as String),
      amountPaise: moneyTextToPaise(payload['amount'] as String),
      method: payload['method'] as String?,
      paymentDate: DateTime.parse(payload['paymentDate'] as String).toUtc(),
      notes: payload['notes'] as String?,
    );
  }

  UpdatePaymentInput _updateInputFromPayload(Map<String, dynamic> payload) {
    return UpdatePaymentInput(
      partyId: payload['partyId'] as String,
      dealId: payload['dealId'] as String?,
      type: PaymentTypeValue.fromApi(payload['type'] as String),
      amountPaise: moneyTextToPaise(payload['amount'] as String),
      method: payload['method'] as String?,
      paymentDate: DateTime.parse(payload['paymentDate'] as String).toUtc(),
      notes: payload['notes'] as String?,
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  int _clampPositive(int value) {
    return value < 0 ? 0 : value;
  }
}

class _PartyLedgerTotals {
  const _PartyLedgerTotals({
    required this.receivablePaise,
    required this.payablePaise,
    required this.overdueAmountPaise,
    required this.dealCount,
    this.oldestOverdueDate,
    this.lastActivityAt,
  });

  final int receivablePaise;
  final int payablePaise;
  final int overdueAmountPaise;
  final int dealCount;
  final DateTime? oldestOverdueDate;
  final DateTime? lastActivityAt;
}
