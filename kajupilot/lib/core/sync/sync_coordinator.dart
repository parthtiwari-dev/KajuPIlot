import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deals/data/deals_repository.dart';
import '../../features/money/data/expenses_repository.dart';
import '../../features/money/data/payments_repository.dart';
import '../../features/people/data/parties_repository.dart';
import '../../features/today/data/call_logs_repository.dart';
import '../../features/today/data/tasks_repository.dart';

typedef SyncTask = Future<void> Function();

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  return SyncCoordinator(
    retryTasks: [
      () => ref.read(partiesRepositoryProvider).flushPendingPartySync(),
      () => ref.read(dealsRepositoryProvider).flushPendingDealSync(),
      () => ref.read(paymentsRepositoryProvider).flushPendingPaymentSync(),
      () => ref.read(expensesRepositoryProvider).flushPendingExpenseSync(),
      () => ref.read(tasksRepositoryProvider).flushPendingTaskSync(),
      () => ref.read(callLogsRepositoryProvider).flushPendingCallLogSync(),
    ],
  );
});

class SyncCoordinator {
  SyncCoordinator({required List<SyncTask> retryTasks})
      : _retryTasks = retryTasks;

  final List<SyncTask> _retryTasks;
  Future<void>? _activeRetry;

  Future<void> retryAll() {
    final running = _activeRetry;
    if (running != null) {
      return running;
    }

    final retry = _retryAll().whenComplete(() {
      _activeRetry = null;
    });
    _activeRetry = retry;
    return retry;
  }

  Future<void> _retryAll() async {
    for (final task in _retryTasks) {
      try {
        await task();
      } catch (_) {
        // Individual repositories already record failed attempts per row.
      }
    }
  }
}
