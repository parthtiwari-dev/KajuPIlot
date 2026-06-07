import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/features/insights/data/insights_api.dart';
import 'package:kajupilot/features/insights/data/insights_models.dart';
import 'package:kajupilot/features/insights/insights_screen.dart';
import 'package:kajupilot/features/money/data/money_models.dart';
import 'package:kajupilot/features/people/data/party_models.dart';

void main() {
  testWidgets('Insights screen shows empty state without business data', (
    tester,
  ) async {
    await tester.pumpWidget(insightsWidget(_emptyDashboard()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('feature-insights-screen')), findsOneWidget);
    expect(find.text('Not enough data yet'), findsOneWidget);
  });

  testWidgets('Insights screen renders weekly data and expense donut', (
    tester,
  ) async {
    await tester.pumpWidget(insightsWidget(_dataDashboard()));
    await tester.pumpAndSettle();

    expect(find.text('AI summary'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Amit Verma'), findsWidgets);
    expect(find.text('Business expense mix'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AI provider'),
      500,
      maxScrolls: 8,
    );

    expect(find.text('AI provider'), findsOneWidget);
    expect(find.text('Backend'), findsOneWidget);
    expect(find.text('Sync queue'), findsOneWidget);
  });

  testWidgets('Insights screen cleans fenced JSON weekly notes', (
    tester,
  ) async {
    await tester.pumpWidget(insightsWidget(_jsonNotesDashboard()));
    await tester.pumpAndSettle();

    expect(find.textContaining('```json'), findsNothing);
    expect(find.textContaining('"insights"'), findsNothing);
    expect(find.textContaining('Secure upfront payments'), findsOneWidget);
  });
}

Widget insightsWidget(InsightsDashboard dashboard) {
  return ProviderScope(
    overrides: [
      insightsDashboardProvider.overrideWith((ref) async => dashboard),
      moreToolsStatusProvider.overrideWith(
        (ref) async => MoreToolsStatus(
          backend: BackendHealthStatus(
            ok: true,
            service: 'kajupilot-api',
            timestamp: DateTime(2026, 6, 7),
          ),
          aiProvider: const AiProviderStatus(
            provider: 'openai',
            model: 'gpt-4o-mini',
          ),
          pendingSyncCount: 0,
        ),
      ),
    ],
    child: MaterialApp(
      theme: KajuTheme.dark(),
      home: const InsightsScreen(),
    ),
  );
}

InsightsDashboard _jsonNotesDashboard() {
  final base = _dataDashboard();
  return InsightsDashboard(
    aiSummary: base.aiSummary,
    aiWeekly: AiWeeklyInsights.fromJson({
      'insights': [
        '```json',
        '{',
        '"insights": [',
        '"Secure upfront payments before new dispatches.",',
        ']',
        '}',
        '```',
      ],
      'provider': 'openai',
      'model': 'gpt-4o-mini',
      'cached': true,
    }),
    weekly: base.weekly,
    people: base.people,
  );
}

InsightsDashboard _emptyDashboard() {
  return InsightsDashboard(
    aiSummary: const AiTodaySummary(
      text: 'No urgent business risks today.',
      provider: 'openai',
      model: 'gpt-4o-mini',
      cached: false,
    ),
    aiWeekly: const AiWeeklyInsights(
      insights: [],
      provider: 'openai',
      model: 'gpt-4o-mini',
      cached: false,
    ),
    weekly: WeeklyInsights(
      from: '2026-06-01',
      to: '2026-06-07',
      revenuePaise: 0,
      businessExpensesPaise: 0,
      personalExpensesPaise: 0,
      grossProfitEstimatePaise: 0,
      dealsClosedCount: 0,
      newPartiesCount: 0,
      topBuyers: const [],
      slowestPayers: const [],
      expenseByCategoryPaise: {
        for (final category in ExpenseCategoryValue.values) category: 0,
      },
    ),
    people: const PeopleInsights(
      topBuyers: [],
      slowPayers: [],
      inactiveCustomers: [],
      trustTagUpdates: [],
    ),
  );
}

InsightsDashboard _dataDashboard() {
  final buyer = PartyInsightItem(
    partyId: 'party-1',
    name: 'Amit Verma',
    trustTag: TrustTagValue.reliable,
    amountPaise: 1250000,
    dealCount: 2,
  );

  return InsightsDashboard(
    aiSummary: const AiTodaySummary(
      text: 'Amit is the strongest buyer this week. Watch transport spend.',
      provider: 'openai',
      model: 'gpt-4o-mini',
      cached: false,
    ),
    aiWeekly: const AiWeeklyInsights(
      insights: ['Follow up with slow payers before new dispatches.'],
      provider: 'openai',
      model: 'gpt-4o-mini',
      cached: false,
    ),
    weekly: WeeklyInsights(
      from: '2026-06-01',
      to: '2026-06-07',
      revenuePaise: 1500000,
      businessExpensesPaise: 180000,
      personalExpensesPaise: 25000,
      grossProfitEstimatePaise: 1320000,
      dealsClosedCount: 3,
      newPartiesCount: 1,
      topBuyers: [buyer],
      slowestPayers: const [],
      expenseByCategoryPaise: {
        for (final category in ExpenseCategoryValue.values) category: 0,
        ExpenseCategoryValue.transport: 120000,
        ExpenseCategoryValue.labour: 60000,
      },
    ),
    people: PeopleInsights(
      topBuyers: [buyer],
      slowPayers: const [],
      inactiveCustomers: const [],
      trustTagUpdates: const [],
    ),
  );
}
