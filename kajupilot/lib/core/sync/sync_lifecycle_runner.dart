import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../../features/today/data/tasks_repository.dart';
import 'sync_coordinator.dart';

class SyncLifecycleRunner extends ConsumerStatefulWidget {
  const SyncLifecycleRunner({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleRunner> createState() =>
      _SyncLifecycleRunnerState();
}

class _SyncLifecycleRunnerState extends ConsumerState<SyncLifecycleRunner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(authControllerProvider).valueOrNull != null) {
      unawaited(_retryAndReschedule());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (
      previous,
      next,
    ) {
      final wasSignedOut = previous?.valueOrNull == null;
      final isSignedIn = next.valueOrNull != null;
      if (wasSignedOut && isSignedIn) {
        unawaited(_retryAndReschedule());
      }
    });

    return widget.child;
  }

  Future<void> _retryAndReschedule() async {
    await ref.read(syncCoordinatorProvider).retryAll();
    await ref.read(tasksRepositoryProvider).rescheduleNotificationsForToday();
  }
}
