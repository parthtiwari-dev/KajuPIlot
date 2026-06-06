import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/sync/sync_coordinator.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/currency.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../deals/data/deals_repository.dart';
import '../people/data/parties_repository.dart';
import 'data/expenses_repository.dart';
import 'data/money_models.dart';
import 'data/payments_repository.dart';
import 'widgets/expense_card.dart';
import 'widgets/expense_sheet.dart';
import 'widgets/ledger_party_card.dart';
import 'widgets/payment_sheet.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  var _expenseQuery = const ExpenseListQuery();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final ledger = ref.watch(moneyLedgerProvider);

    return Column(
      key: const Key('feature-money-screen'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KajuSpacing.lg,
            KajuSpacing.xl,
            KajuSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECEIVABLES AND EXPENSES',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const SizedBox(height: KajuSpacing.sm),
                        Text(
                          'Money',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    key: const Key('add-payment-button'),
                    onPressed: () => showPaymentSheet(context),
                    icon: const Icon(Icons.payments_outlined),
                    tooltip: 'Add payment',
                  ),
                  const SizedBox(width: KajuSpacing.sm),
                  IconButton.filledTonal(
                    key: const Key('add-expense-button'),
                    onPressed: () => showExpenseSheet(context),
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: 'Add expense',
                  ),
                ],
              ),
              const SizedBox(height: KajuSpacing.lg),
              ledger.when(
                loading: () => const KajuSkeletonCard(),
                error: (_, __) => const _MoneySummaryCard(
                  receivablePaise: 0,
                  payablePaise: 0,
                  netPaise: 0,
                ),
                data: (snapshot) => _MoneySummaryCard(
                  receivablePaise: snapshot.totalReceivablePaise,
                  payablePaise: snapshot.totalPayablePaise,
                  netPaise: snapshot.netPaise,
                ),
              ),
              const SizedBox(height: KajuSpacing.md),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Receivable'),
                  Tab(text: 'Payable'),
                  Tab(text: 'Expenses'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _LedgerTab(
                side: PaymentTypeValue.received,
                parties: ledger.valueOrNull?.receivableParties ?? const [],
              ),
              _LedgerTab(
                side: PaymentTypeValue.paid,
                parties: ledger.valueOrNull?.payableParties ?? const [],
              ),
              _ExpensesTab(
                query: _expenseQuery,
                onQueryChanged: (query) {
                  setState(() => _expenseQuery = query);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoneySummaryCard extends StatelessWidget {
  const _MoneySummaryCard({
    required this.receivablePaise,
    required this.payablePaise,
    required this.netPaise,
  });

  final int receivablePaise;
  final int payablePaise;
  final int netPaise;

  @override
  Widget build(BuildContext context) {
    return KajuCard(
      child: Row(
        children: [
          Expanded(
            child: _SummaryAmount(
              label: 'To receive',
              amountPaise: receivablePaise,
              tone: AmountDisplayTone.received,
            ),
          ),
          Expanded(
            child: _SummaryAmount(
              label: 'To pay',
              amountPaise: payablePaise,
              tone: AmountDisplayTone.pending,
            ),
          ),
          Expanded(
            child: _SummaryAmount(
              label: 'Net',
              amountPaise: netPaise,
              tone: netPaise >= 0
                  ? AmountDisplayTone.received
                  : AmountDisplayTone.overdue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({
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
          tone: tone,
          size: AmountDisplaySize.small,
        ),
      ],
    );
  }
}

class _LedgerTab extends ConsumerWidget {
  const _LedgerTab({
    required this.side,
    required this.parties,
  });

  final PaymentTypeValue side;
  final List<MoneyLedgerParty> parties;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          KajuSpacing.lg,
          KajuSpacing.lg,
          KajuSpacing.lg,
          180,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (parties.isEmpty)
            KajuEmptyState(
              icon: side == PaymentTypeValue.received
                  ? Icons.done_all_outlined
                  : Icons.account_balance_wallet_outlined,
              title: side == PaymentTypeValue.received
                  ? "Everyone's paid up"
                  : 'No payables pending',
              body: 'Balances will appear as deals and payments are recorded.',
            )
          else
            for (final party in parties) ...[
              LedgerPartyCard(party: party, side: side),
              const SizedBox(height: KajuSpacing.md),
            ],
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref.read(partiesRepositoryProvider).refresh(flushPending: false);
      await ref.read(dealsRepositoryProvider).refresh(flushPending: false);
      await ref.read(paymentsRepositoryProvider).refresh(flushPending: false);
    } catch (_) {
      // Refresh is intentionally quiet; local ledger stays usable offline.
    }
  }
}

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab({
    required this.query,
    required this.onQueryChanged,
  });

  final ExpenseListQuery query;
  final ValueChanged<ExpenseListQuery> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider(query));
    final summary = ref.watch(expenseSummaryProvider(query));

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          KajuSpacing.lg,
          KajuSpacing.lg,
          KajuSpacing.lg,
          180,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          summary.when(
            loading: () => const KajuSkeletonCard(),
            error: (_, __) => const SizedBox.shrink(),
            data: (value) => _ExpenseSummaryCard(summary: value),
          ),
          const SizedBox(height: KajuSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  key: const Key('expense-scope-all'),
                  selected: query.scope == null,
                  label: const Text('All'),
                  onSelected: (_) => onQueryChanged(
                    ExpenseListQuery(category: query.category),
                  ),
                ),
                const SizedBox(width: KajuSpacing.sm),
                for (final scope in ExpenseScopeValue.values) ...[
                  FilterChip(
                    key: Key('expense-scope-${scope.name}'),
                    selected: query.scope == scope,
                    label: Text(scope.label),
                    onSelected: (_) => onQueryChanged(
                      ExpenseListQuery(
                        scope: scope,
                        category: query.category,
                      ),
                    ),
                  ),
                  const SizedBox(width: KajuSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: KajuSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  selected: query.category == null,
                  label: const Text('All categories'),
                  onSelected: (_) => onQueryChanged(
                    ExpenseListQuery(scope: query.scope),
                  ),
                ),
                const SizedBox(width: KajuSpacing.sm),
                for (final category in ExpenseCategoryValue.values) ...[
                  FilterChip(
                    selected: query.category == category,
                    label: Text(category.label),
                    onSelected: (_) => onQueryChanged(
                      ExpenseListQuery(
                        scope: query.scope,
                        category: category,
                      ),
                    ),
                  ),
                  const SizedBox(width: KajuSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: KajuSpacing.lg),
          expenses.when(
            loading: () => const Column(
              children: [
                KajuSkeletonCard(),
                SizedBox(height: KajuSpacing.md),
                KajuSkeletonCard(),
              ],
            ),
            error: (_, __) => const KajuEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Expenses are saved locally',
              body: 'Pull down to retry sync.',
            ),
            data: (items) {
              if (items.isEmpty) {
                return KajuEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: query.category == null
                      ? query.scope == null
                          ? 'No expenses yet'
                          : 'No ${query.scope!.label.toLowerCase()} expenses'
                      : 'No expenses in this category',
                  body: 'Add transport, labour, packaging, or other costs.',
                  action: FilledButton.icon(
                    onPressed: () => showExpenseSheet(context),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Add expense'),
                  ),
                );
              }

              return Column(
                children: [
                  for (final expense in items) ...[
                    Dismissible(
                      key: Key('expense-${expense.id}'),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(context, ref, expense),
                      child: ExpenseCard(
                        expense: expense,
                        onTap: () => showExpenseSheet(
                          context,
                          expense: expense,
                        ),
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

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref
          .read(expensesRepositoryProvider)
          .refresh(query: query, flushPending: false);
    } catch (_) {
      // Refresh is intentionally quiet; local expenses stay usable offline.
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final repository = ref.read(expensesRepositoryProvider);
    final deleted = await repository.softDelete(expense.id);
    if (!context.mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${ExpenseCategoryValue.fromApi(expense.category).label} deleted',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(expense),
        ),
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.summary});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final topCategories = summary.byCategoryPaise.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expenses', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: KajuSpacing.xs),
          AmountDisplay(
            amountPaise: summary.totalPaise,
            tone: AmountDisplayTone.pending,
            size: AmountDisplaySize.large,
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ScopeAmount(
                  label: 'Business',
                  amountPaise:
                      summary.byScopePaise[ExpenseScopeValue.business] ?? 0,
                ),
              ),
              Expanded(
                child: _ScopeAmount(
                  label: 'Personal',
                  amountPaise:
                      summary.byScopePaise[ExpenseScopeValue.personal] ?? 0,
                ),
              ),
            ],
          ),
          if (topCategories.isNotEmpty) ...[
            const SizedBox(height: KajuSpacing.md),
            Wrap(
              spacing: KajuSpacing.sm,
              runSpacing: KajuSpacing.sm,
              children: [
                for (final entry in topCategories.take(4))
                  Chip(
                    label: Text(
                      '${entry.key.label}: '
                      '${formatInrFromPaise(entry.value)}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScopeAmount extends StatelessWidget {
  const _ScopeAmount({
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
          tone: AmountDisplayTone.pending,
          size: AmountDisplaySize.small,
        ),
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
