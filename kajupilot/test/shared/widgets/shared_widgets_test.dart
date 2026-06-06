import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/theme/app_theme.dart';
import 'package:kajupilot/shared/widgets/amount_display.dart';
import 'package:kajupilot/shared/widgets/kaju_card.dart';
import 'package:kajupilot/shared/widgets/person_avatar.dart';
import 'package:kajupilot/shared/widgets/status_badge.dart';

void main() {
  testWidgets('AmountDisplay renders Indian rupee format', (tester) async {
    await tester.pumpWidget(
      themed(
        const AmountDisplay(
          amountPaise: 10000000,
          tone: AmountDisplayTone.received,
        ),
      ),
    );

    expect(find.text('₹1,00,000'), findsOneWidget);
  });

  testWidgets('StatusBadge uppercases its label', (tester) async {
    await tester.pumpWidget(
      themed(
        const StatusBadge(
          label: 'paid',
          tone: StatusBadgeTone.success,
        ),
      ),
    );

    expect(find.text('PAID'), findsOneWidget);
  });

  testWidgets('PersonAvatar renders initials', (tester) async {
    await tester.pumpWidget(themed(const PersonAvatar(name: 'Amit Verma')));

    expect(find.text('AV'), findsOneWidget);
  });

  testWidgets('KajuCard handles taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      themed(
        KajuCard(
          onTap: () => tapped = true,
          child: const Text('Card body'),
        ),
      ),
    );

    await tester.tap(find.text('Card body'));

    expect(tapped, isTrue);
  });
}

Widget themed(Widget child) {
  return MaterialApp(
    theme: KajuTheme.dark(),
    home: Scaffold(body: child),
  );
}
