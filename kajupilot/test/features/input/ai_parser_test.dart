import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/features/input/ai_parse_models.dart';
import 'package:kajupilot/features/input/ai_parser_api.dart';
import 'package:kajupilot/features/input/ai_parser_repository.dart';
import 'package:kajupilot/features/input/parse_sheet.dart';
import 'package:kajupilot/features/input/universal_input_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('new contact warning does not block confirm after local validation', () {
    final item = AiPreviewItem(
      kind: AiPreviewKind.payment,
      tempId: 'payment-1',
      partyName: 'Ramesh',
      partyMatch: const AiPartyMatch(status: 'new', name: 'Ramesh'),
      type: 'RECEIVED',
      amountPaise: 5000000,
      paymentDate: DateTime(2026, 6, 7),
      needsReview: true,
      warnings: const ['New contact will be created'],
    );

    expect(item.validated().needsReview, isFalse);
  });

  test('repository confirm calls API then refresh callback', () async {
    final api = FakeAiParserApi();
    var refreshed = false;
    final repository = AiParserRepository(
      api: api,
      onConfirmed: () async => refreshed = true,
    );

    final count = await repository.confirm(
      logId: 'log-1',
      items: [
        AiPreviewItem(
          kind: AiPreviewKind.expense,
          tempId: 'expense-1',
          scope: 'PERSONAL',
          category: 'OTHER',
          amountPaise: 120000,
          expenseDate: DateTime(2026, 6, 7),
        ),
      ],
    );

    expect(count, 1);
    expect(api.confirmedLogId, 'log-1');
    expect(refreshed, isTrue);
  });

  testWidgets('UniversalInputBar opens ParseSheet', (tester) async {
    await tester.pumpWidget(
      themed(
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: UniversalInputBar(),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('universal-input-bar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-parse-input')), findsOneWidget);
  });

  testWidgets('ParseSheet renders preview items after parse', (tester) async {
    final api = FakeAiParserApi(
      result: AiParseResult(
        logId: 'log-1',
        provider: 'openai',
        model: 'gpt-4o-mini',
        itemCount: 1,
        needsReviewCount: 0,
        items: [
          AiPreviewItem(
            kind: AiPreviewKind.task,
            tempId: 'task-1',
            partyName: 'Amit Verma',
            partyMatch: const AiPartyMatch(status: 'matched'),
            type: 'CALL',
            title: 'Call Amit',
            scheduledAt: DateTime(2026, 6, 8, 10),
          ),
        ],
      ),
    );

    await tester.pumpWidget(parseSheetHarness(api));
    await tester.enterText(
      find.byKey(const Key('ai-parse-input')),
      'Call Amit tomorrow',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('ai-parse-button')));
    await tester.tap(find.byKey(const Key('ai-parse-button')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Amit Verma'), findsOneWidget);
    expect(find.text('Call Amit'), findsOneWidget);
    expect(find.byKey(const Key('ai-confirm-button')), findsOneWidget);
  });

  testWidgets('ParseSheet disables confirm for unresolved preview items',
      (tester) async {
    final api = FakeAiParserApi(
      result: AiParseResult(
        logId: 'log-1',
        provider: 'openai',
        model: 'gpt-4o-mini',
        itemCount: 1,
        needsReviewCount: 1,
        items: [
          const AiPreviewItem(
            kind: AiPreviewKind.deal,
            tempId: 'deal-1',
            partyName: 'Amit',
            type: 'SALE',
            needsReview: true,
            warnings: ['Deal total needs review'],
          ),
        ],
      ),
    );

    await tester.pumpWidget(parseSheetHarness(api));
    await tester.enterText(
      find.byKey(const Key('ai-parse-input')),
      'Amit sale',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('ai-parse-button')));
    await tester.tap(find.byKey(const Key('ai-parse-button')));
    await tester.pump();
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('ai-confirm-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.textContaining('Resolve'), findsOneWidget);
  });
}

Widget themed(Widget child) {
  return MaterialApp(
    theme: KajuTheme.dark(),
    home: child,
  );
}

Widget parseSheetHarness(FakeAiParserApi api) {
  return ProviderScope(
    overrides: [
      aiParserRepositoryProvider.overrideWithValue(
        AiParserRepository(
          api: api,
          onConfirmed: () async {},
        ),
      ),
    ],
    child: themed(const Scaffold(body: ParseSheet())),
  );
}

class FakeAiParserApi implements AiParserApi {
  FakeAiParserApi({this.result});

  final AiParseResult? result;
  String? confirmedLogId;

  @override
  Future<AiParseResult> parse({
    required String text,
    required DateTime localDate,
    required String timezone,
  }) async {
    return result ??
        const AiParseResult(
          logId: 'log-1',
          provider: 'openai',
          model: 'gpt-4o-mini',
          items: [],
          itemCount: 0,
          needsReviewCount: 0,
        );
  }

  @override
  Future<Map<String, dynamic>> confirm({
    required String logId,
    required List<AiPreviewItem> items,
  }) async {
    confirmedLogId = logId;
    return {'created': <String, dynamic>{}};
  }
}
