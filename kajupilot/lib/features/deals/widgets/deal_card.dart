import 'package:flutter/material.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/deal_models.dart';

class DealCard extends StatelessWidget {
  const DealCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final DealListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final deal = item.deal;
    final pendingPaise = item.pendingPaise;

    return KajuCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonAvatar(name: item.party.name),
              const SizedBox(width: KajuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.party.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: KajuSpacing.xs),
                    Text(
                      '${item.type.label} - ${item.gradeSummary} - ${item.quantitySummary}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: item.status.label,
                tone: _statusTone(item.status),
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'Total',
                  amountPaise: deal.totalPaise,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'Paid',
                  amountPaise: deal.paidPaise,
                  tone: AmountDisplayTone.received,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'Pending',
                  amountPaise: pendingPaise,
                  tone: pendingPaise > 0
                      ? AmountDisplayTone.pending
                      : AmountDisplayTone.neutral,
                ),
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.sm),
          Wrap(
            spacing: KajuSpacing.md,
            runSpacing: KajuSpacing.xs,
            children: [
              if (item.items.isNotEmpty && item.items.first.rateText != null)
                Text(
                  'Rate ${item.items.first.rateText}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (deal.deliveryDate != null)
                Text(
                  'Delivery ${formatKajuDate(deal.deliveryDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (deal.paymentDue != null)
                Text(
                  'Due ${formatKajuDate(deal.paymentDue!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            isBeforeToday(deal.paymentDue!) && pendingPaise > 0
                                ? colors.danger
                                : colors.textSecondary,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  StatusBadgeTone _statusTone(DealStatusValue status) {
    return switch (status) {
      DealStatusValue.quoted => StatusBadgeTone.info,
      DealStatusValue.confirmed => StatusBadgeTone.accent,
      DealStatusValue.delivered => StatusBadgeTone.warning,
      DealStatusValue.paid => StatusBadgeTone.success,
    };
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amountPaise,
    this.tone = AmountDisplayTone.neutral,
  });

  final String label;
  final int amountPaise;
  final AmountDisplayTone tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: KajuSpacing.xs),
        AmountDisplay(
          amountPaise: amountPaise,
          tone: tone,
          size: AmountDisplaySize.small,
        ),
      ],
    );
  }
}
