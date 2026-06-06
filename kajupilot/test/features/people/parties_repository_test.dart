import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/network/api_client.dart';
import 'package:kajupilot/core/sync/pending_sync_service.dart';
import 'package:kajupilot/features/people/data/parties_api.dart';
import 'package:kajupilot/features/people/data/parties_repository.dart';
import 'package:kajupilot/features/people/data/party_models.dart';

void main() {
  group('PartiesRepository', () {
    late AppDatabase database;
    late FakePartiesApi api;
    late PartiesRepository repository;
    var ids = <String>[];
    var pendingIndex = 0;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      api = FakePartiesApi();
      ids = ['party-1', 'sync-1'];
      repository = PartiesRepository(
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
        const CreatePartyInput(
          name: 'Amit Verma',
          phone: '98765',
          type: PartyTypeValue.customer,
        ),
      );

      final party = await database.select(database.parties).getSingle();
      final pending = await database.select(database.pendingSync).get();

      expect(party.name, 'Amit Verma');
      expect(party.syncId, 'sync-1');
      expect(pending, hasLength(1));
      expect(pending.single.action, PendingSyncAction.create.name);
    });

    test('removes pending sync when API create succeeds', () async {
      await repository.create(
        const CreatePartyInput(
          name: 'Amit Verma',
          type: PartyTypeValue.customer,
        ),
      );

      final pending = await database.select(database.pendingSync).get();
      final party = await database.select(database.parties).getSingle();

      expect(pending, isEmpty);
      expect(party.userId, 'server-user');
    });

    test('updates and soft deletes locally', () async {
      api.failUpdate = true;
      api.failDelete = true;
      await seedParty(database);

      await repository.update(
        'party-1',
        const UpdatePartyInput(name: 'Ramesh Sahu'),
      );
      await repository.softDelete('party-1');

      final party = await database.select(database.parties).getSingle();
      final pending = await database.select(database.pendingSync).get();

      expect(party.name, 'Ramesh Sahu');
      expect(party.deletedAt, isNotNull);
      expect(pending.map((entry) => entry.action), contains('update'));
      expect(pending.map((entry) => entry.action), contains('delete'));
    });

    test('watches filtered parties', () async {
      await seedParty(database);
      await database.into(database.parties).insert(
            PartiesCompanion.insert(
              id: 'party-2',
              userId: 'local-owner',
              name: 'Supplier One',
              type: const Value('SUPPLIER'),
              syncId: 'sync-2',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );

      final items = await repository
          .watchParties(
            const PartyListQuery(filter: PartyListFilter.suppliers),
          )
          .first;

      expect(items, hasLength(1));
      expect(items.single.party.name, 'Supplier One');
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
          syncId: 'sync-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class FakePartiesApi extends PartiesApi {
  FakePartiesApi() : super(KajuApiClient(Dio()));

  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  @override
  Future<PartyListItem> create({
    required String id,
    required String syncId,
    required CreatePartyInput input,
  }) async {
    if (failCreate) {
      throw StateError('offline');
    }

    return PartyListItem(
      party: Party(
        id: id,
        userId: 'server-user',
        name: input.name,
        phone: input.phone,
        type: input.type.apiValue,
        trustTag: input.trustTag.apiValue,
        notes: input.notes,
        syncId: syncId,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: null,
      ),
    );
  }

  @override
  Future<PartyListItem> update(String id, UpdatePartyInput input) async {
    if (failUpdate) {
      throw StateError('offline');
    }

    return PartyListItem(
      party: Party(
        id: id,
        userId: 'server-user',
        name: input.name ?? 'Amit Verma',
        phone: input.phone,
        type: input.type?.apiValue ?? 'CUSTOMER',
        trustTag: input.trustTag?.apiValue ?? 'NEW',
        notes: input.notes,
        syncId: 'sync-1',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: null,
      ),
    );
  }

  @override
  Future<Party> delete(String id) async {
    if (failDelete) {
      throw StateError('offline');
    }

    final now = DateTime.now().toUtc();
    return Party(
      id: id,
      userId: 'server-user',
      name: 'Amit Verma',
      phone: '98765',
      type: 'CUSTOMER',
      trustTag: 'NEW',
      notes: null,
      syncId: 'sync-1',
      createdAt: now,
      updatedAt: now,
      deletedAt: now,
    );
  }
}
