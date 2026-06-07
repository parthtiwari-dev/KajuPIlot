import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/app_database_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pending_sync_service.dart';
import 'parties_api.dart';
import 'party_models.dart';

final partiesApiProvider = Provider<PartiesApi>((ref) {
  return PartiesApi(ref.watch(apiClientProvider));
});

final partiesRepositoryProvider = Provider<PartiesRepository>((ref) {
  final authSession = ref.watch(authControllerProvider).valueOrNull;
  return PartiesRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(partiesApiProvider),
    pendingSync: ref.watch(pendingSyncServiceProvider),
    currentUserId: authSession?.userId ?? 'local-owner',
  );
});

final partyListProvider =
    StreamProvider.family<List<PartyListItem>, PartyListQuery>((ref, query) {
  return ref.watch(partiesRepositoryProvider).watchParties(query);
});

final partyProvider = StreamProvider.family<Party?, String>((ref, partyId) {
  return ref.watch(partiesRepositoryProvider).watchParty(partyId);
});

final partyStatsProvider =
    FutureProvider.family<PartyStats, String>((ref, partyId) {
  return ref.watch(partiesRepositoryProvider).statsForParty(partyId);
});

final partyLedgerProvider =
    FutureProvider.family<PartyLedger, String>((ref, partyId) {
  return ref.watch(partiesRepositoryProvider).ledger(partyId);
});

final partyHistoryProvider =
    FutureProvider.family<PartyHistory, String>((ref, partyId) {
  return ref.watch(partiesRepositoryProvider).history(partyId);
});

class PartiesRepository {
  PartiesRepository({
    required AppDatabase database,
    required PartiesApi api,
    required PendingSyncService pendingSync,
    required String currentUserId,
    String Function()? idGenerator,
  })  : _database = database,
        _api = api,
        _pendingSync = pendingSync,
        _currentUserId = currentUserId,
        _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final PartiesApi _api;
  final PendingSyncService _pendingSync;
  final String _currentUserId;
  final String Function() _idGenerator;

  Stream<List<PartyListItem>> watchParties(PartyListQuery query) {
    return (_database.select(_database.parties)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([
            (row) => OrderingTerm.desc(row.updatedAt),
            (row) => OrderingTerm.asc(row.name),
          ]))
        .watch()
        .asyncMap((parties) => _mapAndFilter(parties, query));
  }

