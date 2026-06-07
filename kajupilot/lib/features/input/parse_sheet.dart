import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/dates.dart';
import '../../features/deals/widgets/deal_sheet.dart';
import '../../features/money/widgets/expense_sheet.dart';
import '../../features/money/widgets/payment_sheet.dart';
import '../../features/today/widgets/task_sheet.dart';
import '../../shared/widgets/kaju_bottom_sheet.dart';
import '../../shared/widgets/kaju_button_spinner.dart';
import '../../shared/widgets/kaju_card.dart';
import '../../shared/widgets/kaju_empty_state.dart';
import '../../shared/widgets/kaju_skeleton.dart';
import '../../shared/widgets/status_badge.dart';
import 'ai_parse_models.dart';
import 'ai_parser_repository.dart';

Future<void> showParseSheet(BuildContext context) {
  return showKajuBottomSheet<void>(
    context: context,
    builder: (_) => const ParseSheet(),
  );
}

class ParseSheet extends ConsumerStatefulWidget {
  const ParseSheet({super.key});

  @override
  ConsumerState<ParseSheet> createState() => _ParseSheetState();
}

class _ParseSheetState extends ConsumerState<ParseSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _logId;
  List<AiPreviewItem> _items = const [];
  String? _error;
  var _isParsing = false;
  var _isConfirming = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KajuRadius.sheet),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            KajuSpacing.lg,
            KajuSpacing.sm,
            KajuSpacing.lg,
            bottom + KajuSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(child: _header(context)),
                SliverToBoxAdapter(child: _input(context)),
                SliverToBoxAdapter(child: _manualShortcuts(context)),
                if (_error != null)
                  SliverToBoxAdapter(child: _errorState(context, _error!)),
                if (_isParsing)
                  const SliverToBoxAdapter(child: _LoadingPreview()),
                if (!_isParsing && _items.isNotEmpty)
                  SliverList.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KajuSpacing.md),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _PreviewItemCard(
                        key: ValueKey(item.tempId),
                        item: item,
                        onChanged: (updated) => _replaceItem(index, updated),
                        onRemove: () => _removeItem(index),
                      );
                    },
                  ),
                if (!_isParsing && _items.isEmpty && _error == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: KajuSpacing.md),
                      child: KajuEmptyState(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Type one business note',
                        body:
                            'AI will turn it into tasks, deals, payments, or expenses for review.',
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: _confirmButton(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's happening?",
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KajuSpacing.xs),
        Text(
          'Type or use Gboard voice. Nothing is saved until you confirm.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: KajuSpacing.md),
      ],
    );
  }

  Widget _input(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('ai-parse-input'),
          controller: _controller,
          focusNode: _focusNode,
          minLines: 4,
          maxLines: 8,
          autofocus: true,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Kal Amit ko 80k ke liye call, Ramesh se 50k mila...',
            suffixIcon: IconButton(
              key: const Key('ai-parse-mic-button'),
              onPressed: () => _focusNode.requestFocus(),
              icon: const Icon(Icons.mic_none_outlined),
              tooltip: 'Voice input',
            ),
          ),
          onChanged: (_) {
            setState(() => _error = null);
          },
        ),
        const SizedBox(height: KajuSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('ai-parse-button'),
            onPressed:
                _isParsing || _controller.text.trim().isEmpty ? null : _parse,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: Text(_isParsing ? 'Parsing...' : 'Parse'),
          ),
        ),
      ],
    );
  }

  Widget _manualShortcuts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KajuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OR ADD MANUALLY',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: KajuSpacing.sm),
          Wrap(
            spacing: KajuSpacing.sm,
            runSpacing: KajuSpacing.sm,
            children: [
              _ShortcutButton(
                label: 'Sale',
                icon: Icons.handshake_outlined,
                onPressed: () => showDealSheet(context),
              ),
              _ShortcutButton(
                label: 'Payment',
                icon: Icons.payments_outlined,
                onPressed: () => showPaymentSheet(context),
              ),
              _ShortcutButton(
                label: 'Expense',
                icon: Icons.receipt_long_outlined,
                onPressed: () => showExpenseSheet(context),
              ),
              _ShortcutButton(
                label: 'Call',
                icon: Icons.call_outlined,
                onPressed: () => showTaskSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, String error) {
    final colors = context.kajuColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: KajuSpacing.md),
      child: Text(
        error,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.danger,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context) {
    final invalidCount =
        _items.where((item) => item.validated().needsReview).length;
    final canConfirm = _logId != null &&
        _items.isNotEmpty &&
        invalidCount == 0 &&
        !_isConfirming &&
        !_isParsing;

    return Padding(
      padding: const EdgeInsets.only(top: KajuSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('ai-confirm-button'),
          onPressed: canConfirm ? _confirm : null,
          icon: _isConfirming
              ? const KajuButtonSpinner()
              : const Icon(Icons.check_outlined),
          label: Text(
            invalidCount == 0
                ? 'Confirm All'
                : 'Resolve $invalidCount item${invalidCount == 1 ? '' : 's'}',
          ),
        ),
      ),
    );
  }

  Future<void> _parse() async {
    setState(() {
      _isParsing = true;
      _error = null;
      _items = const [];
      _logId = null;
    });

    try {
      final result =
          await ref.read(aiParserRepositoryProvider).parse(_controller.text);
      setState(() {
        _logId = result.logId;
        _items = result.items;
        if (result.items.isEmpty) {
          _error = "Couldn't find anything to add. Use manual shortcuts below.";
        }
      });
    } catch (error) {
      setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) {
        setState(() => _isParsing = false);
      }
    }
  }

  Future<void> _confirm() async {
    final logId = _logId;
    if (logId == null) {
      return;
    }

    setState(() {
      _isConfirming = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final count = await ref
          .read(aiParserRepositoryProvider)
          .confirm(logId: logId, items: _items);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      router.go('/today');
      messenger.showSnackBar(
        SnackBar(content: Text('$count item${count == 1 ? '' : 's'} added')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = _messageFor(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  void _replaceItem(int index, AiPreviewItem item) {
    final next = [..._items];
    next[index] = item.validated();
    setState(() => _items = next);
  }

  void _removeItem(int index) {
    final next = [..._items]..removeAt(index);
    setState(() => _items = next);
  }

  String _messageFor(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      if (statusCode == 401 || statusCode == 403) {
        return 'Setup token expired. Clear app data and run setup again.';
      }
      if (data is Map && data['error'] == 'rate_limited') {
        return 'AI limit reached for this hour. Add manually for now.';
      }
      if (data is Map && data['error'] == 'parse_failed') {
        return "Couldn't parse this safely. Try shorter text or add manually.";
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Backend unreachable. Check Docker is running and USB reverse is active.';
      }
      return 'AI request failed. Check backend/API key and try again.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}

class _PreviewItemCard extends StatefulWidget {
  const _PreviewItemCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final AiPreviewItem item;
  final ValueChanged<AiPreviewItem> onChanged;
  final VoidCallback onRemove;

  @override
  State<_PreviewItemCard> createState() => _PreviewItemCardState();
}

class _PreviewItemCardState extends State<_PreviewItemCard> {
  var _editing = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item.validated();
    final colors = context.kajuColors;

    return KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(item.kind), color: colors.accent),
              const SizedBox(width: KajuSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.partyName?.trim().isNotEmpty == true
                          ? item.partyName!
                          : item.kind.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: KajuSpacing.xs),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: item.needsReview ? 'Review' : item.kind.label,
                tone: item.needsReview
                    ? StatusBadgeTone.warning
                    : StatusBadgeTone.info,
              ),
            ],
          ),
          if (item.partyMatch?.status == 'new') ...[
            const SizedBox(height: KajuSpacing.sm),
            Text(
              'New contact will be created',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (item.warnings.isNotEmpty) ...[
            const SizedBox(height: KajuSpacing.sm),
            for (final warning in item.warnings)
              Text(
                warning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.danger,
                    ),
              ),
          ],
          const SizedBox(height: KajuSpacing.sm),
          Wrap(
            spacing: KajuSpacing.sm,
            runSpacing: KajuSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _editing = !_editing),
                icon: Icon(_editing ? Icons.expand_less : Icons.edit_outlined),
                label: Text(_editing ? 'Done editing' : 'Edit'),
              ),
              IconButton.outlined(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
              ),
            ],
          ),
          if (_editing) ...[
            const SizedBox(height: KajuSpacing.md),
            _InlineEditor(item: item, onChanged: widget.onChanged),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(AiPreviewKind kind) {
    return switch (kind) {
      AiPreviewKind.task => Icons.task_alt_outlined,
      AiPreviewKind.deal => Icons.handshake_outlined,
      AiPreviewKind.payment => Icons.payments_outlined,
      AiPreviewKind.expense => Icons.receipt_long_outlined,
    };
  }
}

class _InlineEditor extends StatelessWidget {
  const _InlineEditor({required this.item, required this.onChanged});

  final AiPreviewItem item;
  final ValueChanged<AiPreviewItem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (item.kind != AiPreviewKind.expense) ...[
          TextFormField(
            initialValue: item.partyName,
            decoration: const InputDecoration(labelText: 'Person'),
            onChanged: (value) => onChanged(item.copyWith(partyName: value)),
          ),
          const SizedBox(height: KajuSpacing.sm),
        ],
        if (item.kind == AiPreviewKind.task) _taskEditor(context),
        if (item.kind == AiPreviewKind.deal) _dealEditor(context),
        if (item.kind == AiPreviewKind.payment) _paymentEditor(context),
        if (item.kind == AiPreviewKind.expense) _expenseEditor(context),
        const SizedBox(height: KajuSpacing.sm),
        TextFormField(
          initialValue: item.notes,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Notes'),
          onChanged: (value) => onChanged(item.copyWith(notes: value)),
        ),
      ],
    );
  }

  Widget _taskEditor(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: item.type ?? 'CALL',
          decoration: const InputDecoration(labelText: 'Task type'),
          items: const [
            DropdownMenuItem(value: 'CALL', child: Text('Call')),
            DropdownMenuItem(
                value: 'PAYMENT_COLLECTION', child: Text('Payment')),
            DropdownMenuItem(value: 'DELIVERY', child: Text('Delivery')),
            DropdownMenuItem(value: 'REMINDER', child: Text('Reminder')),
            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          onChanged: (value) => onChanged(item.copyWith(type: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        TextFormField(
          initialValue: item.title,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (value) => onChanged(item.copyWith(title: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        _DateButton(
          label: item.scheduledAt == null
              ? 'Pick schedule'
              : _dateTimeLabel(item.scheduledAt!),
          onPressed: () async {
            final picked = await _pickDateTime(context, item.scheduledAt);
            if (picked != null) onChanged(item.copyWith(scheduledAt: picked));
          },
        ),
      ],
    );
  }

  Widget _dealEditor(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: item.type ?? 'SALE',
          decoration: const InputDecoration(labelText: 'Deal type'),
          items: const [
            DropdownMenuItem(value: 'SALE', child: Text('Sale')),
            DropdownMenuItem(value: 'PURCHASE', child: Text('Purchase')),
          ],
          onChanged: (value) => onChanged(item.copyWith(type: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        for (var index = 0; index < item.items.length; index++) ...[
          _DealLineEditor(
            line: item.items[index],
            onChanged: (line) {
              final lines = [...item.items]..[index] = line;
              final total = lines.fold(0, (sum, row) => sum + row.totalPaise);
              onChanged(item.copyWith(items: lines, totalPaise: total));
            },
            onRemove: () {
              final lines = [...item.items]..removeAt(index);
              final total = lines.fold(0, (sum, row) => sum + row.totalPaise);
              onChanged(item.copyWith(items: lines, totalPaise: total));
            },
          ),
          const SizedBox(height: KajuSpacing.sm),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final lines = [
                ...item.items,
                const AiDealLinePreview(
                  grade: '',
                  quantityText: '',
                  totalPaise: 0,
                ),
              ];
              onChanged(item.copyWith(items: lines));
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        ),
        const SizedBox(height: KajuSpacing.sm),
        TextFormField(
          initialValue: paiseToDecimalRupeesString(item.paidPaise)
              .replaceFirst(RegExp(r'\.00$'), ''),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Paid amount'),
          onChanged: (value) =>
              onChanged(item.copyWith(paidPaise: decimalRupeesToPaise(value))),
        ),
      ],
    );
  }

  Widget _paymentEditor(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: item.type ?? 'RECEIVED',
          decoration: const InputDecoration(labelText: 'Payment type'),
          items: const [
            DropdownMenuItem(value: 'RECEIVED', child: Text('Received')),
            DropdownMenuItem(value: 'PAID', child: Text('Paid')),
          ],
          onChanged: (value) => onChanged(item.copyWith(type: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        _amountField(
          label: 'Amount',
          value: item.amountPaise,
          onChanged: (value) => onChanged(item.copyWith(amountPaise: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        TextFormField(
          initialValue: item.method,
          decoration: const InputDecoration(labelText: 'Method'),
          onChanged: (value) => onChanged(item.copyWith(method: value)),
        ),
      ],
    );
  }

  Widget _expenseEditor(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: item.scope ?? 'BUSINESS',
          decoration: const InputDecoration(labelText: 'Scope'),
          items: const [
            DropdownMenuItem(value: 'BUSINESS', child: Text('Business')),
            DropdownMenuItem(value: 'PERSONAL', child: Text('Personal')),
          ],
          onChanged: (value) => onChanged(item.copyWith(scope: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        DropdownButtonFormField<String>(
          value: item.category ?? 'OTHER',
          decoration: const InputDecoration(labelText: 'Category'),
          items: const [
            DropdownMenuItem(value: 'TRANSPORT', child: Text('Transport')),
            DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
            DropdownMenuItem(value: 'PACKAGING', child: Text('Packaging')),
            DropdownMenuItem(value: 'BROKER_COMMISSION', child: Text('Broker')),
            DropdownMenuItem(value: 'STOCK_PURCHASE', child: Text('Stock')),
            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          onChanged: (value) => onChanged(item.copyWith(category: value)),
        ),
        const SizedBox(height: KajuSpacing.sm),
        _amountField(
          label: 'Amount',
          value: item.amountPaise,
          onChanged: (value) => onChanged(item.copyWith(amountPaise: value)),
        ),
      ],
    );
  }

  Widget _amountField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return TextFormField(
      initialValue: value == 0
          ? ''
          : paiseToDecimalRupeesString(value)
              .replaceFirst(RegExp(r'\.00$'), ''),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, prefixText: '₹'),
      onChanged: (value) => onChanged(decimalRupeesToPaise(value)),
    );
  }
}

class _DealLineEditor extends StatelessWidget {
  const _DealLineEditor({
    required this.line,
    required this.onChanged,
    required this.onRemove,
  });

  final AiDealLinePreview line;
  final ValueChanged<AiDealLinePreview> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.kajuColors.borderSubtle),
        borderRadius: BorderRadius.circular(KajuRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KajuSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: line.grade,
                    decoration: const InputDecoration(labelText: 'Grade'),
                    onChanged: (value) =>
                        onChanged(line.copyWith(grade: value)),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove item',
                ),
              ],
            ),
            const SizedBox(height: KajuSpacing.sm),
            TextFormField(
              initialValue: line.quantityText,
              decoration: const InputDecoration(labelText: 'Quantity'),
              onChanged: (value) =>
                  onChanged(line.copyWith(quantityText: value)),
            ),
            const SizedBox(height: KajuSpacing.sm),
            TextFormField(
              initialValue: line.rateText,
              decoration: const InputDecoration(labelText: 'Rate text'),
              onChanged: (value) => onChanged(line.copyWith(rateText: value)),
            ),
            const SizedBox(height: KajuSpacing.sm),
            TextFormField(
              initialValue: line.totalPaise == 0
                  ? ''
                  : paiseToDecimalRupeesString(line.totalPaise)
                      .replaceFirst(RegExp(r'\.00$'), ''),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Line total',
                prefixText: '₹',
              ),
              onChanged: (value) => onChanged(
                line.copyWith(totalPaise: decimalRupeesToPaise(value)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.event_outlined),
        label: Text(label),
      ),
    );
  }
}

class _LoadingPreview extends StatelessWidget {
  const _LoadingPreview();

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

Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
  final now = DateTime.now();
  final seed = initial ?? now.add(const Duration(hours: 1));
  final date = await showDatePicker(
    context: context,
    initialDate: seed,
    firstDate: now.subtract(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(seed),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String _dateTimeLabel(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${formatKajuDate(value)} $hour:$minute $suffix';
}
