import 'package:flutter/material.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/today_models.dart';

class CallLogCard extends StatelessWidget {
  const CallLogCard({
    super.key,
    required this.item,
  });

  final CallLogListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final callLog = item.callLog;

    return KajuCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonAvatar(name: item.party?.name ?? item.taskTitle ?? 'Call'),
          const SizedBox(width: KajuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.party?.name ?? item.taskTitle ?? 'Call log',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(
                      label: item.outcome.label,
                      tone: _tone(item.outcome),
                    ),
                  ],
                ),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  formatKajuDate(callLog.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                if (callLog.promisedAmountPaise != null) ...[
                  const SizedBox(height: KajuSpacing.sm),
                  AmountDisplay(
                    amountPaise: callLog.promisedAmountPaise!,
                    tone: AmountDisplayTone.pending,
                    size: AmountDisplaySize.small,
                  ),
                ],
                if (callLog.promisedDate != null) ...[
                  const SizedBox(height: KajuSpacing.xs),
                  Text(
                    'Promised by ${formatKajuDate(callLog.promisedDate!.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (callLog.notes != null) ...[
                  const SizedBox(height: KajuSpacing.sm),
                  Text(
                    callLog.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusBadgeTone _tone(CallOutcomeValue outcome) {
    return switch (outcome) {
      CallOutcomeValue.paymentPromised => StatusBadgeTone.warning,
      CallOutcomeValue.newOrder => StatusBadgeTone.accent,
      CallOutcomeValue.noAnswer => StatusBadgeTone.danger,
      CallOutcomeValue.notInterested => StatusBadgeTone.neutral,
      CallOutcomeValue.deliveryUpdate => StatusBadgeTone.info,
      CallOutcomeValue.other => StatusBadgeTone.neutral,
    };
  }
}
