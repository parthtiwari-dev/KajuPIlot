import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pending_sync_service.dart';
import '../../../core/utils/currency.dart';
import 'deal_models.dart';
import 'deals_api.dart';

final dealsApiProvider = Provider<DealsApi>((ref) {
  return DealsApi(ref.watch(apiClientProvider));
});

final dealsRepositoryProvider = Provider<DealsRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return DealsRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(dealsApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final dealListProvider =
    StreamProvider.family<List<DealListItem>, DealListQuery>((ref, query) {
  return ref.watch(dealsRepositoryProvider).watchDeals(query);
});

final dealProvider =
    StreamProvider.family<DealListItem?, String>((ref, dealId) {
  return ref.watch(dealsRepositoryProvider).watchDealItem(dealId);
});

class DealsRepository {
  DealsRepository({
    required AppDatabase database,
    required DealsApi api,
    required PendingSyncService pendingSync,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _pendingSync = pendingSync,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final DealsApi _api;
  final PendingSyncService _pendingSync;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<DealListItem>> watchDeals(DealListQuery query) {
    return (_database.select(_database.deals)
          ..where((row) {
            var expression = row.deletedAt.isNull();
            if (query.partyId != null) {
              expression = expression & row.partyId.equals(query.partyId!);
            }
            if (query.filter.status != null) {
              expression =
                  expression & row.status.equals(query.filter.status!.apiValue);
            }
            return expression;
          })
          ..orderBy([
            (row) => OrderingTerm.desc(row.updatedAt),
            (row) => OrderingTerm.desc(row.createdAt),
          ]))
        .watch()
        .asyncMap((deals) => _mapAndFilter(deals, query));
  }

  Stream<DealListItem?> watchDealItem(String dealId) {
    return (_database.select(_database.deals)
          ..where((row) => row.id.equals(dealId) & row.deletedAt.isNull()))
        .watchSingleOrNull()
        .asyncMap((deal) => deal == null ? null : _toListItem(deal));
  }

  Future<Deal?> getDeal(String dealId) {
    return (_database.select(_database.deals)
          ..where((row) => row.id.equals(dealId) & row.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<Party>> localParties() {
    return (_database.select(_database.parties)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
  }

  Future<Deal> create(CreateDealInput input) async {
    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final lineInputs = _lineInputsWithIds(input.items);
    final deal = Deal(
      id: id,
      userId: _currentUserId,
      partyId: input.partyId,
      type: input.type.apiValue,
      cashewGrade: dealGradeSummary(lineInputs),
      quantityGrams: 0,
      ratePaisePerKg: 0,
      totalPaise: input.totalPaise,
      paidPaise: input.paidPaise,
      status: input.status.apiValue,
      deliveryDate: input.deliveryDate?.toUtc(),
      paymentDue: input.paymentDue?.toUtc(),
      notes: _clean(input.notes),
      syncId: syncId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
    final normalizedInput = CreateDealInput(
      partyId: input.partyId,
      type: input.type,
      items: lineInputs,
      totalPaise: input.totalPaise,
      paidPaise: input.paidPaise,
      status: input.status,
      deliveryDate: input.deliveryDate,
      paymentDue: input.paymentDue,
      notes: input.notes,
    );

    await _database.transaction(() async {
      await _upsertDeal(deal);
      await _replaceDealItems(id, lineInputs, now);
    });

    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.deal,
      entityId: id,
      action: PendingSyncAction.create,
      payload: dealCreatePayload(
        id: id,
        syncId: syncId,
        input: normalizedInput,
      ),
      now: now,
    );

    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: normalizedInput,
    );

    return deal;
  }

  Future<Deal?> update(String dealId, UpdateDealInput input) async {
    final existing = await getDeal(dealId);
    if (existing == null) {
      return null;
    }

    final existingItems = await _dealItems(dealId);
    final now = DateTime.now().toUtc();
    final lineInputs =
        input.items == null ? null : _lineInputsWithIds(input.items!);
    final totalPaise = input.totalPaise ?? existing.totalPaise;
    final updated = existing.copyWith(
      partyId: input.partyId,
      type: input.type?.apiValue,
      cashewGrade: lineInputs == null ? null : dealGradeSummary(lineInputs),
      quantityGrams: lineInputs == null ? null : 0,
      ratePaisePerKg: lineInputs == null ? null : 0,
      totalPaise: input.totalPaise,
      paidPaise: input.paidPaise,
      deliveryDate: input.clearDeliveryDate
          ? const Value(null)
          : input.deliveryDate == null
              ? const Value.absent()
              : Value(input.deliveryDate!.toUtc()),
      paymentDue: input.clearPaymentDue
          ? const Value(null)
          : input.paymentDue == null
              ? const Value.absent()
              : Value(input.paymentDue!.toUtc()),
      notes: input.clearNotes
          ? const Value(null)
          : input.notes == null
              ? const Value.absent()
              : Value(_clean(input.notes)),
      updatedAt: now,
    );

    _assertPaidStatusIsValid(updated.copyWith(totalPaise: totalPaise));
    await _database.transaction(() async {
      await _upsertDeal(updated);
      if (lineInputs != null) {
        await _replaceDealItems(dealId, lineInputs, now);
      }
    });

    final normalizedInput = UpdateDealInput(
      partyId: input.partyId,
      type: input.type,
      items: lineInputs,
      totalPaise: input.totalPaise,
      paidPaise: input.paidPaise,
      deliveryDate: input.deliveryDate,
      clearDeliveryDate: input.clearDeliveryDate,
      paymentDue: input.paymentDue,
      clearPaymentDue: input.clearPaymentDue,
      notes: input.notes,
      clearNotes: input.clearNotes,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.deal,
      entityId: dealId,
      action: PendingSyncAction.update,
      payload: dealUpdatePayload(normalizedInput),
      now: now,
    );

    await _tryUpdateOnApi(
      pendingId: pendingId,
      id: dealId,
      input: normalizedInput,
    );

    if (lineInputs == null && existingItems.isEmpty) {
      await _replaceDealItems(
        dealId,
        _legacyLineInputs(existing),
        now,
      );
    }

    return updated;
  }

  Future<Deal?> updateStatus(String dealId, DealStatusValue status) async {
    final existing = await getDeal(dealId);
    if (existing == null) {
      return null;
    }

    final current = DealStatusValue.fromApi(existing.status);
    if (current == status) {
      return existing;
    }

    if (current.next != status) {
      throw StateError('Invalid status transition');
    }

    if (status == DealStatusValue.paid &&
        existing.paidPaise < existing.totalPaise) {
      throw StateError('Paid status requires full payment');
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      status: status.apiValue,
      updatedAt: now,
    );

    await _upsertDeal(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.deal,
      entityId: dealId,
      action: PendingSyncAction.update,
      payload: {
        'statusOnly': true,
        'status': status.apiValue,
      },
      now: now,
    );

    await _tryUpdateStatusOnApi(
      pendingId: pendingId,
      id: dealId,
      status: status,
    );

    return updated;
  }

  Future<Deal?> softDelete(String dealId) async {
    final existing = await getDeal(dealId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );

    await _upsertDeal(deleted);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.deal,
      entityId: dealId,
      action: PendingSyncAction.delete,
      payload: {'id': dealId},
      now: now,
    );

    await _tryDeleteOnApi(pendingId: pendingId, id: dealId);

    return deleted;
  }

  Future<void> restore(Deal deal) async {
    final now = DateTime.now().toUtc();
    final restored = deal.copyWith(
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await _upsertDeal(restored);

    final pendingEntries = await _pendingSync.pending(limit: 100);
    for (final entry in pendingEntries.where((entry) {
      return entry.entityType == PendingSyncEntityType.deal.name &&
          entry.entityId == deal.id &&
          entry.action == PendingSyncAction.delete.name;
    })) {
      await _pendingSync.remove(entry.id);
    }

    final items = await _dealItems(restored.id);
    final lineInputs = items.isEmpty
        ? _legacyLineInputs(restored)
        : items.map(_lineInputFromRow).toList();
    final input = CreateDealInput(
      partyId: restored.partyId,
      type: DealTypeValue.fromApi(restored.type),
      items: lineInputs,
      totalPaise: restored.totalPaise,
      paidPaise: restored.paidPaise,
      status: DealStatusValue.fromApi(restored.status),
      deliveryDate: restored.deliveryDate,
      paymentDue: restored.paymentDue,
      notes: restored.notes,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.deal,
      entityId: restored.id,
      action: PendingSyncAction.create,
      payload: dealCreatePayload(
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
    DealListQuery query = const DealListQuery(),
    bool flushPending = true,
  }) async {
    if (flushPending) {
      await flushPendingDealSync();
    }
    final remoteDeals = await _api.list(
      status: query.filter.status,
      partyId: query.partyId,
      grade: query.search,
    );
    for (final item in remoteDeals) {
      await _upsertDealItem(item);
    }
  }

  Future<void> flushPendingDealSync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.deal.name;
    })) {
      try {
        final payload = await _pendingSync.decodedPayload(entry);
        switch (entry.action) {
          case 'create':
            final input = _createInputFromPayload(payload);
            await _tryCreateOnApi(
              pendingId: entry.id,
              id: payload['id'] as String,
              syncId: payload['syncId'] as String,
              input: input,
              markAttemptOnFailure: true,
            );
          case 'update':
            if (payload['statusOnly'] == true) {
              await _tryUpdateStatusOnApi(
                pendingId: entry.id,
                id: entry.entityId,
                status: DealStatusValue.fromApi(payload['status'] as String),
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

  Future<List<DealListItem>> _mapAndFilter(
    List<Deal> deals,
    DealListQuery query,
  ) async {
    final normalizedSearch = query.search.trim().toLowerCase();
    final items = <DealListItem>[];

    for (final deal in deals) {
      final item = await _toListItem(deal);
      if (!_matchesSearch(item, normalizedSearch) ||
          !_matchesFilter(item, query.filter) ||
          !_matchesParty(item, query.partyId)) {
        continue;
      }
      items.add(item);
    }

    return items;
  }

  Future<DealListItem> _toListItem(Deal deal) async {
    final party = await (_database.select(_database.parties)
          ..where((row) => row.id.equals(deal.partyId)))
        .getSingleOrNull();
    final items = await _dealItems(deal.id);

    return DealListItem(
      deal: deal,
      party: party == null
          ? DealPartySummary(
              id: deal.partyId,
              name: 'Unknown',
              type: 'CUSTOMER',
              trustTag: 'NEW',
            )
          : DealPartySummary.fromParty(party),
      items: items,
    );
  }

  bool _matchesSearch(DealListItem item, String search) {
    if (search.isEmpty) {
      return true;
    }

    return item.party.name.toLowerCase().contains(search) ||
        item.gradeSummary.toLowerCase().contains(search) ||
        item.items.any((line) {
          return line.grade.toLowerCase().contains(search) ||
              line.quantityText.toLowerCase().contains(search) ||
              (line.rateText ?? '').toLowerCase().contains(search);
        });
  }

  bool _matchesFilter(DealListItem item, DealListFilter filter) {
    final status = filter.status;
    if (status == null) {
      return true;
    }
    return item.status == status;
  }

  bool _matchesParty(DealListItem item, String? partyId) {
    return partyId == null || item.deal.partyId == partyId;
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreateDealInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final created = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertDealItem(created);
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
    required UpdateDealInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final updated = await _api.update(id, input);
      await _upsertDealItem(updated);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _tryUpdateStatusOnApi({
    required String pendingId,
    required String id,
    required DealStatusValue status,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final updated = await _api.updateStatus(id, status);
      await _upsertDealItem(updated);
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
      await _upsertDealItem(deleted);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<void> _upsertDealItem(DealListItem item) {
    return _database.transaction(() async {
      await _upsertDeal(item.deal);
      await _replaceDealItems(
        item.deal.id,
        item.items.map(_lineInputFromRow).toList(),
        item.deal.updatedAt,
      );
    });
  }

  Future<void> _upsertDeal(Deal deal) {
    return _database
        .into(_database.deals)
        .insertOnConflictUpdate(deal.toCompanion(false));
  }

  Future<List<DealItem>> _dealItems(String dealId) {
    return (_database.select(_database.dealItems)
          ..where((row) => row.dealId.equals(dealId))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
  }

  Future<void> _replaceDealItems(
    String dealId,
    List<DealLineInput> items,
    DateTime now,
  ) async {
    await (_database.delete(_database.dealItems)
          ..where((row) => row.dealId.equals(dealId)))
        .go();

    for (var index = 0; index < items.length; index += 1) {
      final item = items[index];
      await _database.into(_database.dealItems).insert(
            DealItemsCompanion.insert(
              id: item.id ?? _idGenerator(),
              dealId: dealId,
              grade: item.grade.trim(),
              quantityText: item.quantityText.trim(),
              rateText: Value(_clean(item.rateText)),
              lineTotalPaise: item.lineTotalPaise,
              sortOrder: Value(index),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  List<DealLineInput> _lineInputsWithIds(List<DealLineInput> items) {
    return [
      for (final item in items)
        DealLineInput(
          id: item.id ?? _idGenerator(),
          grade: item.grade,
          quantityText: item.quantityText,
          rateText: item.rateText,
          lineTotalPaise: item.lineTotalPaise,
        ),
    ];
  }

  List<DealLineInput> _legacyLineInputs(Deal deal) {
    return [
      DealLineInput(
        id: _idGenerator(),
        grade: deal.cashewGrade,
        quantityText: 'Bucket-wise',
        lineTotalPaise: deal.totalPaise,
      ),
    ];
  }

  DealLineInput _lineInputFromRow(DealItem item) {
    return DealLineInput(
      id: item.id,
      grade: item.grade,
      quantityText: item.quantityText,
      rateText: item.rateText,
      lineTotalPaise: item.lineTotalPaise,
    );
  }

  CreateDealInput _createInputFromPayload(Map<String, dynamic> payload) {
    return CreateDealInput(
      partyId: payload['partyId'] as String,
      type: DealTypeValue.fromApi(payload['type'] as String),
      items: _lineInputsFromPayload(payload['items']),
      totalPaise: decimalRupeesToPaise(payload['totalAmount']),
      paidPaise: decimalRupeesToPaise(payload['paidAmount'] as String?),
      status: DealStatusValue.fromApi(
        payload['status'] as String? ?? DealStatusValue.confirmed.apiValue,
      ),
      deliveryDate: _dateFromPayload(payload['deliveryDate']),
      paymentDue: _dateFromPayload(payload['paymentDue']),
      notes: payload['notes'] as String?,
    );
  }

  UpdateDealInput _updateInputFromPayload(Map<String, dynamic> payload) {
    return UpdateDealInput(
      partyId: payload['partyId'] as String?,
      type: payload['type'] == null
          ? null
          : DealTypeValue.fromApi(payload['type'] as String),
      items: payload['items'] == null
          ? null
          : _lineInputsFromPayload(payload['items']),
      totalPaise: payload['totalAmount'] == null
          ? null
          : decimalRupeesToPaise(payload['totalAmount']),
      paidPaise: payload['paidAmount'] == null
          ? null
          : decimalRupeesToPaise(payload['paidAmount']),
      deliveryDate: _dateFromPayload(payload['deliveryDate']),
      clearDeliveryDate: payload.containsKey('deliveryDate') &&
          payload['deliveryDate'] == null,
      paymentDue: _dateFromPayload(payload['paymentDue']),
      clearPaymentDue:
          payload.containsKey('paymentDue') && payload['paymentDue'] == null,
      notes: payload['notes'] as String?,
      clearNotes: payload.containsKey('notes') && payload['notes'] == null,
    );
  }

  List<DealLineInput> _lineInputsFromPayload(Object? value) {
    final rows = value is List<dynamic> ? value : const <dynamic>[];
    return rows.whereType<Map<String, dynamic>>().map((row) {
      return DealLineInput(
        id: row['id'] as String?,
        grade: row['grade'] as String,
        quantityText: row['quantityText'] as String,
        rateText: row['rateText'] as String?,
        lineTotalPaise: decimalRupeesToPaise(row['totalAmount']),
      );
    }).toList();
  }

  void _assertPaidStatusIsValid(Deal deal) {
    if (DealStatusValue.fromApi(deal.status) == DealStatusValue.paid &&
        deal.paidPaise < deal.totalPaise) {
      throw StateError('Paid status requires full payment');
    }
  }

  DateTime? _dateFromPayload(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String).toUtc();
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
