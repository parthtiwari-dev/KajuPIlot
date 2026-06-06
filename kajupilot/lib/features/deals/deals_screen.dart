import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/sync/sync_coordinator.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import 'data/deal_models.dart';
import 'data/deals_repository.dart';
import 'widgets/deal_card.dart';
import 'widgets/deal_sheet.dart';

class DealsScreen extends ConsumerStatefulWidget {
  const DealsScreen({super.key});

  @override
  ConsumerState<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends ConsumerState<DealsScreen> {
  final _searchController = TextEditingController();
  var _query = const DealListQuery();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deals = ref.watch(dealListProvider(_query));
    final colors = context.kajuColors;

    return RefreshIndicator(
      color: colors.accent,
      backgroundColor: colors.bgElevated,
      onRefresh: _refresh,
      child: ListView(
        key: const Key('feature-deals-screen'),
        padding: const EdgeInsets.fromLTRB(
          KajuSpacing.lg,
          KajuSpacing.xl,
          KajuSpacing.lg,
          180,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SALES AND PURCHASES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.textMuted,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: KajuSpacing.sm),
                    Text('Deals',
                        style: Theme.of(context).textTheme.displayLarge),
                  ],
                ),
              ),
              IconButton.filled(
                key: const Key('add-deal-button'),
                onPressed: () => showDealSheet(context),
                icon: const Icon(Icons.add_business_outlined),
                tooltip: 'Add deal',
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.lg),
          TextField(
            key: const Key('deals-search-field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search party or grade',
            ),
            onChanged: (value) {
              setState(() {
                _query = DealListQuery(
                  search: value,
                  filter: _query.filter,
                  partyId: _query.partyId,
                );
              });
            },
          ),
          const SizedBox(height: KajuSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in DealListFilter.values) ...[
                  FilterChip(
                    key: Key('deals-filter-${filter.name}'),
                    selected: _query.filter == filter,
                    label: Text(filter.label),
                    onSelected: (_) {
                      setState(() {
                        _query = DealListQuery(
                          search: _query.search,
                          filter: filter,
                          partyId: _query.partyId,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: KajuSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: KajuSpacing.lg),
          deals.when(
            loading: () => const _DealsLoadingState(),
            error: (_, __) => KajuEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Deals are saved locally',
              body: 'Pull down to retry sync.',
              action: OutlinedButton.icon(
                onPressed: () => ref.refresh(dealListProvider(_query)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return KajuEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: _query.search.isEmpty ? 'No deals yet' : 'No matches',
                  body: _query.search.isEmpty
                      ? 'Add the first sale or purchase deal.'
                      : 'Try a different search.',
                  action: FilledButton.icon(
                    onPressed: () => showDealSheet(context),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Add deal'),
                  ),
                );
              }

              return Column(
                children: [
                  for (final item in items) ...[
                    Dismissible(
                      key: Key('deal-${item.deal.id}'),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(item),
                      child: DealCard(
                        item: item,
                        onTap: () => showDealSheet(context, item: item),
                      ),
                    ),
                    const SizedBox(height: KajuSpacing.md),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref
          .read(dealsRepositoryProvider)
          .refresh(query: _query, flushPending: false);
    } catch (_) {
      // Refresh is intentionally quiet; local data remains visible offline.
    }
  }

  Future<void> _delete(DealListItem item) async {
    final repository = ref.read(dealsRepositoryProvider);
    final deleted = await repository.softDelete(item.deal.id);
    if (!mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.deal.cashewGrade} deal deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(item.deal),
        ),
      ),
    );
  }
}

class _DealsLoadingState extends StatelessWidget {
  const _DealsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.md),
        KajuSkeletonCard(),
        SizedBox(height: KajuSpacing.md),
        KajuSkeletonCard(),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Container(
      margin: const EdgeInsets.only(bottom: KajuSpacing.md),
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
