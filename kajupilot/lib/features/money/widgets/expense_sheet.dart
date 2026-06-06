import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/dates.dart';
import '../data/expenses_repository.dart';
import '../data/money_models.dart';

Future<void> showExpenseSheet(BuildContext context, {Expense? expense}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExpenseSheet(expense: expense),
  );
}

class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late ExpenseScopeValue _scope;
  late ExpenseCategoryValue _category;
  DateTime _expenseDate = DateTime.now();
  var _isSaving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _scope = expense == null
        ? ExpenseScopeValue.business
        : ExpenseScopeValue.fromApi(expense.scope);
    _category = expense == null
        ? ExpenseCategoryValue.transport
        : ExpenseCategoryValue.fromApi(expense.category);
    _expenseDate = expense?.expenseDate ?? DateTime.now();
    _amountController = TextEditingController(
      text: expense == null
          ? ''
          : paiseToDecimalRupeesString(expense.amountPaise)
              .replaceFirst(RegExp(r'\.00$'), ''),
    );
    _notesController = TextEditingController(text: expense?.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KajuRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: KajuSpacing.lg,
            right: KajuSpacing.lg,
            top: KajuSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + KajuSpacing.lg,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderMedium,
                        borderRadius: BorderRadius.circular(KajuRadius.full),
                      ),
                    ),
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isEdit ? 'Edit expense' : 'Add expense',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (_isEdit)
                        IconButton(
                          key: const Key('expense-delete-button'),
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete expense',
                        ),
                    ],
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  SegmentedButton<ExpenseScopeValue>(
                    key: const Key('expense-scope-field'),
                    segments: [
                      for (final scope in ExpenseScopeValue.values)
                        ButtonSegment(value: scope, label: Text(scope.label)),
                    ],
                    selected: {_scope},
                    onSelectionChanged: (selection) {
                      setState(() => _scope = selection.single);
                    },
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  DropdownButtonFormField<ExpenseCategoryValue>(
                    key: const Key('expense-category-field'),
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final category in ExpenseCategoryValue.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('expense-amount-field'),
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                    ),
                    validator: (value) {
                      if (moneyTextToPaise(value ?? '') <= 0) {
                        return 'Enter amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(formatKajuDate(_expenseDate)),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('expense-notes-field'),
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  FilledButton(
                    key: const Key('expense-save-button'),
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save expense'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(expensesRepositoryProvider);
    final amountPaise = moneyTextToPaise(_amountController.text);

    try {
      if (_isEdit) {
        await repository.update(
          widget.expense!.id,
          UpdateExpenseInput(
            scope: _scope,
            category: _category,
            amountPaise: amountPaise,
            expenseDate: _expenseDate,
            notes: _notesController.text,
          ),
        );
      } else {
        await repository.create(
          CreateExpenseInput(
            scope: _scope,
            category: _category,
            amountPaise: amountPaise,
            expenseDate: _expenseDate,
            notes: _notesController.text,
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    final expense = widget.expense;
    if (expense == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(expensesRepositoryProvider);
    final deleted = await repository.softDelete(expense.id);
    if (!mounted || deleted == null) {
      return;
    }

    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            '${ExpenseCategoryValue.fromApi(expense.category).label} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(expense),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null) {
      setState(() => _expenseDate = selected);
    }
  }
}
