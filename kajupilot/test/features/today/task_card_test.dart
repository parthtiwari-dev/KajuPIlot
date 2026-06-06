import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/db/app_database.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/features/today/data/today_models.dart';
import 'package:kajupilot/features/today/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard call actions fit on a phone width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now().toUtc();
    final item = TaskListItem(
      task: Task(
        id: 'task-1',
        userId: 'owner',
        partyId: 'party-1',
        type: TaskTypeValue.call.apiValue,
        title: 'Call Amit for payment',
        notes: 'Ask about pending amount',
        scheduledAt: now.add(const Duration(hours: 1)),
        status: TaskStatusValue.pending.apiValue,
        priority: 2,
        syncId: 'sync-1',
        createdAt: now,
        updatedAt: now,
      ),
      party: const TaskPartySummary(
        id: 'party-1',
        name: 'Amit Verma',
        phone: '9876543210',
        type: 'CUSTOMER',
        trustTag: 'NEW',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: KajuTheme.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: TaskCard(item: item),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
