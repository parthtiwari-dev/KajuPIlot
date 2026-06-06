import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajupilot/app/kaju_app.dart';
import 'package:kajupilot/core/auth/token_storage.dart';

void main() {
  testWidgets('shows setup screen when no token is stored', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
        ],
        child: const KajuApp(persistTheme: false),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('setup-screen')), findsOneWidget);
    expect(find.text('Private setup'), findsOneWidget);
  });

  testWidgets('shows app shell when token is stored', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(
            MemoryTokenStorage(initialToken: 'stored-token'),
          ),
        ],
        child: const KajuApp(persistTheme: false),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('feature-today-screen')), findsOneWidget);
    expect(find.byKey(const Key('universal-input-bar')), findsOneWidget);
  });

  testWidgets('bottom navigation switches feature tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(
            MemoryTokenStorage(initialToken: 'stored-token'),
          ),
        ],
        child: const KajuApp(persistTheme: false),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feature-today-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-money')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('feature-money-screen')), findsOneWidget);
  });
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
