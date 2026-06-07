import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/sync/sync_coordinator.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/amount_display.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../../shared/widgets/person_avatar.dart';
import '../deals/data/deal_models.dart';
import '../deals/data/deals_repository.dart';
import '../deals/widgets/deal_sheet.dart';
import '../money/data/payments_repository.dart';
import '../people/person_profile_screen.dart';
import 'data/tasks_repository.dart';
import 'data/today_models.dart';
import 'widgets/outcome_sheet.dart';
import 'widgets/postpone_sheet.dart';
import 'widgets/task_card.dart';
import 'widgets/task_sheet.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with WidgetsBindingObserver {
  TaskListItem? _pendingCallOutcome;
  DateTime? _callLaunchedAt;
  var _showingOutcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pendingCallOutcome != null &&
        !_showingOutcome) {
      final launchedAt = _callLaunchedAt;
      if (launchedAt == null ||
          DateTime.now().difference(launchedAt) >
              const Duration(milliseconds: 500)) {
        _showOutcomeForPendingCall();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final today = dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final tasksState = ref.watch(todayTasksProvider(today));
    final tomorrowTasks = ref.watch(
      taskListProvider(
        TaskListQuery(
          from: tomorrow,
          to: tomorrow.add(const Duration(days: 1)),
        ),
      ),
    );
    final dealsState = ref.watch(dealListProvider(const DealListQuery()));
    final ledger = ref.watch(moneyLedgerProvider);
    final insights = ref.watch(todayInsightsProvider(today));

    final tasks = tasksState.valueOrNull ?? const <TaskListItem>[];
    final deals = dealsState.valueOrNull ?? const <DealListItem>[];
    final paymentDeals = _paymentDueDeals(deals, today);
    final deliveryDeals = _deliveryDueDeals(deals, today);
    final overdueTasks =
        tasks.where((item) => item.isOverdue(DateTime.now().toUtc())).toList();
    final callTasks = tasks
        .where((item) =>
            item.type == TaskTypeValue.call && !overdueTasks.contains(item))
        .toList();
    final otherTasks = tasks
        .where((item) =>
            item.type != TaskTypeValue.call && !overdueTasks.contains(item))
        .toList();

    return Scaffold(
      key: const Key('feature-today-screen'),
      backgroundColor: colors.bgBase,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-task-button'),
        onPressed: () => showTaskSheet(context),
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Task'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(today),
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
              _greeting(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
            const SizedBox(height: KajuSpacing.xs),
            Text(
              _dateHeader(today),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: KajuSpacing.lg),
            _StatsRow(
              pendingPaise: ledger.valueOrNull?.totalReceivablePaise ??
                  insights.valueOrNull?.pendingCollectionPaise ??
                  0,
              calls: callTasks.length +
                  overdueTasks
                      .where((item) => item.type == TaskTypeValue.call)
                      .length,
              deliveries: deliveryDeals.length +
                  otherTasks
                      .where((item) => item.type == TaskTypeValue.delivery)
                      .length,
            ),
            const SizedBox(height: KajuSpacing.xl),
            if (tasksState.isLoading && tasks.isEmpty)
              const _TodayLoading()
            else if (tasks.isEmpty &&
                paymentDeals.isEmpty &&
                deliveryDeals.isEmpty)
              KajuEmptyState(
                icon: Icons.today_outlined,
                title: 'Nothing on the agenda',
                body: "Add tomorrow's calls from the task button.",
                action: FilledButton.icon(
                  onPressed: () => showTaskSheet(context),
                  icon: const Icon(Icons.add_task_outlined),
                  label: const Text('Add task'),
                ),
              )
            else ...[
              if (overdueTasks.isNotEmpty)
                _TaskSection(
                  title: 'Overdue',
                  items: overdueTasks,
                  onCall: _startCall,
                  onDone: _completeTask,
                  onPostpone: _postponeTask,
                  onTap: (item) => showTaskSheet(context, item: item),
                ),
              if (callTasks.isNotEmpty)
                _TaskSection(
                  title: 'Calls today',
                  items: callTasks,
                  onCall: _startCall,
                  onDone: _completeTask,
                  onPostpone: _postponeTask,
                  onTap: (item) => showTaskSheet(context, item: item),
                ),
              if (paymentDeals.isNotEmpty)
                _DealDueSection(
                  title: 'Payments due',
                  items: paymentDeals,
                  mode: _DealDueMode.payment,
                ),
              if (deliveryDeals.isNotEmpty)
                _DealDueSection(
                  title: 'Deliveries due',
                  items: deliveryDeals,
                  mode: _DealDueMode.delivery,
                ),
              if (otherTasks.isNotEmpty)
                _TaskSection(
                  title: 'Other work',
                  items: otherTasks,
                  onCall: _startCall,
                  onDone: _completeTask,
                  onPostpone: _postponeTask,
                  onTap: (item) => showTaskSheet(context, item: item),
                ),
            ],
            const SizedBox(height: KajuSpacing.lg),
            tomorrowTasks.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const SizedBox.shrink()
                  : _TomorrowPreview(count: items.length),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(DateTime today) async {
    try {
      await ref.read(syncCoordinatorProvider).retryAll();
      await ref
          .read(tasksRepositoryProvider)
          .refreshToday(today, flushPending: false);
      await ref.read(dealsRepositoryProvider).refresh(flushPending: false);
      await ref.read(paymentsRepositoryProvider).refresh(flushPending: false);
      ref.invalidate(todayInsightsProvider(today));
    } catch (_) {
      // Local data remains visible; refresh is quiet by design.
    }
  }

  Future<void> _startCall(TaskListItem item) async {
    final phone = item.party?.phone;
    if (phone == null) {
      return;
    }
    final number = phone.replaceAll(RegExp(r'\D'), '');
    _pendingCallOutcome = item;
    _callLaunchedAt = DateTime.now();
    await launchUrl(Uri.parse('tel:$number'));
  }

  Future<void> _showOutcomeForPendingCall() async {
    final task = _pendingCallOutcome;
    if (task == null || !mounted) {
      return;
    }
    _showingOutcome = true;
    await showOutcomeSheet(context, task: task);
    _pendingCallOutcome = null;
    _callLaunchedAt = null;
    _showingOutcome = false;
  }

  Future<void> _completeTask(TaskListItem item) async {
    HapticFeedback.lightImpact();
    await ref.read(tasksRepositoryProvider).complete(item.task.id);
  }

  Future<void> _postponeTask(TaskListItem item) async {
    final scheduledAt = await showPostponeSheet(
      context,
      initialDate: item.task.scheduledAt,
    );
    if (scheduledAt != null) {
      await ref.read(tasksRepositoryProvider).postpone(
            item.task.id,
            scheduledAt,
          );
    }
  }

  List<DealListItem> _paymentDueDeals(
      List<DealListItem> deals, DateTime today) {
    final end = today.add(const Duration(days: 1));
    return deals.where((item) {
      final due = item.deal.paymentDue;
      return due != null &&
          due.toLocal().isBefore(end) &&
          item.pendingPaise > 0 &&
          item.status != DealStatusValue.paid;
    }).toList();
  }

  List<DealListItem> _deliveryDueDeals(
      List<DealListItem> deals, DateTime today) {
    final end = today.add(const Duration(days: 1));
    return deals.where((item) {
      final due = item.deal.deliveryDate;
      return due != null &&
          due.toLocal().isBefore(end) &&
          item.status != DealStatusValue.delivered &&
          item.status != DealStatusValue.paid;
    }).toList();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String _dateHeader(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.pendingPaise,
    required this.calls,
    required this.deliveries,
  });

  final int pendingPaise;
  final int calls;
  final int deliveries;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'to collect',
            child: AmountDisplay(
              amountPaise: pendingPaise,
              tone: AmountDisplayTone.received,
              size: AmountDisplaySize.small,
            ),
          ),
        ),
        const SizedBox(width: KajuSpacing.sm),
        Expanded(child: _StatChip(label: 'calls', text: '$calls planned')),
        const SizedBox(width: KajuSpacing.sm),
        Expanded(
            child: _StatChip(label: 'deliveries', text: '$deliveries due')),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    this.text,
    this.child,
  });

  final String label;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return KajuCard(
      padding: const EdgeInsets.all(KajuSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child ??
              Text(
                text ?? '',
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          const SizedBox(height: KajuSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _TodayLoading extends StatelessWidget {
  const _TodayLoading();

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

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.items,
    required this.onCall,
    required this.onDone,
    required this.onPostpone,
    required this.onTap,
  });

  final String title;
  final List<TaskListItem> items;
  final ValueChanged<TaskListItem> onCall;
  final ValueChanged<TaskListItem> onDone;
  final ValueChanged<TaskListItem> onPostpone;
  final ValueChanged<TaskListItem> onTap;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: Column(
            key: ValueKey(
              'today-task-section-$title-${items.map((item) => item.task.id).join('|')}',
            ),
            children: [
              for (final item in items) ...[
                Dismissible(
                  key: Key('today-task-${item.task.id}'),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  onDismissed: (_) {
                    HapticFeedback.mediumImpact();
                    final container = ProviderScope.containerOf(context);
                    final repository = container.read(tasksRepositoryProvider);
                    unawaited(repository.softDelete(item.task.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.task.title} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () =>
                              unawaited(repository.restore(item.task)),
                        ),
                      ),
                    );
                  },
                  child: _AnimatedTaskEntry(
                    child: TaskCard(
                      item: item,
                      onCall: () => onCall(item),
                      onDone: () => onDone(item),
                      onPostpone: () => onPostpone(item),
                      onTap: () => onTap(item),
                    ),
                  ),
                ),
                const SizedBox(height: KajuSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedTaskEntry extends StatelessWidget {
  const _AnimatedTaskEntry({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

enum _DealDueMode { payment, delivery }

class _DealDueSection extends StatelessWidget {
  const _DealDueSection({
    required this.title,
    required this.items,
    required this.mode,
  });

  final String title;
  final List<DealListItem> items;
  final _DealDueMode mode;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      children: [
        for (final item in items) ...[
          _DealDueCard(item: item, mode: mode),
          const SizedBox(height: KajuSpacing.md),
        ],
      ],
    );
  }
}

class _DealDueCard extends StatelessWidget {
  const _DealDueCard({required this.item, required this.mode});

  final DealListItem item;
  final _DealDueMode mode;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final isPayment = mode == _DealDueMode.payment;

    return KajuCard(
      onTap: () => showDealSheet(context, item: item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonAvatar(name: item.party.name),
          const SizedBox(width: KajuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.party.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: KajuSpacing.xs),
                Text(
                  '${item.gradeSummary} - ${item.quantitySummary}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                const SizedBox(height: KajuSpacing.sm),
                isPayment
                    ? AmountDisplay(
                        amountPaise: item.pendingPaise,
                        tone: AmountDisplayTone.overdue,
                        size: AmountDisplaySize.small,
                      )
                    : Text(
                        'Delivery due ${formatKajuDate(item.deal.deliveryDate!.toLocal())}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PersonProfileScreen(
                    partyId: item.party.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'Open person',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: KajuSpacing.md),
        ...children,
        const SizedBox(height: KajuSpacing.sm),
      ],
    );
  }
}

class _TomorrowPreview extends StatelessWidget {
  const _TomorrowPreview({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return KajuCard(
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_right_outlined),
          const SizedBox(width: KajuSpacing.sm),
          Expanded(
            child: Text(
              'Tomorrow has $count planned ${count == 1 ? 'task' : 'tasks'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.dangerMuted,
        borderRadius: BorderRadius.circular(KajuRadius.lg),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: KajuSpacing.lg),
          child: Icon(Icons.delete_outline, color: colors.danger),
        ),
      ),
    );
  }
}
