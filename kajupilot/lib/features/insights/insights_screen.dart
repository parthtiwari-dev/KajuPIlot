import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../../shared/widgets/status_badge.dart';
import '../money/data/money_models.dart';
import 'data/insights_api.dart';
import 'data/insights_models.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.kajuColors;
    final dashboard = ref.watch(insightsDashboardProvider);
    final toolsStatus = ref.watch(moreToolsStatusProvider);

    return Scaffold(
      key: const Key('feature-insights-screen'),
      backgroundColor: colors.bgBase,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(insightsDashboardProvider);
          ref.invalidate(moreToolsStatusProvider);
          await Future.wait([
            ref.read(insightsDashboardProvider.future),
            ref.read(moreToolsStatusProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            KajuSpacing.lg,
            KajuSpacing.xl,
            KajuSpacing.lg,
            168,
          ),
          children: [
            Text(
              'INSIGHTS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: KajuSpacing.sm),
            Text('More', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: KajuSpacing.xl),
            dashboard.when(
              loading: () => const _InsightsLoading(),
              error: (_, __) => KajuEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Insights need the backend',
                body: 'Pull down after Docker and the API are running.',
                action: FilledButton.icon(
                  onPressed: () => ref.invalidate(insightsDashboardProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
              data: (value) {
                if (!value.hasData) {
                  return const KajuEmptyState(
                    icon: Icons.query_stats_outlined,
                    title: 'Not enough data yet',
                    body: 'Start adding deals and payments.',
                  );
                }

                return _InsightsContent(dashboard: value);
              },
            ),
            const SizedBox(height: KajuSpacing.lg),
            _MoreToolsSection(status: toolsStatus),
          ],
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.dashboard});

  final InsightsDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiSummaryCard(summary: dashboard.aiSummary),
        const SizedBox(height: KajuSpacing.md),
        _WeeklyStatsCard(weekly: dashboard.weekly),
        const SizedBox(height: KajuSpacing.md),
        _ExpenseDonutCard(weekly: dashboard.weekly),
        const SizedBox(height: KajuSpacing.lg),
        _PartyInsightSection(
          title: 'Top buyers',
          emptyText: 'Sales leaders will show after sale deals.',
          items: dashboard.people.topBuyers.isNotEmpty
              ? dashboard.people.topBuyers
              : dashboard.weekly.topBuyers,
          amountLabel: 'sale value',
          tone: AmountDisplayTone.received,
        ),
        const SizedBox(height: KajuSpacing.lg),
        _PartyInsightSection(
          title: 'Slow payers',
          emptyText: 'Late payment patterns will show here.',
          items: dashboard.people.slowPayers.isNotEmpty
              ? dashboard.people.slowPayers
              : dashboard.weekly.slowestPayers,
          amountLabel: 'overdue',
          tone: AmountDisplayTone.overdue,
          showDelay: true,
        ),
        const SizedBox(height: KajuSpacing.lg),
        _PartyInsightSection(
          title: 'Inactive customers',
          emptyText: 'Customers with no recent activity appear here.',
          items: dashboard.people.inactiveCustomers,
          amountLabel: 'last sale',
          tone: AmountDisplayTone.neutral,
          showInactiveDays: true,
        ),
        const SizedBox(height: KajuSpacing.lg),
        _AiTipsCard(insights: dashboard.aiWeekly.insights),
      ],
    );
  }
}

class _MoreToolsSection extends StatelessWidget {
  const _MoreToolsSection({required this.status});

