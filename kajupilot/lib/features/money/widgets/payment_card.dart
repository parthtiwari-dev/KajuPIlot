import 'package:flutter/material.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/money_models.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final PaymentListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final isReceived = item.type == PaymentTypeValue.received;

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
                      item.deal == null
                          ? 'Party-level payment'
                          : 'Linked to ${item.deal!.cashewGrade}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: item.type.label,
                tone:
                    isReceived ? StatusBadgeTone.success : StatusBadgeTone.info,
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: AmountDisplay(
                  amountPaise: item.payment.amountPaise,
                  tone: isReceived
                      ? AmountDisplayTone.received
                      : AmountDisplayTone.neutral,
                ),
              ),
              Text(
                formatKajuDate(item.payment.paymentDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
          if (item.payment.method != null || item.payment.notes != null) ...[
            const SizedBox(height: KajuSpacing.sm),
            Text(
              [
                if (item.payment.method != null) item.payment.method,
                if (item.payment.notes != null) item.payment.notes,
              ].join(' - '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
