import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/app_database.dart';
import '../../core/sync/sync_coordinator.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_action_button.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../../shared/widgets/person_avatar.dart';
import '../../shared/widgets/status_badge.dart';
import '../deals/data/deal_models.dart';
import '../deals/data/deals_repository.dart';
import '../deals/widgets/deal_card.dart';
import '../deals/widgets/deal_sheet.dart';
import '../money/data/money_models.dart';
import '../money/data/payments_repository.dart';
import '../money/widgets/payment_card.dart';
import '../money/widgets/payment_sheet.dart';
import '../today/data/call_logs_repository.dart';
import '../today/data/today_models.dart';
import '../today/widgets/call_log_card.dart';
import 'data/parties_repository.dart';
import 'data/party_models.dart';
import 'widgets/person_sheet.dart';

class PersonProfileScreen extends ConsumerStatefulWidget {
  const PersonProfileScreen({
    super.key,
    required this.partyId,
    this.initialTabIndex = 0,
  });

  final String partyId;
  final int initialTabIndex;

  @override
  ConsumerState<PersonProfileScreen> createState() =>
      _PersonProfileScreenState();
}

class _PersonProfileScreenState extends ConsumerState<PersonProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _notesController = TextEditingController();
  Timer? _notesDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      initialIndex: widget.initialTabIndex,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _notesDebounce?.cancel();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partyState = ref.watch(partyProvider(widget.partyId));
    final colors = context.kajuColors;

    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Person'),
      ),
      body: partyState.when(
        loading: () => const _ProfileLoadingState(),
        error: (_, __) => const KajuEmptyState(
          icon: Icons.error_outline,
          title: 'Could not open person',
          body: 'Go back and try again.',
        ),
        data: (party) {
          if (party == null) {
            return const KajuEmptyState(
              icon: Icons.person_off_outlined,
              title: 'Person not found',
              body: 'This record may have been deleted.',
            );
          }

          if (_notesController.text != (party.notes ?? '')) {
            _notesController.text = party.notes ?? '';
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              KajuSpacing.lg,
              KajuSpacing.md,
              KajuSpacing.lg,
              KajuSpacing.xl,
            ),
            children: [
              _ProfileHeader(party: party),
              const SizedBox(height: KajuSpacing.lg),
              _ProfileStats(partyId: party.id),
              const SizedBox(height: KajuSpacing.lg),
              _TrustBadge(party: party),
              const SizedBox(height: KajuSpacing.md),
              _ProfileHistoryButton(partyId: party.id),
              const SizedBox(height: KajuSpacing.lg),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Deals'),
                  Tab(text: 'Payments'),
                  Tab(text: 'Calls'),
                  Tab(text: 'Notes'),
                ],
              ),
              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ProfileDealsTab(partyId: party.id),
                    _ProfilePaymentsTab(partyId: party.id),
                    _ProfileCallsTab(partyId: party.id),
                    _NotesTab(
                      controller: _notesController,
                      onChanged: (value) => _saveNotes(party, value),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveNotes(Party party, String value) {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 700), () {
      ref.read(partiesRepositoryProvider).update(
            party.id,
            UpdatePartyInput(notes: value),
          );
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context) {
    final type = PartyTypeValue.fromApi(party.type);
    final whatsAppUri = _whatsAppUri(party.phone);

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonAvatar(name: party.name, size: 52),
              const SizedBox(width: KajuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: KajuSpacing.xs),
                    Text(type.label,
                        style: Theme.of(context).textTheme.bodyMedium),
                    if (party.phone != null) ...[
                      const SizedBox(height: KajuSpacing.xs),
                      Text(
                        party.phone!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showPersonSheet(context, party: party),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.lg),
          Row(
            children: [
              Expanded(
                child: KajuActionButton(phoneNumber: party.phone),
              ),
              const SizedBox(width: KajuSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: whatsAppUri == null
                      ? null
                      : () => unawaited(launchUrl(whatsAppUri)),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Uri? _whatsAppUri(String? phone) {
  final digits = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (digits.isEmpty) {
    return null;
  }

  final normalized = switch (digits.length) {
    10 => '91$digits',
    11 when digits.startsWith('0') => '91${digits.substring(1)}',
    >= 11 && <= 15 => digits,
    _ => null,
  };

  return normalized == null ? null : Uri.parse('https://wa.me/$normalized');
}

class _ProfileStats extends ConsumerWidget {
  const _ProfileStats({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(partyStatsProvider(partyId));

    return stats.when(
      loading: () => const KajuSkeletonCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (value) => KajuCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatTile(label: 'Deals', value: '${value.dealCount}'),
                ),
                Expanded(
                  child: _AmountStatTile(
                    label: 'Pending',
                    amountPaise: value.pendingAmountPaise,
                    tone: value.pendingAmountPaise > 0
                        ? AmountDisplayTone.pending
                        : AmountDisplayTone.neutral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KajuSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _AmountStatTile(
                    label: 'Overdue',
                    amountPaise: value.overdueAmountPaise,
                    tone: value.overdueAmountPaise > 0
                        ? AmountDisplayTone.overdue
                        : AmountDisplayTone.neutral,
                  ),
                ),
                Expanded(
                  child: _AmountStatTile(
                    label: 'Sale value',
                    amountPaise: value.totalSaleValuePaise,
                    tone: AmountDisplayTone.received,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KajuSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: _StatTile(
                label: 'Avg delay',
                value: value.avgDelayDays == null
                    ? '--'
                    : '${value.avgDelayDays}d',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends ConsumerWidget {
  const _TrustBadge({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = TrustTagValue.fromApi(party.trustTag);
    final colors = context.kajuColors;

    return KajuCard(
      onTap: () => _showTrustSheet(context, ref, selected),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined,
              color: _trustColor(colors, selected)),
          const SizedBox(width: KajuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trust tag',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  party.trustTagManualOverride
                      ? 'Manual: ${selected.label}'
                      : 'Auto: ${selected.label}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          StatusBadge(label: selected.label, tone: _trustTone(selected)),
          const SizedBox(width: KajuSpacing.sm),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Future<void> _showTrustSheet(
    BuildContext context,
    WidgetRef ref,
    TrustTagValue selected,
  ) async {
    final tag = await showModalBottomSheet<TrustTagValue>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KajuSpacing.lg,
                  KajuSpacing.sm,
                  KajuSpacing.lg,
                  KajuSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Set trust tag',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final tag in TrustTagValue.values)
                ListTile(
                  selected: selected == tag,
                  leading: Icon(
                    selected == tag
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(tag.label),
                  onTap: () => Navigator.of(context).pop(tag),
                ),
            ],
          ),
        );
      },
    );

    if (tag != null) {
      await ref.read(partiesRepositoryProvider).update(
            party.id,
            UpdatePartyInput(trustTag: tag),
          );
    }
  }
}

class _ProfileHistoryButton extends StatelessWidget {
  const _ProfileHistoryButton({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push('/people/$partyId/history'),
      icon: const Icon(Icons.history_outlined),
      label: const Text('Open full history'),
    );
  }
}

StatusBadgeTone _trustTone(TrustTagValue tag) {
  return switch (tag) {
    TrustTagValue.reliable => StatusBadgeTone.success,
    TrustTagValue.slowPayer => StatusBadgeTone.warning,
    TrustTagValue.risky => StatusBadgeTone.danger,
    TrustTagValue.fresh => StatusBadgeTone.neutral,
  };
}

Color _trustColor(KajuColorTokens colors, TrustTagValue tag) {
  return switch (tag) {
    TrustTagValue.reliable => colors.success,
    TrustTagValue.slowPayer => colors.warning,
    TrustTagValue.risky => colors.danger,
    TrustTagValue.fresh => colors.textSecondary,
  };
}

class _ProfileEmptyTab extends StatelessWidget {
  const _ProfileEmptyTab({
    required this.icon,
    required this.title,
    this.body = 'No records here yet.',
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return KajuEmptyState(
      icon: icon,
      title: title,
      body: body,
      action: action,
    );
  }
}

class _ProfileDealsTab extends ConsumerWidget {
  const _ProfileDealsTab({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(
      dealListProvider(DealListQuery(partyId: partyId)),
    );

    return deals.when(
      loading: () => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [_ProfileTabLoading()],
      ),
      error: (_, __) => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [
          _ProfileEmptyTab(
            icon: Icons.cloud_off_outlined,
            title: 'Deals are saved locally',
            body: 'Pull down to refresh when connection is back.',
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) {
          return _ProfileRefreshList(
            onRefresh: () => _refresh(ref),
            children: [
              _ProfileEmptyTab(
                icon: Icons.inventory_2_outlined,
                title: 'No deals yet',
                body: 'Add the first sale or purchase for this person.',
                action: FilledButton.icon(
                  onPressed: () => showDealSheet(context),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Add deal'),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: KajuSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key('profile-deal-${item.deal.id}'),
                direction: DismissDirection.endToStart,
                background: const _ProfileDeleteBackground(),
                onDismissed: (_) => _delete(context, ref, item),
                child: DealCard(
                  item: item,
                  onTap: () => showDealSheet(context, item: item),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(
              height: KajuSpacing.md,
            ),
            itemCount: items.length,
          ),
        );
      },
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref.read(dealsRepositoryProvider).refresh(
            query: DealListQuery(partyId: partyId),
            flushPending: false,
          );
      ref.invalidate(partyStatsProvider(partyId));
    } catch (_) {
      // Refresh is intentionally quiet; local profile data remains visible.
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DealListItem item,
  ) async {
    final repository = ref.read(dealsRepositoryProvider);
    final deleted = await repository.softDelete(item.deal.id);
    ref.invalidate(partyStatsProvider(partyId));
    if (!context.mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.gradeSummary} deal deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(repository.restore(item.deal).then((_) {
              ref.invalidate(partyStatsProvider(partyId));
            }));
          },
        ),
      ),
    );
  }
}

class _ProfilePaymentsTab extends ConsumerWidget {
  const _ProfilePaymentsTab({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(
      paymentListProvider(PaymentListQuery(partyId: partyId)),
    );

    return payments.when(
      loading: () => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [_ProfileTabLoading()],
      ),
      error: (_, __) => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [
          _ProfileEmptyTab(
            icon: Icons.cloud_off_outlined,
            title: 'Payments are saved locally',
            body: 'Pull down to refresh when connection is back.',
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) {
          return _ProfileRefreshList(
            onRefresh: () => _refresh(ref),
            children: [
              _ProfileEmptyTab(
                icon: Icons.currency_rupee,
                title: 'No payments yet',
                body: 'Record money received or paid for this person.',
                action: FilledButton.icon(
                  onPressed: () => showPaymentSheet(context),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Add payment'),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: KajuSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key('profile-payment-${item.payment.id}'),
                direction: DismissDirection.endToStart,
                background: const _ProfileDeleteBackground(),
                onDismissed: (_) => _delete(context, ref, item),
                child: PaymentCard(
                  item: item,
                  onTap: () => showPaymentSheet(context, item: item),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(
              height: KajuSpacing.md,
            ),
            itemCount: items.length,
          ),
        );
      },
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref.read(paymentsRepositoryProvider).refresh(
            query: PaymentListQuery(partyId: partyId),
            flushPending: false,
          );
      ref.invalidate(partyStatsProvider(partyId));
    } catch (_) {
      // Refresh is intentionally quiet; local profile data remains visible.
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PaymentListItem item,
  ) async {
    final repository = ref.read(paymentsRepositoryProvider);
    final deleted = await repository.softDelete(item.payment.id);
    ref.invalidate(partyStatsProvider(partyId));
    if (!context.mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.party.name} payment deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(repository.restore(item.payment).then((_) {
              ref.invalidate(partyStatsProvider(partyId));
            }));
          },
        ),
      ),
    );
  }
}

class _ProfileCallsTab extends ConsumerWidget {
  const _ProfileCallsTab({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.watch(
      callLogListProvider(CallLogListQuery(partyId: partyId)),
    );

    return calls.when(
      loading: () => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [_ProfileTabLoading()],
      ),
      error: (_, __) => _ProfileRefreshList(
        onRefresh: () => _refresh(ref),
        children: const [
          _ProfileEmptyTab(
            icon: Icons.cloud_off_outlined,
            title: 'Calls are saved locally',
            body: 'Pull down to refresh when connection is back.',
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) {
          return _ProfileRefreshList(
            onRefresh: () => _refresh(ref),
            children: const [
              _ProfileEmptyTab(
                icon: Icons.call_outlined,
                title: 'No calls yet',
                body: 'Call outcomes will appear here after Today tasks.',
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: KajuSpacing.md),
            itemBuilder: (context, index) {
              return CallLogCard(item: items[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(
              height: KajuSpacing.md,
            ),
            itemCount: items.length,
          ),
        );
      },
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref.read(callLogsRepositoryProvider).refresh(
            query: CallLogListQuery(partyId: partyId),
            flushPending: false,
          );
    } catch (_) {
      // Refresh is intentionally quiet; local profile data remains visible.
    }
  }
}

class _ProfileRefreshList extends StatelessWidget {
  const _ProfileRefreshList({
    required this.onRefresh,
    required this.children,
  });

  final RefreshCallback onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: KajuSpacing.md),
        children: children,
      ),
    );
  }
}

class _ProfileTabLoading extends StatelessWidget {
  const _ProfileTabLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.md),
        KajuSkeletonCard(),
      ],
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KajuSpacing.lg,
        KajuSpacing.md,
        KajuSpacing.lg,
        KajuSpacing.xl,
      ),
      children: const [
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.lg),
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.lg),
        KajuSkeletonCard(),
      ],
    );
  }
}

class _ProfileDeleteBackground extends StatelessWidget {
  const _ProfileDeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Container(
      padding: const EdgeInsets.only(right: KajuSpacing.lg),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: colors.dangerMuted,
        borderRadius: BorderRadius.circular(KajuRadius.lg),
      ),
      child: Icon(Icons.delete_outline, color: colors.danger),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KajuSpacing.md),
      child: TextField(
        controller: controller,
        minLines: 8,
        maxLines: 12,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Notes',
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: KajuSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _AmountStatTile extends StatelessWidget {
  const _AmountStatTile({
    required this.label,
    required this.amountPaise,
    required this.tone,
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
          size: AmountDisplaySize.small,
          tone: tone,
        ),
      ],
    );
  }
}
