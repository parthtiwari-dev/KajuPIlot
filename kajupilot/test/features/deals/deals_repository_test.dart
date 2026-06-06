import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/deals/data/deal_models.dart';
import 'package:kajupilot/features/deals/data/deals_api.dart';
import 'package:kajupilot/features/deals/data/deals_repository.dart';

void main() {
  group('DealsRepository', () {
    late AppDatabase database;
    late FakeDealsApi api;
    late DealsRepository repository;
    var ids = <String>[];
    var pendingIndex = 0;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      await seedParty(database);
      api = FakeDealsApi();
      ids = ['deal-1', 'sync-1', 'line-1', 'line-2', 'line-3'];
      pendingIndex = 0;
      repository = DealsRepository(
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
        const CreateDealInput(
          partyId: 'party-1',
          items: [
            DealLineInput(
              grade: 'W320',
              quantityText: '10 balti',
              rateText: '780 per balti',
              lineTotalPaise: 3900000,
            ),
          ],
          totalPaise: 3900000,
        ),
      );

      final deal = await database.select(database.deals).getSingle();
      final items = await database.select(database.dealItems).get();
      final pending = await database.select(database.pendingSync).get();

      expect(deal.cashewGrade, 'W320');
      expect(deal.quantityGrams, 0);
      expect(deal.ratePaisePerKg, 0);
      expect(deal.totalPaise, 3900000);
      expect(items.single.quantityText, '10 balti');
      expect(pending, hasLength(1));
      expect(pending.single.payloadJson, contains('10 balti'));
    });

    test('removes pending sync when API create succeeds', () async {
      await repository.create(
        const CreateDealInput(
          partyId: 'party-1',
          items: [
            DealLineInput(
              grade: 'W320',
              quantityText: '10 balti',
              lineTotalPaise: 3900000,
            ),
          ],
          totalPaise: 3900000,
        ),
      );

      final pending = await database.select(database.pendingSync).get();
      final deal = await database.select(database.deals).getSingle();
      final items = await database.select(database.dealItems).get();

      expect(pending, isEmpty);
      expect(deal.userId, 'server-user');
      expect(items.single.grade, 'W320');
    });

    test('updates line items and soft deletes locally', () async {
      api.failUpdate = true;
      api.failDelete = true;
      await seedDeal(database);
      await seedDealItem(database);

      await repository.update(
        'deal-1',
        const UpdateDealInput(
          items: [
            DealLineInput(
              grade: 'W240',
              quantityText: '5 balti',
              lineTotalPaise: 1800000,
            ),
          ],
          totalPaise: 1800000,
        ),
      );
      await repository.softDelete('deal-1');

      final deal = await database.select(database.deals).getSingle();
      final items = await database.select(database.dealItems).get();
      final pending = await database.select(database.pendingSync).get();

      expect(deal.cashewGrade, 'W240');
      expect(deal.totalPaise, 1800000);
      expect(deal.deletedAt, isNotNull);
      expect(items.single.quantityText, '5 balti');
      expect(pending.map((entry) => entry.action), contains('update'));
      expect(pending.map((entry) => entry.action), contains('delete'));
    });

    test('clears nullable deal fields locally and in pending payload',
        () async {
      api.failUpdate = true;
      await seedDeal(database);
      final delivery = DateTime.utc(2026, 6, 10);
      final due = DateTime.utc(2026, 6, 12);
      await (database.update(database.deals)
            ..where((row) => row.id.equals('deal-1')))
          .write(
        DealsCompanion(
          deliveryDate: Value(delivery),
          paymentDue: Value(due),
          notes: const Value('Remove me'),
        ),
      );

      await repository.update(
        'deal-1',
        const UpdateDealInput(
          clearDeliveryDate: true,
          clearPaymentDue: true,
          clearNotes: true,
        ),
      );

      final deal = await database.select(database.deals).getSingle();
      final pending = await database.select(database.pendingSync).getSingle();

      expect(deal.deliveryDate, isNull);
      expect(deal.paymentDue, isNull);
      expect(deal.notes, isNull);
      expect(pending.payloadJson, contains('"deliveryDate":null'));
      expect(pending.payloadJson, contains('"paymentDue":null'));
      expect(pending.payloadJson, contains('"notes":null'));
    });

    test('queues status updates through pending sync', () async {
      api.failStatus = true;
      await seedDeal(database);

      await repository.updateStatus('deal-1', DealStatusValue.delivered);

      final deal = await database.select(database.deals).getSingle();
      final pending = await database.select(database.pendingSync).get();

      expect(deal.status, 'DELIVERED');
      expect(pending.single.action, PendingSyncAction.update.name);
      expect(pending.single.payloadJson, contains('statusOnly'));
    });

    test('watches filtered and searched deals by item text', () async {
      await seedDeal(database);
      await seedDealItem(database);
      await database.into(database.deals).insert(
            DealsCompanion.insert(
              id: 'deal-2',
              userId: 'local-owner',
              partyId: 'party-1',
              cashewGrade: 'Broken',
              quantityGrams: 0,
              ratePaisePerKg: 0,
              totalPaise: 500000,
              status: const Value('QUOTED'),
              syncId: 'sync-2',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      await database.into(database.dealItems).insert(
            DealItemsCompanion.insert(
              id: 'item-2',
              dealId: 'deal-2',
              grade: 'Broken',
              quantityText: '2 balti',
              lineTotalPaise: 500000,
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );

      final items = await repository
          .watchDeals(
            const DealListQuery(
              search: '2 balti',
              filter: DealListFilter.quoted,
            ),
          )
          .first;

      expect(items, hasLength(1));
      expect(items.single.items.single.grade, 'Broken');
    });
  });
}

Future<void> seedParty(AppDatabase database) {
  final now = DateTime.now().toUtc();
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

Future<void> seedDeal(AppDatabase database) {
  final now = DateTime.now().toUtc();
  return database.into(database.deals).insert(
        DealsCompanion.insert(
          id: 'deal-1',
          userId: 'local-owner',
          partyId: 'party-1',
          cashewGrade: 'W320',
          quantityGrams: 0,
          ratePaisePerKg: 0,
          totalPaise: 3900000,
          paidPaise: const Value(500000),
          syncId: 'sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> seedDealItem(AppDatabase database) {
  final now = DateTime.now().toUtc();
  return database.into(database.dealItems).insert(
        DealItemsCompanion.insert(
          id: 'line-1',
          dealId: 'deal-1',
          grade: 'W320',
          quantityText: '10 balti',
          rateText: const Value('780 per balti'),
          lineTotalPaise: 3900000,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class FakeDealsApi extends DealsApi {
  FakeDealsApi() : super(KajuApiClient(Dio()));

  bool failCreate = false;
  bool failUpdate = false;
  bool failStatus = false;
  bool failDelete = false;

  @override
  Future<DealListItem> create({
    required String id,
    required String syncId,
    required CreateDealInput input,
  }) async {
    if (failCreate) {
      throw StateError('offline');
    }

    return testDealItem(
      deal: testDeal(
        id: id,
        userId: 'server-user',
        syncId: syncId,
        cashewGrade: dealGradeSummary(input.items),
        totalPaise: input.totalPaise,
      ),
      items: input.items,
    );
  }

  @override
  Future<DealListItem> update(String id, UpdateDealInput input) async {
    if (failUpdate) {
      throw StateError('offline');
    }

    final items = input.items ??
        const [
          DealLineInput(
            id: 'line-1',
            grade: 'W320',
            quantityText: '10 balti',
            lineTotalPaise: 3900000,
          ),
        ];
    return testDealItem(
      deal: testDeal(
        id: id,
        userId: 'server-user',
        cashewGrade: dealGradeSummary(items),
        totalPaise: input.totalPaise ?? sumLineTotals(items),
      ),
      items: items,
    );
  }

  @override
  Future<DealListItem> updateStatus(String id, DealStatusValue status) async {
    if (failStatus) {
      throw StateError('offline');
    }

    return testDealItem(deal: testDeal(id: id, status: status.apiValue));
  }

  @override
  Future<DealListItem> delete(String id) async {
    if (failDelete) {
      throw StateError('offline');
    }

    return testDealItem(
        deal: testDeal(id: id, deletedAt: DateTime.now().toUtc()));
  }
}

DealListItem testDealItem({
  Deal? deal,
  List<DealLineInput> items = const [
    DealLineInput(
      id: 'line-1',
      grade: 'W320',
      quantityText: '10 balti',
      rateText: '780 per balti',
      lineTotalPaise: 3900000,
    ),
  ],
}) {
  final currentDeal = deal ?? testDeal();
  final now = DateTime.now().toUtc();
  return DealListItem(
    deal: currentDeal,
    party: const DealPartySummary(
      id: 'party-1',
      name: 'Amit Verma',
      type: 'CUSTOMER',
      trustTag: 'NEW',
    ),
    items: [
      for (var index = 0; index < items.length; index += 1)
        DealItem(
          id: items[index].id ?? 'line-$index',
          dealId: currentDeal.id,
          grade: items[index].grade,
          quantityText: items[index].quantityText,
          rateText: items[index].rateText,
          lineTotalPaise: items[index].lineTotalPaise,
          sortOrder: index,
          createdAt: now,
          updatedAt: now,
        ),
    ],
  );
}

Deal testDeal({
  String id = 'deal-1',
  String userId = 'local-owner',
  String syncId = 'sync-1',
  String cashewGrade = 'W320',
  int totalPaise = 3900000,
  int paidPaise = 500000,
  String status = 'CONFIRMED',
  DateTime? deletedAt,
}) {
  final now = DateTime.now().toUtc();
  return Deal(
    id: id,
    userId: userId,
    partyId: 'party-1',
    type: 'SALE',
    cashewGrade: cashewGrade,
    quantityGrams: 0,
    ratePaisePerKg: 0,
    totalPaise: totalPaise,
    paidPaise: paidPaise,
    status: status,
    deliveryDate: null,
    paymentDue: null,
    notes: null,
    syncId: syncId,
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}
