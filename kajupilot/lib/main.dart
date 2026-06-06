import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/kaju_app.dart';
import 'core/sync/sync_lifecycle_runner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SyncLifecycleRunner(child: KajuApp()),
    ),
  );
}
