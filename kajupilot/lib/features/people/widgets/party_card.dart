import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/party_models.dart';

class PartyCard extends StatelessWidget {
  const PartyCard({
    super.key,
    required this.item,
  });

  final PartyListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final party = item.party;
    final pendingTone = item.stats.overdueAmountPaise > 0
        ? AmountDisplayTone.overdue
        : AmountDisplayTone.pending;

    return KajuCard(
      onTap: () => context.push('/people/${party.id}'),
      child: Row(
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
                Wrap(
                  spacing: KajuSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.type.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: colors.textMuted),
                    ),
                    AmountDisplay(
                      amountPaise: item.stats.pendingAmountPaise,
                      tone: pendingTone,
                      size: AmountDisplaySize.small,
                    ),
                    Text(
                      'pending',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: KajuSpacing.sm),
                Wrap(
                  spacing: KajuSpacing.sm,
                  runSpacing: KajuSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(
                      label: item.trustTag.label,
                      tone: _trustTone(item.trustTag),
                    ),
                    Text(
                      '${item.stats.dealCount} deals',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  StatusBadgeTone _trustTone(TrustTagValue trustTag) {
    return switch (trustTag) {
      TrustTagValue.reliable => StatusBadgeTone.success,
      TrustTagValue.slowPayer => StatusBadgeTone.warning,
      TrustTagValue.risky => StatusBadgeTone.danger,
      TrustTagValue.fresh => StatusBadgeTone.info,
    };
  }
}
