import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kajupilot/app/kaju_app.dart';
import 'package:kajupilot/core/auth/token_storage.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/db/app_database_provider.dart';
import 'package:kajupilot/core/onboarding/onboarding_storage.dart';
import 'package:kajupilot/features/deals/data/deal_models.dart';
import 'package:kajupilot/features/deals/data/deals_repository.dart';
import 'package:kajupilot/features/money/data/money_models.dart';
import 'package:kajupilot/features/money/data/payments_repository.dart';
import 'package:kajupilot/features/today/data/tasks_repository.dart';
import 'package:kajupilot/features/today/data/today_models.dart';

void main() {
  testWidgets('first launch shows onboarding before setup', (tester) async {
    await pumpKajuApp(tester, onboardingComplete: false);

    expect(find.byKey(const Key('onboarding-screen')), findsOneWidget);
    expect(find.text('Your calls, planned'), findsOneWidget);
  });

  testWidgets('onboarding completion opens setup when no token exists',
      (tester) async {
    await pumpKajuApp(tester, onboardingComplete: false);

    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('setup-screen')), findsOneWidget);
    expect(find.text('Private setup'), findsOneWidget);
  });

  testWidgets('shows setup screen when no token is stored', (tester) async {
    await pumpKajuApp(tester);

    expect(find.byKey(const Key('setup-screen')), findsOneWidget);
    expect(find.text('Private setup'), findsOneWidget);
  });

  testWidgets('shows app shell when token is stored', (tester) async {
    await pumpKajuApp(tester, token: 'stored-token');

    expect(find.byKey(const Key('feature-today-screen')), findsOneWidget);
    expect(find.byKey(const Key('universal-input-bar')), findsOneWidget);
  });

  testWidgets('bottom navigation switches feature tabs', (tester) async {
    await pumpKajuApp(tester, token: 'stored-token');
    expect(find.byKey(const Key('feature-today-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-money')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('feature-money-screen')), findsOneWidget);
  });
}

Future<void> pumpKajuApp(
  WidgetTester tester, {
  String? token,
  bool onboardingComplete = true,
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(
          MemoryTokenStorage(initialToken: token),
        ),
        onboardingStorageProvider.overrideWithValue(
          MemoryOnboardingStorage(initialComplete: onboardingComplete),
        ),
        appDatabaseProvider.overrideWithValue(database),
        todayTasksProvider.overrideWith(
          (ref, date) => Stream.value(const []),
        ),
        taskListProvider.overrideWith(
          (ref, query) => Stream.value(const []),
        ),
        todayInsightsProvider.overrideWith(
          (ref, date) async => TodayInsights.empty(),
        ),
        dealListProvider.overrideWith(
          (ref, query) => Stream.value(const <DealListItem>[]),
        ),
        moneyLedgerProvider.overrideWith(
          (ref) => Stream.value(
            const MoneyLedgerSnapshot(
              totalReceivablePaise: 0,
              totalPayablePaise: 0,
              parties: [],
            ),
          ),
        ),
      ],
      child: const KajuApp(persistTheme: false),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(seconds: 1));
}

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage({String? initialToken}) : _token = initialToken;

  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}

class MemoryOnboardingStorage implements OnboardingStorage {
  MemoryOnboardingStorage({required bool initialComplete})
      : _complete = initialComplete;

  bool _complete;

  @override
  Future<bool> isComplete() async => _complete;

  @override
  Future<void> markComplete() async {
    _complete = true;
  }
}
