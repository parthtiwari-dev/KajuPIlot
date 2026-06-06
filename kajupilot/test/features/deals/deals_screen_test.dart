import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/features/deals/data/deal_models.dart';
import 'package:kajupilot/features/deals/data/deals_api.dart';
import 'package:kajupilot/features/deals/data/deals_repository.dart';
import 'package:kajupilot/features/deals/deals_screen.dart';
import 'package:kajupilot/features/deals/widgets/deal_sheet.dart';
import 'package:kajupilot/features/people/data/parties_api.dart';
import 'package:kajupilot/features/people/data/parties_repository.dart';
import 'package:kajupilot/features/people/data/party_models.dart';
import 'package:kajupilot/features/people/person_profile_screen.dart';

void main() {
  testWidgets('Deals screen shows empty state', (tester) async {
    await tester.pumpWidget(
      dealsWidget(
        const DealsScreen(),
        items: const [],
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Deals'), findsOneWidget);
    expect(find.text('No deals yet'), findsOneWidget);
  });

  testWidgets('Deals screen lists and searches local deals', (tester) async {
    await tester.pumpWidget(
      dealsWidget(
        const DealsScreen(),
        items: [
          testDealListItem(),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Amit Verma'), findsOneWidget);
    expect(find.textContaining('W320'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('deals-search-field')), 'w240');
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('Deal sheet validates and saves with live total', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DealsRepository(
      database: database,
      api: _OfflineDealsApi(),
      pendingSync: PendingSyncService(database),
      currentUserId: 'local-owner',
      idGenerator: _fixedIds(),
    );
    final partiesRepository = PartiesRepository(
      database: database,
      api: _OfflinePartiesApi(),
      pendingSync: PendingSyncService(database),
      currentUserId: 'local-owner',
      idGenerator: _fixedPartyIds(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dealsRepositoryProvider.overrideWithValue(repository),
          partiesRepositoryProvider.overrideWithValue(partiesRepository),
        ],
        child: MaterialApp(
          theme: KajuTheme.dark(),
          home: const Scaffold(body: DealSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('deal-save-button')));
    await tester.tap(find.byKey(const Key('deal-save-button')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Enter a person name'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('deal-party-field')));
    await tester.enterText(
      find.byKey(const Key('deal-party-field')),
      'New Buyer',
    );

    await tester.ensureVisible(find.byKey(const Key('deal-quantity-field')));
    await tester.enterText(find.byKey(const Key('deal-grade-field')), 'W320');
    await tester.enterText(
      find.byKey(const Key('deal-quantity-field')),
      '10 balti',
    );
    await tester.enterText(
      find.byKey(const Key('deal-rate-field')),
      '780 per balti',
    );
    await tester.enterText(
      find.byKey(const Key('deal-line-total-field')),
      '39000',
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('39,000'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('deal-save-button')));
    await tester.tap(find.byKey(const Key('deal-save-button')));
    await tester.pump(const Duration(milliseconds: 300));

    final deals = await database.select(database.deals).get();
    final parties = await database.select(database.parties).get();
    final lines = await database.select(database.dealItems).get();

    expect(parties.single.name, 'New Buyer');
    expect(parties.single.type, 'CUSTOMER');
    expect(deals.single.cashewGrade, 'W320');
    expect(deals.single.totalPaise, 3900000);
    expect(lines.single.quantityText, '10 balti');
  });

  testWidgets('People profile Deals tab shows party deals', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partyProvider.overrideWith(
            (ref, partyId) => Stream.value(testParty()),
          ),
          partyStatsProvider.overrideWith(
            (ref, partyId) => const PartyStats(
              dealCount: 1,
              pendingAmountPaise: 3400000,
            ),
          ),
          dealListProvider.overrideWith(
            (ref, query) => Stream.value([
              testDealListItem(),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: KajuTheme.dark(),
          home: const PersonProfileScreen(partyId: 'party-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amit Verma'), findsWidgets);
    expect(find.textContaining('W320'), findsOneWidget);
  });
}

Widget dealsWidget(
  Widget child, {
  required List<DealListItem> items,
}) {
  return ProviderScope(
    overrides: [
      dealListProvider.overrideWith((ref, query) => Stream.value(items.where(
            (item) {
              final search = query.search.trim().toLowerCase();
              final matchesSearch = search.isEmpty ||
                  item.party.name.toLowerCase().contains(search) ||
                  item.gradeSummary.toLowerCase().contains(search) ||
                  item.items.any(
                    (line) =>
                        line.grade.toLowerCase().contains(search) ||
                        line.quantityText.toLowerCase().contains(search),
                  );
              final matchesFilter = query.filter.status == null ||
                  item.status == query.filter.status;
              final matchesParty =
                  query.partyId == null || item.deal.partyId == query.partyId;
              return matchesSearch && matchesFilter && matchesParty;
            },
          ).toList())),
    ],
    child: MaterialApp(
      theme: KajuTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
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

Party testParty() {
  final now = DateTime.now().toUtc();
  return Party(
    id: 'party-1',
    userId: 'local-owner',
    name: 'Amit Verma',
    phone: '98765',
    type: 'CUSTOMER',
    trustTag: 'NEW',
    notes: null,
    syncId: 'party-sync-1',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

DealListItem testDealListItem({String cashewGrade = 'W320'}) {
  return DealListItem(
    deal: testDeal(cashewGrade: cashewGrade),
    party: const DealPartySummary(
      id: 'party-1',
      name: 'Amit Verma',
      type: 'CUSTOMER',
      trustTag: 'NEW',
    ),
    items: [testDealItem()],
  );
}

DealItem testDealItem() {
  final now = DateTime.now().toUtc();
  return DealItem(
    id: 'line-1',
    dealId: 'deal-1',
    grade: 'W320',
    quantityText: '10 balti',
    rateText: '780 per balti',
    lineTotalPaise: 3900000,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

Deal testDeal({String cashewGrade = 'W320'}) {
  final now = DateTime.now().toUtc();
  return Deal(
    id: 'deal-1',
    userId: 'local-owner',
    partyId: 'party-1',
    type: 'SALE',
    cashewGrade: cashewGrade,
    quantityGrams: 0,
    ratePaisePerKg: 0,
    totalPaise: 3900000,
    paidPaise: 500000,
    status: 'CONFIRMED',
    deliveryDate: null,
    paymentDue: null,
    notes: null,
    syncId: 'sync-1',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

String Function() _fixedIds() {
  final ids = ['deal-widget', 'sync-widget', 'line-widget'];
  return () => ids.removeAt(0);
}

String Function() _fixedPartyIds() {
  final ids = ['party-widget', 'party-sync-widget'];
  return () => ids.removeAt(0);
}

class _OfflineDealsApi extends DealsApi {
  _OfflineDealsApi() : super(KajuApiClient(Dio()));

  @override
  Future<DealListItem> create({
    required String id,
    required String syncId,
    required CreateDealInput input,
  }) async {
    throw StateError('offline in widget test');
  }
}

class _OfflinePartiesApi extends PartiesApi {
  _OfflinePartiesApi() : super(KajuApiClient(Dio()));

  @override
  Future<PartyListItem> create({
    required String id,
    required String syncId,
    required CreatePartyInput input,
  }) async {
    throw StateError('offline in widget test');
  }
}
