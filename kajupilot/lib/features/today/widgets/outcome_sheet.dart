import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../shared/widgets/kaju_bottom_sheet.dart';
import '../../../shared/widgets/kaju_button_spinner.dart';
import '../data/call_logs_repository.dart';
import '../data/today_models.dart';

Future<void> showOutcomeSheet(
  BuildContext context, {
  required TaskListItem task,
}) {
  return showKajuBottomSheet<void>(
    context: context,
    builder: (_) => OutcomeSheet(task: task),
  );
}

class OutcomeSheet extends ConsumerStatefulWidget {
  const OutcomeSheet({super.key, required this.task});

  final TaskListItem task;

  @override
  ConsumerState<OutcomeSheet> createState() => _OutcomeSheetState();
}

class _OutcomeSheetState extends ConsumerState<OutcomeSheet> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  CallOutcomeValue _outcome = CallOutcomeValue.noAnswer;
  DateTime? _promisedDate;
  var _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final name = widget.task.party?.name ?? widget.task.task.title;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KajuSpacing.lg,
          KajuSpacing.lg,
          KajuSpacing.lg,
          bottom + KajuSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How did it go with $name?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: KajuSpacing.lg),
              Wrap(
                spacing: KajuSpacing.sm,
                runSpacing: KajuSpacing.sm,
                children: [
                  for (final outcome in CallOutcomeValue.values)
                    ChoiceChip(
                      selected: _outcome == outcome,
                      label: Text(outcome.label),
                      onSelected: (_) => setState(() => _outcome = outcome),
                    ),
                ],
              ),
              if (_outcome == CallOutcomeValue.paymentPromised) ...[
                const SizedBox(height: KajuSpacing.md),
                OutlinedButton.icon(
                  onPressed: _pickPromisedDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    _promisedDate == null
                        ? 'Pick promised date'
                        : '${_promisedDate!.day}/${_promisedDate!.month}/${_promisedDate!.year}',
                  ),
                ),
                const SizedBox(height: KajuSpacing.md),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Promised amount optional',
                    prefixText: '₹',
                  ),
                ),
              ],
              const SizedBox(height: KajuSpacing.md),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Add note'),
              ),
              const SizedBox(height: KajuSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const KajuButtonSpinner()
                      : const Icon(Icons.check_outlined),
                  label: const Text('Save outcome'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPromisedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _promisedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _promisedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_outcome == CallOutcomeValue.paymentPromised && _promisedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick the promised date first')),
      );
      return;
    }

    setState(() => _saving = true);
    final notes = _noteController.text.trim();
    final amount = _amountController.text.trim();
    await ref.read(callLogsRepositoryProvider).create(
          CreateCallLogInput(
            taskId: widget.task.task.id,
            partyId: widget.task.task.partyId,
            outcome: _outcome,
            notes: notes.isEmpty ? null : notes,
            promisedDate: _promisedDate,
            promisedAmountPaise:
                amount.isEmpty ? null : decimalRupeesToPaise(amount),
          ),
        );

    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }
}