  Stream<Party?> watchParty(String partyId) {
    return (_database.select(_database.parties)
          ..where((row) => row.id.equals(partyId) & row.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Future<List<Party>> localParties() {
    return (_database.select(_database.parties)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
  }

  Future<Party?> getParty(String partyId) {
    return (_database.select(_database.parties)
          ..where((row) => row.id.equals(partyId) & row.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Party> create(CreatePartyInput input) async {
    final now = DateTime.now().toUtc();
    final id = _idGenerator();
    final syncId = _idGenerator();
    final party = Party(
      id: id,
      userId: _currentUserId,
      name: input.name.trim(),
      phone: _clean(input.phone),
      type: input.type.apiValue,
      trustTag: input.trustTag.apiValue,
      trustTagManualOverride: input.trustTag != TrustTagValue.fresh,
      notes: _clean(input.notes),
      syncId: syncId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    await _upsertParty(party);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.party,
      entityId: id,
      action: PendingSyncAction.create,
      payload: partyCreatePayload(id: id, syncId: syncId, input: input),
      now: now,
    );

    await _tryCreateOnApi(
      pendingId: pendingId,
      id: id,
      syncId: syncId,
      input: input,
    );

    return party;
  }

  Future<Party?> update(String partyId, UpdatePartyInput input) async {
    final existing = await getParty(partyId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      name: input.name?.trim(),
      phone: input.clearPhone
          ? const Value(null)
          : input.phone == null
              ? const Value.absent()
              : Value(_clean(input.phone)),
      type: input.type?.apiValue,
      trustTag: input.trustTag?.apiValue,
      trustTagManualOverride: input.trustTag == null ? null : true,
      notes: input.clearNotes
          ? const Value(null)
          : input.notes == null
              ? const Value.absent()
              : Value(_clean(input.notes)),
      updatedAt: now,
    );

    await _upsertParty(updated);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.party,
      entityId: partyId,
      action: PendingSyncAction.update,
      payload: partyUpdatePayload(input),
      now: now,
    );

    await _tryUpdateOnApi(pendingId: pendingId, id: partyId, input: input);

    return updated;
  }

  Future<Party?> softDelete(String partyId) async {
    final existing = await getParty(partyId);
    if (existing == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );

    await _upsertParty(deleted);
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.party,
      entityId: partyId,
      action: PendingSyncAction.delete,
      payload: {'id': partyId},
      now: now,
    );

    await _tryDeleteOnApi(pendingId: pendingId, id: partyId);

    return deleted;
  }

  Future<void> restore(Party party) async {
    final now = DateTime.now().toUtc();
    final restored = party.copyWith(
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await _upsertParty(restored);

    final pendingEntries = await _pendingSync.pending(limit: 100);
    for (final entry in pendingEntries.where((entry) {
      return entry.entityType == PendingSyncEntityType.party.name &&
          entry.entityId == party.id &&
          entry.action == PendingSyncAction.delete.name;
    })) {
      await _pendingSync.remove(entry.id);
    }

    final input = CreatePartyInput(
      name: restored.name,
      phone: restored.phone,
      type: PartyTypeValue.fromApi(restored.type),
      trustTag: TrustTagValue.fromApi(restored.trustTag),
      notes: restored.notes,
    );
    final pendingId = await _pendingSync.enqueue(
      entityType: PendingSyncEntityType.party,
      entityId: restored.id,
      action: PendingSyncAction.create,
      payload: partyCreatePayload(
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

  Future<void> refresh({bool flushPending = true}) async {
    if (flushPending) {
      await flushPendingPartySync();
    }
    final remoteParties = await _api.list();
    for (final item in remoteParties) {
      await _upsertParty(item.party);
    }
  }

  Future<void> flushPendingPartySync() async {
    final entries = await _pendingSync.pending(limit: 100);
    for (final entry in entries.where((entry) {
      return entry.entityType == PendingSyncEntityType.party.name;
    })) {
      try {
        final payload = await _pendingSync.decodedPayload(entry);
        switch (entry.action) {
          case 'create':
            final input = CreatePartyInput(
              name: payload['name'] as String,
              phone: payload['phone'] as String?,
              type: PartyTypeValue.fromApi(payload['type'] as String),
              trustTag: TrustTagValue.fromApi(
                payload['trustTag'] as String? ?? TrustTagValue.fresh.apiValue,
              ),
              notes: payload['notes'] as String?,
            );
            await _tryCreateOnApi(
              pendingId: entry.id,
              id: payload['id'] as String,
              syncId: payload['syncId'] as String,
              input: input,
              markAttemptOnFailure: true,
            );
          case 'update':
            final input = UpdatePartyInput(
              name: payload['name'] as String?,
              phone: payload['phone'] as String?,
              clearPhone:
                  payload.containsKey('phone') && payload['phone'] == null,
              type: payload['type'] == null
                  ? null
                  : PartyTypeValue.fromApi(payload['type'] as String),
              trustTag: payload['trustTag'] == null
                  ? null
                  : TrustTagValue.fromApi(payload['trustTag'] as String),
              notes: payload['notes'] as String?,
              clearNotes:
                  payload.containsKey('notes') && payload['notes'] == null,
            );
            await _tryUpdateOnApi(
              pendingId: entry.id,
              id: entry.entityId,
              input: input,
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

  Future<PartyStats> statsForParty(String partyId) async {
    final deals = await (_database.select(_database.deals)
          ..where(
              (row) => row.partyId.equals(partyId) & row.deletedAt.isNull()))
        .get();
    final payments = await (_database.select(_database.payments)
          ..where((row) {
            return row.partyId.equals(partyId) &
                row.dealId.isNull() &
                row.deletedAt.isNull();
          }))
        .get();

    return _computeStats(deals, payments);
  }

  Future<PartyLedger> ledger(String partyId) async {
    try {
      return await _api.ledger(partyId);
    } catch (_) {
      final stats = await statsForParty(partyId);
      return PartyLedger(
        receivablePaise:
            stats.pendingAmountPaise > 0 ? stats.pendingAmountPaise : 0,
        payablePaise:
            stats.pendingAmountPaise < 0 ? stats.pendingAmountPaise.abs() : 0,
        netPaise: stats.pendingAmountPaise,
        overdueAmountPaise: stats.overdueAmountPaise,
        oldestOverdueDate: null,
      );
    }
  }

  Future<PartyHistory> history(String partyId) {
    return _api.history(partyId);
  }

  Future<void> _tryCreateOnApi({
    required String pendingId,
    required String id,
    required String syncId,
    required CreatePartyInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final created = await _api.create(id: id, syncId: syncId, input: input);
      await _upsertParty(created.party);
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
    required UpdatePartyInput input,
    bool markAttemptOnFailure = false,
  }) async {
    try {
      final updated = await _api.update(id, input);
      await _upsertParty(updated.party);
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
      await _upsertParty(deleted);
      await _pendingSync.remove(pendingId);
    } catch (_) {
      if (markAttemptOnFailure) {
        await _pendingSync.markAttempted(pendingId);
      }
    }
  }

  Future<List<PartyListItem>> _mapAndFilter(
    List<Party> parties,
    PartyListQuery query,
  ) async {
    final normalizedSearch = query.search.trim().toLowerCase();
    final allDeals = await (_database.select(_database.deals)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final allPayments = await (_database.select(_database.payments)
          ..where((row) => row.dealId.isNull() & row.deletedAt.isNull()))
        .get();
    final dealsByParty = _groupDealsByParty(allDeals);
    final paymentsByParty = _groupPaymentsByParty(allPayments);
    final items = <PartyListItem>[];

    for (final party in parties) {
      final item = PartyListItem(
        party: party,
        stats: _computeStats(
          dealsByParty[party.id] ?? const [],
          paymentsByParty[party.id] ?? const [],
        ),
      );

      if (!_matchesSearch(item, normalizedSearch) ||
          !_matchesFilter(item, query.filter)) {
        continue;
      }

      items.add(item);
    }

    return items;
  }

  PartyStats _computeStats(List<Deal> deals, List<Payment> payments) {
    var receivable = 0;
    var payable = 0;
    var overdueReceivable = 0;
    var overduePayable = 0;
    var totalSaleValue = 0;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    for (final deal in deals) {
      if (deal.type == PartyDealType.sale.apiValue) {
        totalSaleValue += deal.totalPaise;
      }
      final remaining = deal.totalPaise - deal.paidPaise;
      if (remaining <= 0) {
        continue;
      }

      if (deal.type == PartyDealType.sale.apiValue) {
        receivable += remaining;
      } else {
        payable += remaining;
      }

      final due = deal.paymentDue;
      if (due != null && due.isBefore(todayOnly)) {
        if (deal.type == PartyDealType.sale.apiValue) {
          overdueReceivable += remaining;
        } else {
          overduePayable += remaining;
        }
      }
    }

    for (final payment in payments) {
      if (payment.type == 'RECEIVED') {
        receivable = _clampPositive(receivable - payment.amountPaise);
        overdueReceivable =
            _clampPositive(overdueReceivable - payment.amountPaise);
      } else {
        payable = _clampPositive(payable - payment.amountPaise);
        overduePayable = _clampPositive(overduePayable - payment.amountPaise);
      }
    }

    return PartyStats(
      dealCount: deals.length,
      pendingAmountPaise: receivable - payable,
      overdueAmountPaise: overdueReceivable + overduePayable,
      totalSaleValuePaise: totalSaleValue,
    );
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

  bool _matchesSearch(PartyListItem item, String search) {
    if (search.isEmpty) {
      return true;
    }

    return item.party.name.toLowerCase().contains(search) ||
        (item.party.phone ?? '').toLowerCase().contains(search);
  }

  bool _matchesFilter(PartyListItem item, PartyListFilter filter) {
    return switch (filter) {
      PartyListFilter.all => true,
      PartyListFilter.customers => item.type == PartyTypeValue.customer,
      PartyListFilter.suppliers => item.type == PartyTypeValue.supplier,
      PartyListFilter.both => item.type == PartyTypeValue.both,
      PartyListFilter.overdue => item.stats.overdueAmountPaise > 0,
    };
  }

  Future<void> _upsertParty(Party party) {
    return _database
        .into(_database.parties)
        .insertOnConflictUpdate(party.toCompanion(false));
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  int _clampPositive(int value) {
    return value < 0 ? 0 : value;
  }
}

enum PartyDealType {
  sale('SALE'),
  purchase('PURCHASE');

  const PartyDealType(this.apiValue);

  final String apiValue;
}
