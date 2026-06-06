import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/app_database_provider.dart';

final pendingSyncServiceProvider = Provider<PendingSyncService>((ref) {
  return PendingSyncService(ref.watch(appDatabaseProvider));
});

enum PendingSyncAction {
  create,
  update,
  delete,
}

enum PendingSyncEntityType {
  party,
  deal,
  payment,
  expense,
  task,
  callLog,
  aiParseLog,
}

class PendingSyncService {
  PendingSyncService(
    this._database, {
    String Function()? idGenerator,
  }) : _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final String Function() _idGenerator;

  Future<String> enqueue({
    required PendingSyncEntityType entityType,
    required String entityId,
    required PendingSyncAction action,
    required Map<String, Object?> payload,
    DateTime? now,
  }) async {
    final id = _idGenerator();
    final createdAt = now ?? DateTime.now().toUtc();

    await _database.into(_database.pendingSync).insert(
          PendingSyncCompanion.insert(
            id: id,
            entityType: entityType.name,
            entityId: entityId,
            action: action.name,
            payloadJson: jsonEncode(payload),
            createdAt: createdAt,
          ),
        );

    return id;
  }

  Future<List<PendingSyncData>> pending({int limit = 50}) {
    return (_database.select(_database.pendingSync)
          ..orderBy([
            (row) => OrderingTerm.asc(row.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<Map<String, dynamic>> decodedPayload(PendingSyncData entry) async {
    final payload = jsonDecode(entry.payloadJson);
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    return <String, dynamic>{};
  }

  Future<void> markAttempted(String id, {DateTime? now}) async {
    final entry = await (_database.select(_database.pendingSync)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();

    if (entry == null) {
      return;
    }

    await (_database.update(_database.pendingSync)
          ..where((row) => row.id.equals(id)))
        .write(
      PendingSyncCompanion(
        attemptCount: Value(entry.attemptCount + 1),
        lastAttemptAt: Value(now ?? DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> remove(String id) {
    return (_database.delete(_database.pendingSync)
          ..where((row) => row.id.equals(id)))
        .go();
  }
}