  final AsyncValue<MoreToolsStatus> status;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOOLS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: KajuSpacing.md),
        KajuCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              status.when(
                loading: () => const _ToolRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI provider',
                  subtitle: 'Checking active model',
                ),
                error: (_, __) => const _ToolRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI provider',
                  subtitle: 'Unavailable',
                  trailing: StatusBadge(
                    label: 'Offline',
                    tone: StatusBadgeTone.danger,
                  ),
                ),
                data: (value) => _ToolRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI provider',
                  subtitle:
                      '${value.aiProvider.provider} / ${value.aiProvider.model}',
                  trailing: const StatusBadge(
                    label: 'Active',
                    tone: StatusBadgeTone.info,
                  ),
                ),
              ),
              const _ToolDivider(),
              status.when(
                loading: () => const _ToolRow(
                  icon: Icons.cloud_outlined,
                  title: 'Backend',
                  subtitle: 'Checking API',
                ),
                error: (_, __) => const _ToolRow(
                  icon: Icons.cloud_off_outlined,
                  title: 'Backend',
                  subtitle: 'Unavailable',
                  trailing: StatusBadge(
                    label: 'Offline',
                    tone: StatusBadgeTone.danger,
                  ),
                ),
                data: (value) => _ToolRow(
                  icon: value.backend.ok
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  title: 'Backend',
                  subtitle: value.backend.service ?? 'API unavailable',
                  trailing: StatusBadge(
                    label: value.backend.ok ? 'OK' : 'Offline',
                    tone: value.backend.ok
                        ? StatusBadgeTone.success
                        : StatusBadgeTone.danger,
                  ),
                ),
              ),
              const _ToolDivider(),
              status.when(
                loading: () => const _ToolRow(
                  icon: Icons.sync_outlined,
                  title: 'Sync queue',
                  subtitle: 'Checking local queue',
                ),
                error: (_, __) => const _ToolRow(
                  icon: Icons.sync_problem_outlined,
                  title: 'Sync queue',
                  subtitle: 'Unavailable',
                ),
                data: (value) => _ToolRow(
                  icon: value.pendingSyncCount == 0
                      ? Icons.sync_outlined
                      : Icons.sync_problem_outlined,
                  title: 'Sync queue',
                  subtitle: value.pendingSyncCount == 0
                      ? 'No pending local changes'
                      : '${value.pendingSyncCount} pending local changes',
                  trailing: StatusBadge(
                    label: value.pendingSyncCount == 0 ? 'Clear' : 'Pending',
                    tone: value.pendingSyncCount == 0
                        ? StatusBadgeTone.success
                        : StatusBadgeTone.warning,
                  ),
                ),
              ),
              const _ToolDivider(),
              _ThemeToolRow(
                  isDark: Theme.of(context).brightness == Brightness.dark),
              const _ToolDivider(),
              const _ToolRow(
                icon: Icons.bar_chart_outlined,
                title: 'Reports',
                subtitle: 'Coming in the reports phase',
                trailing: StatusBadge(label: 'Later'),
              ),
              const _ToolDivider(),
              const _ToolRow(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin',
                subtitle: 'Dashboard stays separate for now',
                trailing: StatusBadge(label: 'Later'),
              ),
              const _ToolDivider(),
              const _ToolRow(
                icon: Icons.info_outline,
                title: 'KajuPilot',
                subtitle: 'Private trader operating system',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeToolRow extends StatelessWidget {
  const _ThemeToolRow({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _ToolRow(
      icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      title: 'Theme',
      subtitle: isDark ? 'Dark mode' : 'Light mode',
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          if (value) {
            AdaptiveTheme.of(context).setDark();
          } else {
            AdaptiveTheme.of(context).setLight();
          }
        },
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KajuSpacing.md,
        vertical: KajuSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.textSecondary, size: 22),
          const SizedBox(width: KajuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: KajuSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  const _ToolDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: context.kajuColors.borderSubtle,
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});

  final AiTodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 20),
              const SizedBox(width: KajuSpacing.sm),
              Expanded(
                child: Text(
                  'AI summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(
                label: summary.cached ? 'Cached' : 'Fresh',
                tone: summary.cached
                    ? StatusBadgeTone.neutral
                    : StatusBadgeTone.info,
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Text(
            summary.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStatsCard extends StatelessWidget {
  const _WeeklyStatsCard({required this.weekly});

  final WeeklyInsights weekly;

  @override
  Widget build(BuildContext context) {
    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: Theme.of(context).textTheme.titleMedium),
          if (weekly.from.isNotEmpty && weekly.to.isNotEmpty) ...[
            const SizedBox(height: KajuSpacing.xs),
            Text(
              '${weekly.from} to ${weekly.to}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: KajuSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _AmountMetric(
                  label: 'Revenue',
                  amountPaise: weekly.revenuePaise,
                  tone: AmountDisplayTone.received,
                ),
              ),
              Expanded(
                child: _AmountMetric(
                  label: 'Profit est.',
                  amountPaise: weekly.grossProfitEstimatePaise,
                  tone: weekly.grossProfitEstimatePaise >= 0
                      ? AmountDisplayTone.received
                      : AmountDisplayTone.overdue,
                ),
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          Row(
            children: [
              Expanded(
                child: _AmountMetric(
                  label: 'Business spend',
                  amountPaise: weekly.businessExpensesPaise,
                  tone: AmountDisplayTone.pending,
                ),
              ),
              Expanded(
                child: _NumberMetric(
                  label: 'Deals closed',
                  value: '${weekly.dealsClosedCount}',
                ),
              ),
              Expanded(
                child: _NumberMetric(
                  label: 'New people',
                  value: '${weekly.newPartiesCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountMetric extends StatelessWidget {
  const _AmountMetric({
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

class _NumberMetric extends StatelessWidget {
  const _NumberMetric({required this.label, required this.value});

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

class _ExpenseDonutCard extends StatelessWidget {
  const _ExpenseDonutCard({required this.weekly});

  final WeeklyInsights weekly;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final entries = weekly.expenseByCategoryPaise.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business expense mix',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: KajuSpacing.md),
          if (entries.isEmpty)
            Text(
              'No business expenses in this period.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 116,
                  height: 116,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 34,
                      sectionsSpace: 2,
                      sections: [
                        for (var index = 0; index < entries.length; index++)
                          PieChartSectionData(
                            value: entries[index].value.toDouble(),
                            color: _chartColor(colors, index),
                            radius: 24,
                            title: '',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: KajuSpacing.lg),
                Expanded(
                  child: Column(
                    children: [
                      for (var index = 0;
                          index < entries.take(5).length;
                          index++)
                        _ExpenseLegendRow(
                          category: entries[index].key,
                          amountPaise: entries[index].value,
                          color: _chartColor(colors, index),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (weekly.personalExpensesPaise > 0) ...[
            const SizedBox(height: KajuSpacing.md),
            Text(
              'Personal expenses are tracked separately from business profit.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }

  Color _chartColor(KajuColorTokens colors, int index) {
    return [
      colors.accent,
      colors.success,
      colors.warning,
      colors.info,
      colors.danger,
      colors.textSecondary,
    ][index % 6];
  }
}

class _ExpenseLegendRow extends StatelessWidget {
  const _ExpenseLegendRow({
    required this.category,
    required this.amountPaise,
    required this.color,
  });

  final ExpenseCategoryValue category;
  final int amountPaise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KajuSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(KajuRadius.full),
            ),
          ),
          const SizedBox(width: KajuSpacing.sm),
          Expanded(
            child: Text(
              category.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          AmountDisplay(
            amountPaise: amountPaise,
            size: AmountDisplaySize.small,
            tone: AmountDisplayTone.pending,
          ),
        ],
      ),
    );
  }
}

class _PartyInsightSection extends StatelessWidget {
  const _PartyInsightSection({
    required this.title,
    required this.emptyText,
    required this.items,
    required this.amountLabel,
    required this.tone,
    this.showDelay = false,
    this.showInactiveDays = false,
  });

  final String title;
  final String emptyText;
  final List<PartyInsightItem> items;
  final String amountLabel;
  final AmountDisplayTone tone;
  final bool showDelay;
  final bool showInactiveDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: KajuSpacing.md),
        if (items.isEmpty)
          KajuCard(
            child: Text(
              emptyText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          )
        else
          for (final item in items.take(5)) ...[
            _PartyInsightRow(
              item: item,
              amountLabel: amountLabel,
              tone: tone,
              showDelay: showDelay,
              showInactiveDays: showInactiveDays,
            ),
            const SizedBox(height: KajuSpacing.md),
          ],
      ],
    );
  }
}

class _PartyInsightRow extends StatelessWidget {
  const _PartyInsightRow({
    required this.item,
    required this.amountLabel,
    required this.tone,
    required this.showDelay,
    required this.showInactiveDays,
  });

  final PartyInsightItem item;
  final String amountLabel;
  final AmountDisplayTone tone;
  final bool showDelay;
  final bool showInactiveDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final amount = item.overdueAmountPaise > 0
        ? item.overdueAmountPaise
        : item.amountPaise;

    return KajuCard(
      onTap: item.partyId.isEmpty
          ? null
          : () => context.push('/people/${item.partyId}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  _subtitle(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount > 0)
                AmountDisplay(
                  amountPaise: amount,
                  tone: tone,
                  size: AmountDisplaySize.small,
                )
              else
                StatusBadge(label: item.trustTag.label),
              const SizedBox(height: KajuSpacing.xs),
              Text(amountLabel, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    if (showInactiveDays) {
      final days = item.daysInactive;
      if (days == null) {
        return 'No recent activity';
      }
      return '$days days inactive';
    }
    if (showDelay) {
      return '${item.avgDelayDays}d avg delay, ${item.latePaymentCount} late';
    }
    return '${item.dealCount} sale deals';
  }
}

class _AiTipsCard extends StatelessWidget {
  const _AiTipsCard({required this.insights});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI weekly notes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: KajuSpacing.md),
          if (insights.isEmpty)
            Text(
              'Add more activity to unlock useful weekly notes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            )
          else
            for (final insight in insights.take(4)) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: KajuSpacing.sm),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KajuSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _InsightsLoading extends StatelessWidget {
  const _InsightsLoading();

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
