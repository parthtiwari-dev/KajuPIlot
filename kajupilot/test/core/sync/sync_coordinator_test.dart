import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/sync/sync_coordinator.dart';

void main() {
  test('retryAll quietly runs every retry task', () async {
    final calls = <String>[];
    final coordinator = SyncCoordinator(
      retryTasks: [
        () async => calls.add('party'),
        () async => throw StateError('offline'),
        () async => calls.add('expense'),
      ],
    );

    await coordinator.retryAll();

    expect(calls, ['party', 'expense']);
  });

  test('retryAll dedupes concurrent runs', () async {
    final completer = Completer<void>();
    var calls = 0;
    final coordinator = SyncCoordinator(
      retryTasks: [
        () {
          calls += 1;
          return completer.future;
        },
      ],
    );

    final first = coordinator.retryAll();
    final second = coordinator.retryAll();

    expect(calls, 1);
    completer.complete();
    await Future.wait([first, second]);

    await coordinator.retryAll();

    expect(calls, 2);
  });
}
