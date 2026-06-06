import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/money/data/money_models.dart';
import 'package:kajupilot/features/money/data/payments_api.dart';
import 'package:kajupilot/features/money/data/payments_repository.dart';

void main() {
  group('PaymentsRepository', () {
    late AppDatabase database;
    late FakePaymentsApi api;
    late PaymentsRepository repository;
    var ids = <String>[];
    var pendingIndex = 0;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      await seedParty(database);
      await seedDeal(database);
      api = FakePaymentsApi();
      ids = ['payment-1', 'sync-1'];
      pendingIndex = 0;
      repository = PaymentsRepository(
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

    test('linked payment updates local deal paid amount and queues sync',
        () async {
      api.failCreate = true;

      await repository.create(
        CreatePaymentInput(
          partyId: 'party-1',
          dealId: 'deal-1',
          type: PaymentTypeValue.received,
          amountPaise: 1000000,
          paymentDate: DateTime.utc(2026, 6, 7),
        ),
      );

      final deal = await database.select(database.deals).getSingle();
      final pending = await database.select(database.pendingSync).get();
      final payment = await database.select(database.payments).getSingle();

      expect(deal.paidPaise, 1500000);
      expect(payment.amountPaise, 1000000);
      expect(pending.single.entityType, PendingSyncEntityType.payment.name);
      expect(pending.single.payloadJson, contains('deal-1'));
    });

    test('party-level payment reduces local ledger without mutating deal',
        () async {
      await repository.create(
        CreatePaymentInput(
          partyId: 'party-1',
          type: PaymentTypeValue.received,
          amountPaise: 1000000,
          paymentDate: DateTime.utc(2026, 6, 7),
        ),
      );

      final deal = await database.select(database.deals).getSingle();
      final ledger = await repository.localLedgerSnapshot();

      expect(deal.paidPaise, 500000);
      expect(ledger.totalReceivablePaise, 2400000);
      expect(ledger.receivableParties.single.name, 'Amit Verma');
    });

    test('rejects overpaying a linked deal locally', () async {
      await expectLater(
        repository.create(
          CreatePaymentInput(
            partyId: 'party-1',
            dealId: 'deal-1',
            type: PaymentTypeValue.received,
            amountPaise: 4000000,
            paymentDate: DateTime.utc(2026, 6, 7),
          ),
        ),
        throwsStateError,
      );
    });

    test('remote payment upsert does not mutate soft-deleted deals', () async {
      api.remoteItems = [
        PaymentListItem(
          payment: testPayment(),
          party: const PaymentPartySummary(
            id: 'party-1',
            name: 'Amit Verma',
            type: 'CUSTOMER',
            trustTag: 'NEW',
          ),
          deal: const PaymentDealSummary(
            id: 'deal-1',
            partyId: 'party-1',
            type: 'SALE',
            cashewGrade: 'W320',
            totalPaise: 3900000,
            paidPaise: 2500000,
          ),
        ),
      ];
      await (database.update(database.deals)
            ..where((row) => row.id.equals('deal-1')))
          .write(
        DealsCompanion(
          deletedAt: Value(DateTime.utc(2026, 6, 8)),
        ),
      );

      await repository.refresh();

      final deal = await database.select(database.deals).getSingle();
      expect(deal.deletedAt, isNotNull);
      expect(deal.paidPaise, 500000);
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

Future<void> seedDeal(AppDatabase database) {
  final now = DateTime.utc(2026, 6, 7);
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
          syncId: 'deal-sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Payment testPayment() {
  final now = DateTime.utc(2026, 6, 7);
  return Payment(
    id: 'payment-remote',
    userId: 'server-user',
    partyId: 'party-1',
    dealId: 'deal-1',
    type: PaymentTypeValue.received.apiValue,
    amountPaise: 2000000,
    method: null,
    notes: null,
    paymentDate: now,
    syncId: 'payment-remote-sync',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

class FakePaymentsApi extends PaymentsApi {
  FakePaymentsApi() : super(KajuApiClient(Dio()));

  bool failCreate = false;
  List<PaymentListItem> remoteItems = const [];

  @override
  Future<List<PaymentListItem>> list({
    String? partyId,
    String? dealId,
    PaymentTypeValue? type,
    DateTime? from,
    DateTime? to,
  }) async {
    return remoteItems;
  }

  @override
  Future<PaymentListItem> create({
    required String id,
    required String syncId,
    required CreatePaymentInput input,
  }) async {
    if (failCreate) {
      throw StateError('offline');
    }

    final now = DateTime.utc(2026, 6, 7);
    return PaymentListItem(
      payment: Payment(
        id: id,
        userId: 'server-user',
        partyId: input.partyId,
        dealId: input.dealId,
        type: input.type.apiValue,
        amountPaise: input.amountPaise,
        method: input.method,
        notes: input.notes,
        paymentDate: input.paymentDate,
        syncId: syncId,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      party: const PaymentPartySummary(
        id: 'party-1',
        name: 'Amit Verma',
        type: 'CUSTOMER',
        trustTag: 'NEW',
      ),
      deal: input.dealId == null
          ? null
          : const PaymentDealSummary(
              id: 'deal-1',
              partyId: 'party-1',
              type: 'SALE',
              cashewGrade: 'W320',
              totalPaise: 3900000,
              paidPaise: 1500000,
            ),
    );
  }
}
