import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import 'data/parties_repository.dart';
import 'data/party_models.dart';
import 'widgets/party_card.dart';
import 'widgets/person_sheet.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _searchController = TextEditingController();
  var _query = const PartyListQuery();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(partyListProvider(_query));
    final colors = context.kajuColors;

    return RefreshIndicator(
      color: colors.accent,
      backgroundColor: colors.bgElevated,
      onRefresh: () => ref.read(partiesRepositoryProvider).refresh(),
      child: ListView(
        key: const Key('feature-people-screen'),
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
                      'CUSTOMERS AND SUPPLIERS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.textMuted,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: KajuSpacing.sm),
                    Text('People',
                        style: Theme.of(context).textTheme.displayLarge),
                  ],
                ),
              ),
              IconButton.filled(
                key: const Key('add-person-button'),
                onPressed: () => showPersonSheet(context),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Add person',
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.lg),
          TextField(
            key: const Key('people-search-field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search people',
            ),
            onChanged: (value) {
              setState(() {
                _query = PartyListQuery(search: value, filter: _query.filter);
              });
            },
          ),
          const SizedBox(height: KajuSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in PartyListFilter.values) ...[
                  FilterChip(
                    key: Key('people-filter-${filter.name}'),
                    selected: _query.filter == filter,
                    label: Text(filter.label),
                    onSelected: (_) {
                      setState(() {
                        _query = PartyListQuery(
                          search: _query.search,
                          filter: filter,
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
          parties.when(
            loading: () => const _PeopleLoadingState(),
            error: (_, __) => KajuEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'People are saved locally',
              body: 'Pull down to retry sync.',
              action: OutlinedButton.icon(
                onPressed: () => ref.refresh(partyListProvider(_query)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return KajuEmptyState(
                  icon: Icons.groups_2_outlined,
                  title: _query.search.isEmpty ? 'No people yet' : 'No matches',
                  body: _query.search.isEmpty
                      ? 'Add the first customer or supplier.'
                      : 'Try a different search.',
                  action: FilledButton.icon(
                    onPressed: () => showPersonSheet(context),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Add person'),
                  ),
                );
              }

              return Column(
                children: [
                  for (final item in items) ...[
                    Dismissible(
                      key: Key('party-${item.party.id}'),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(item),
                      child: PartyCard(item: item),
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

  Future<void> _delete(PartyListItem item) async {
    final repository = ref.read(partiesRepositoryProvider);
    final deleted = await repository.softDelete(item.party.id);
    if (!mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.party.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(item.party),
        ),
      ),
    );
  }
}

class _PeopleLoadingState extends StatelessWidget {
  const _PeopleLoadingState();

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
