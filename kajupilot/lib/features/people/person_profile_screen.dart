import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/app_database.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_action_button.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/person_avatar.dart';
import 'data/parties_repository.dart';
import 'data/party_models.dart';
import 'widgets/person_sheet.dart';

class PersonProfileScreen extends ConsumerStatefulWidget {
  const PersonProfileScreen({super.key, required this.partyId});

  final String partyId;

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
    _tabController = TabController(length: 4, vsync: this);
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
              _TrustSelector(party: party),
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
                  children: [
                    const _ProfileEmptyTab(
                      icon: Icons.inventory_2_outlined,
                      title: 'No deals yet',
                    ),
                    const _ProfileEmptyTab(
                      icon: Icons.currency_rupee,
                      title: 'No payments yet',
                    ),
                    const _ProfileEmptyTab(
                      icon: Icons.call_outlined,
                      title: 'No calls yet',
                    ),
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
                  onPressed: party.phone == null
                      ? null
                      : () {
                          final number = party.phone!.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          unawaited(
                            launchUrl(Uri.parse('https://wa.me/91$number')),
                          );
                        },
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

class _ProfileStats extends ConsumerWidget {
  const _ProfileStats({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(partyStatsProvider(partyId));

    return stats.when(
      loading: () => const KajuCard(child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (value) => KajuCard(
        child: Row(
          children: [
            Expanded(
              child: _StatTile(label: 'Deals', value: '${value.dealCount}'),
            ),
            Expanded(
              child: _AmountStatTile(
                label: 'Pending',
                amountPaise: value.pendingAmountPaise,
              ),
            ),
            Expanded(
              child: _StatTile(
                  label: 'Avg delay', value: '${value.avgDelayDays}d'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustSelector extends ConsumerWidget {
  const _TrustSelector({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = TrustTagValue.fromApi(party.trustTag);

    return Wrap(
      spacing: KajuSpacing.sm,
      runSpacing: KajuSpacing.sm,
      children: [
        for (final tag in TrustTagValue.values)
          ChoiceChip(
            selected: selected == tag,
            label: Text(tag.label),
            onSelected: (_) {
              ref.read(partiesRepositoryProvider).update(
                    party.id,
                    UpdatePartyInput(trustTag: tag),
                  );
            },
          ),
      ],
    );
  }
}

class _ProfileEmptyTab extends StatelessWidget {
  const _ProfileEmptyTab({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return KajuEmptyState(
      icon: icon,
      title: title,
      body: 'No records here yet.',
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
  });

  final String label;
  final int amountPaise;

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
          tone: amountPaise > 0
              ? AmountDisplayTone.pending
              : AmountDisplayTone.neutral,
        ),
      ],
    );
  }
}
