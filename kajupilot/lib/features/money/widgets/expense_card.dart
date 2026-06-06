import 'package:flutter/material.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/money_models.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final category = ExpenseCategoryValue.fromApi(expense.category);

    return KajuCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const StatusBadge(
                  label: 'Expense', tone: StatusBadgeTone.warning),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: AmountDisplay(
                  amountPaise: expense.amountPaise,
                  tone: AmountDisplayTone.pending,
                ),
              ),
              Text(
                formatKajuDate(expense.expenseDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
          if (expense.notes != null) ...[
            const SizedBox(height: KajuSpacing.sm),
            Text(
              expense.notes!,
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
