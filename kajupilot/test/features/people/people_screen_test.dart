import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/platform/phone_contact_picker.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/features/people/data/parties_api.dart';
import 'package:kajupilot/features/people/data/parties_repository.dart';
import 'package:kajupilot/features/people/data/party_models.dart';
import 'package:kajupilot/features/people/people_screen.dart';
import 'package:kajupilot/features/people/widgets/person_sheet.dart';

void main() {
  testWidgets('People screen shows empty state', (tester) async {
    await tester.pumpWidget(
      peopleWidget(
        const PeopleScreen(),
        items: const [],
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('People'), findsOneWidget);
    expect(find.text('No people yet'), findsOneWidget);
  });

  testWidgets('People screen lists local parties', (tester) async {
    await tester.pumpWidget(
      peopleWidget(
        const PeopleScreen(),
        items: [
          PartyListItem(
            party: testParty(name: 'Amit Verma'),
            stats: const PartyStats(),
          ),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Amit Verma'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
  });

  testWidgets('Person sheet validates and saves locally', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PartiesRepository(
      database: database,
      api: _OfflinePartiesApi(),
      pendingSync: PendingSyncService(database),
      currentUserId: 'local-owner',
      idGenerator: _fixedIds(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partiesRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: KajuTheme.dark(),
          home: const Scaffold(body: PersonSheet()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('person-save-button')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('person-name-field')),
      'Ramesh Sahu',
    );
    await tester.tap(find.byKey(const Key('person-save-button')));
    await tester.pump(const Duration(milliseconds: 300));

    final parties = await database.select(database.parties).get();
    expect(parties.single.name, 'Ramesh Sahu');
  });

  testWidgets('Person sheet imports phone contact into form fields', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PartiesRepository(
      database: database,
      api: _OfflinePartiesApi(),
      pendingSync: PendingSyncService(database),
      currentUserId: 'local-owner',
      idGenerator: _fixedIds(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partiesRepositoryProvider.overrideWithValue(repository),
          phoneContactPickerProvider.overrideWithValue(
            const _FakePhoneContactPicker(
              PhoneContact(name: 'Amit Verma', phone: '+91 98765 43210'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: KajuTheme.dark(),
          home: const Scaffold(body: PersonSheet()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('import-phone-contact-button')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Amit Verma'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);

    await tester.tap(find.byKey(const Key('person-save-button')));
    await tester.pump(const Duration(milliseconds: 300));

    final parties = await database.select(database.parties).get();
    expect(parties.single.name, 'Amit Verma');
    expect(parties.single.phone, '+91 98765 43210');
  });

  testWidgets('Person sheet scrolls instead of overflowing on compact height', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PartiesRepository(
      database: database,
      api: _OfflinePartiesApi(),
      pendingSync: PendingSyncService(database),
      currentUserId: 'local-owner',
      idGenerator: _fixedIds(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partiesRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: KajuTheme.dark(),
          home: const Scaffold(body: PersonSheet()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('person-save-button')), findsOneWidget);
  });
}

Widget peopleWidget(
  Widget child, {
  required List<PartyListItem> items,
}) {
  return ProviderScope(
    overrides: [
      partyListProvider.overrideWith((ref, query) => Stream.value(items)),
    ],
    child: MaterialApp(
      theme: KajuTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
}

Party testParty({String name = 'Amit Verma'}) {
  final now = DateTime.now().toUtc();
  return Party(
    id: 'party-1',
    userId: 'local-owner',
    name: name,
    phone: '98765',
    type: 'CUSTOMER',
    trustTag: 'NEW',
    trustTagManualOverride: false,
    notes: null,
    syncId: 'sync-1',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

String Function() _fixedIds() {
  final ids = ['party-widget', 'sync-widget'];
  return () => ids.removeAt(0);
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

class _FakePhoneContactPicker implements PhoneContactPicker {
  const _FakePhoneContactPicker(this.contact);

  final PhoneContact? contact;

  @override
  Future<PhoneContact?> pickContact() async => contact;
}
