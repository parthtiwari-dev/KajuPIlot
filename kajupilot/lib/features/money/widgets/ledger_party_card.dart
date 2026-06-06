import 'package:flutter/material.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_action_button.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/money_models.dart';

class LedgerPartyCard extends StatelessWidget {
  const LedgerPartyCard({
    super.key,
    required this.party,
    required this.side,
  });

  final MoneyLedgerParty party;
  final PaymentTypeValue side;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final amountPaise = side == PaymentTypeValue.received
        ? party.receivablePaise
        : party.payablePaise;
    final isOverdue = party.overdueAmountPaise > 0;

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonAvatar(name: party.name),
              const SizedBox(width: KajuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: KajuSpacing.xs),
                    Text(
                      '${party.dealCount} deal${party.dealCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                const StatusBadge(
                    label: 'Overdue', tone: StatusBadgeTone.danger),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: AmountDisplay(
                  amountPaise: amountPaise,
                  tone: isOverdue
                      ? AmountDisplayTone.overdue
                      : AmountDisplayTone.pending,
                ),
              ),
              SizedBox(
                width: 116,
                child: KajuActionButton(phoneNumber: party.phone),
              ),
            ],
          ),
          if (party.oldestOverdueDate != null) ...[
            const SizedBox(height: KajuSpacing.sm),
            Text(
              'Oldest due ${formatKajuDate(party.oldestOverdueDate!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.danger,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
