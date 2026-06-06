import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/today_models.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.item,
    this.onCall,
    this.onDone,
    this.onPostpone,
    this.onTap,
  });

  final TaskListItem item;
  final VoidCallback? onCall;
  final VoidCallback? onDone;
  final VoidCallback? onPostpone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final overdue = item.isOverdue(DateTime.now().toUtc());
    final party = item.party;

    return KajuCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: overdue ? colors.danger : colors.accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(KajuRadius.lg),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KajuSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PersonAvatar(name: party?.name ?? item.task.title),
                        const SizedBox(width: KajuSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                party?.name ?? item.task.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: KajuSpacing.xs),
                              Text(
                                item.task.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: overdue ? 'Overdue' : item.type.label,
                          tone: overdue
                              ? StatusBadgeTone.danger
                              : _typeTone(item.type),
                        ),
                      ],
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    Wrap(
                      spacing: KajuSpacing.md,
                      runSpacing: KajuSpacing.xs,
                      children: [
                        Text(
                          _timeLabel(item.task.scheduledAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: overdue
                                        ? colors.danger
                                        : colors.textSecondary,
                                  ),
                        ),
                        if (item.task.notes != null)
                          Text(
                            item.task.notes!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    Row(
                      children: [
                        if (item.type == TaskTypeValue.call)
                          FilledButton.icon(
                            onPressed: party?.phone == null ? null : onCall,
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text('Call'),
                          ),
                        if (item.type == TaskTypeValue.call)
                          const SizedBox(width: KajuSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: onDone,
                          icon: const Icon(Icons.check_outlined, size: 18),
                          label: const Text('Done'),
                        ),
                        const SizedBox(width: KajuSpacing.sm),
                        IconButton.outlined(
                          onPressed: onPostpone,
                          icon: const Icon(Icons.schedule_outlined),
                          tooltip: 'Postpone',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusBadgeTone _typeTone(TaskTypeValue type) {
    return switch (type) {
      TaskTypeValue.call => StatusBadgeTone.info,
      TaskTypeValue.delivery => StatusBadgeTone.accent,
      TaskTypeValue.paymentCollection => StatusBadgeTone.warning,
      TaskTypeValue.reminder => StatusBadgeTone.info,
      TaskTypeValue.other => StatusBadgeTone.neutral,
    };
  }

  String _timeLabel(DateTime value) {
    final local = value.toLocal();
    final time = DateFormat('h:mm a').format(local);
    if (isToday(local)) {
      return 'Today - $time';
    }
    if (isBeforeToday(local)) {
      return '${formatKajuDate(local)} - $time';
    }
    return '${formatKajuDate(local)} - $time';
  }
}
