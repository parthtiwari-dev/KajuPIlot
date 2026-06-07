import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_coordinator.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../../shared/widgets/status_badge.dart';
import 'data/parties_repository.dart';
import 'data/party_models.dart';

class PartyHistoryScreen extends ConsumerWidget {
  const PartyHistoryScreen({super.key, required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.kajuColors;
    final history = ref.watch(partyHistoryProvider(partyId));

    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: AppBar(title: const Text('History')),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await ref.read(syncCoordinatorProvider).retryAll();
          } catch (_) {
            // History refresh remains useful even when sync is offline.
          }
          ref.invalidate(partyHistoryProvider(partyId));
          await ref.read(partyHistoryProvider(partyId).future);
        },
        child: history.when(
          loading: () => const _HistoryLoading(),
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              KajuEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load history',
                body: 'Pull down to retry when the backend is available.',
              ),
            ],
          ),
          data: (value) {
            if (value.timeline.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  KajuEmptyState(
                    icon: Icons.history_outlined,
                    title: 'No history yet',
                    body: 'Deals, payments, and calls will collect here.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                KajuSpacing.lg,
                KajuSpacing.lg,
                KajuSpacing.lg,
                KajuSpacing.xl,
              ),
              itemBuilder: (context, index) {
                return _TimelineCard(item: value.timeline[index]);
              },
              separatorBuilder: (_, __) => const SizedBox(
                height: KajuSpacing.md,
              ),
              itemCount: value.timeline.length,
            );
          },
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.item});

  final PartyTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final amount = item.amountPaise;

    return KajuCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _toneColor(colors).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(KajuRadius.md),
            ),
            child: Icon(_icon(), color: _toneColor(colors), size: 20),
          ),
          const SizedBox(width: KajuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    StatusBadge(label: item.kind.label, tone: _badgeTone()),
                  ],
                ),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  formatKajuDate(item.occurredAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: KajuSpacing.sm),
                  Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (amount != null && amount > 0) ...[
                  const SizedBox(height: KajuSpacing.sm),
                  AmountDisplay(
                    amountPaise: amount,
                    tone: item.kind == PartyTimelineKind.payment
                        ? AmountDisplayTone.received
                        : AmountDisplayTone.neutral,
                    size: AmountDisplaySize.small,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    return switch (item.kind) {
      PartyTimelineKind.deal => Icons.inventory_2_outlined,
      PartyTimelineKind.payment => Icons.payments_outlined,
      PartyTimelineKind.call => Icons.call_outlined,
    };
  }

  Color _toneColor(KajuColorTokens colors) {
    return switch (item.kind) {
      PartyTimelineKind.deal => colors.accent,
      PartyTimelineKind.payment => colors.success,
      PartyTimelineKind.call => colors.info,
    };
  }

  StatusBadgeTone _badgeTone() {
    return switch (item.kind) {
      PartyTimelineKind.deal => StatusBadgeTone.accent,
      PartyTimelineKind.payment => StatusBadgeTone.success,
      PartyTimelineKind.call => StatusBadgeTone.info,
    };
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KajuSpacing.lg,
        KajuSpacing.lg,
        KajuSpacing.lg,
        KajuSpacing.xl,
      ),
      children: const [
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.md),
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.md),
        KajuSkeletonCard(),
      ],
    );
  }
}
