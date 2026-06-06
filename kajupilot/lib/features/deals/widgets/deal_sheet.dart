import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../people/data/parties_repository.dart';
import '../../people/data/party_models.dart';
import '../data/deal_models.dart';
import '../data/deals_repository.dart';

Future<void> showDealSheet(BuildContext context, {DealListItem? item}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DealSheet(item: item),
  );
}

class DealSheet extends ConsumerStatefulWidget {
  const DealSheet({super.key, this.item});

  final DealListItem? item;

  @override
  ConsumerState<DealSheet> createState() => _DealSheetState();
}

class _DealSheetState extends ConsumerState<DealSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partyController;
  late final TextEditingController _paidController;
  late final TextEditingController _notesController;
  late final Future<List<Party>> _partiesFuture;
  final _lines = <_DealLineControllers>[];
  String? _selectedPartyId;
  late DealTypeValue _type;
  DateTime? _deliveryDate;
  DateTime? _paymentDue;
  var _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final deal = item?.deal;
    _partiesFuture = ref.read(dealsRepositoryProvider).localParties();
    _selectedPartyId = deal?.partyId;
    _partyController = TextEditingController(text: item?.party.name ?? '');
    _type =
        deal == null ? DealTypeValue.sale : DealTypeValue.fromApi(deal.type);
    _deliveryDate = deal?.deliveryDate;
    _paymentDue = deal?.paymentDue;
    _paidController = TextEditingController(
      text: deal == null || deal.paidPaise == 0
          ? ''
          : _moneyInput(deal.paidPaise),
    );
    _notesController = TextEditingController(text: deal?.notes ?? '');
    final rows = <DealLineInput?>[];
    if (item == null) {
      rows.add(null);
    } else if (item.items.isEmpty) {
      rows.add(
        DealLineInput(
          grade: item.deal.cashewGrade,
          quantityText: 'Bucket-wise',
          lineTotalPaise: item.deal.totalPaise,
        ),
      );
    } else {
      rows.addAll(
        item.items.map(
          (line) => DealLineInput(
            id: line.id,
            grade: line.grade,
            quantityText: line.quantityText,
            rateText: line.rateText,
            lineTotalPaise: line.lineTotalPaise,
          ),
        ),
      );
    }

    for (final row in rows) {
      _lines.add(_DealLineControllers.fromInput(row, onChanged: _recalculate));
    }
    _paidController.addListener(_recalculate);
  }

  @override
  void dispose() {
    _paidController.removeListener(_recalculate);
    _partyController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final deal = widget.item?.deal;
    final currentStatus =
        deal == null ? null : DealStatusValue.fromApi(deal.status);
    final nextStatus = currentStatus?.next;

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
                          _isEdit ? 'Deal detail' : 'Add deal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (_isEdit)
                        IconButton(
                          key: const Key('deal-delete-button'),
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete deal',
                        ),
                    ],
                  ),
                  if (_isEdit && nextStatus != null) ...[
                    const SizedBox(height: KajuSpacing.md),
                    OutlinedButton.icon(
                      key: const Key('deal-next-status-button'),
                      onPressed:
                          _canMoveTo(nextStatus) ? _moveToNextStatus : null,
                      icon: const Icon(Icons.trending_up),
                      label: Text('Mark ${nextStatus.label}'),
                    ),
                  ],
                  const SizedBox(height: KajuSpacing.lg),
                  SegmentedButton<DealTypeValue>(
                    segments: [
                      for (final type in DealTypeValue.values)
                        ButtonSegment(value: type, label: Text(type.label)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() => _type = selection.single);
                    },
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  _PartyTextSelector(
                    partiesFuture: _partiesFuture,
                    controller: _partyController,
                    selectedPartyId: _selectedPartyId,
                    onSelected: (party) {
                      setState(() {
                        _selectedPartyId = party.id;
                        _partyController.text = party.name;
                      });
                    },
                    onTextChanged: () => setState(() {
                      _selectedPartyId = null;
                    }),
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: KajuSpacing.sm),
                  for (var index = 0; index < _lines.length; index += 1) ...[
                    _DealLineEditor(
                      key: Key('deal-line-$index'),
                      line: _lines[index],
                      canRemove: _lines.length > 1,
                      onRemove: () => _removeLine(index),
                    ),
                    const SizedBox(height: KajuSpacing.md),
                  ],
                  OutlinedButton.icon(
                    key: const Key('deal-add-line-button'),
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Add another grade'),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('deal-paid-field'),
                    controller: _paidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_decimalInputFormatter()],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Paid amount',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  _LiveTotal(
                    totalPaise: _totalPaise,
                    paidPaise: _paidPaise,
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isDeliveryDate: true),
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: Text(
                            _deliveryDate == null
                                ? 'Delivery'
                                : formatKajuDate(_deliveryDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: KajuSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isDeliveryDate: false),
                          icon: const Icon(Icons.event_outlined),
                          label: Text(
                            _paymentDue == null
                                ? 'Payment due'
                                : formatKajuDate(_paymentDue!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_deliveryDate != null || _paymentDue != null) ...[
                    const SizedBox(height: KajuSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: KajuSpacing.sm,
                        children: [
                          if (_deliveryDate != null)
                            TextButton.icon(
                              key: const Key('deal-clear-delivery-date-button'),
                              onPressed: () {
                                setState(() => _deliveryDate = null);
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Clear delivery'),
                            ),
                          if (_paymentDue != null)
                            TextButton.icon(
                              key: const Key('deal-clear-payment-due-button'),
                              onPressed: () {
                                setState(() => _paymentDue = null);
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Clear due'),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('deal-notes-field'),
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  FilledButton(
                    key: const Key('deal-save-button'),
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save deal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int get _paidPaise => rupeeTextToPaise(_paidController.text);
  int get _totalPaise => sumLineTotals(_lineInputs());

  void _recalculate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addLine() {
    setState(() {
      _lines.add(_DealLineControllers.fromInput(null, onChanged: _recalculate));
    });
  }

  void _removeLine(int index) {
    final removed = _lines.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_totalPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter total amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(dealsRepositoryProvider);

    try {
      final partyId = await _resolvePartyId();
      final lines = _lineInputs();
      final existingDeal = widget.item?.deal;

      if (_isEdit) {
        await repository.update(
          widget.item!.deal.id,
          UpdateDealInput(
            partyId: partyId,
            type: _type,
            items: lines,
            totalPaise: _totalPaise,
            paidPaise: _paidPaise,
            deliveryDate: _deliveryDate,
            clearDeliveryDate:
                existingDeal?.deliveryDate != null && _deliveryDate == null,
            paymentDue: _paymentDue,
            clearPaymentDue:
                existingDeal?.paymentDue != null && _paymentDue == null,
            notes: _notesController.text,
          ),
        );
      } else {
        await repository.create(
          CreateDealInput(
            partyId: partyId,
            type: _type,
            items: lines,
            totalPaise: _totalPaise,
            paidPaise: _paidPaise,
            status: DealStatusValue.confirmed,
            deliveryDate: _deliveryDate,
            paymentDue: _paymentDue,
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

  Future<String> _resolvePartyId() async {
    if (_selectedPartyId != null) {
      return _selectedPartyId!;
    }

    final name = _partyController.text.trim();
    if (name.isEmpty) {
      throw StateError('Enter a person name');
    }

    final party = await ref.read(partiesRepositoryProvider).create(
          CreatePartyInput(
            name: name,
            type: _type == DealTypeValue.sale
                ? PartyTypeValue.customer
                : PartyTypeValue.supplier,
          ),
        );

    return party.id;
  }

  List<DealLineInput> _lineInputs() {
    return _lines.map((line) => line.toInput()).toList();
  }

  Future<void> _moveToNextStatus() async {
    final deal = widget.item!.deal;
    final next = DealStatusValue.fromApi(deal.status).next;
    if (next == null) {
      return;
    }

    try {
      await ref.read(dealsRepositoryProvider).updateStatus(deal.id, next);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(dealsRepositoryProvider);
    final deleted = await repository.softDelete(item.deal.id);
    if (!mounted || deleted == null) {
      return;
    }

    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.gradeSummary} deal deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(item.deal),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isDeliveryDate}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: isDeliveryDate
          ? (_deliveryDate ?? now)
          : (_paymentDue ?? _deliveryDate ?? now),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isDeliveryDate) {
        _deliveryDate = selected;
      } else {
        _paymentDue = selected;
      }
    });
  }

  bool _canMoveTo(DealStatusValue nextStatus) {
    final deal = widget.item?.deal;
    if (deal == null) {
      return false;
    }
    return nextStatus != DealStatusValue.paid ||
        deal.paidPaise >= deal.totalPaise;
  }

  TextInputFormatter _decimalInputFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));
  }

  String _moneyInput(int paise) {
    return paiseToDecimalRupeesString(paise).replaceFirst(RegExp(r'\.00$'), '');
  }
}

class _PartyTextSelector extends StatelessWidget {
  const _PartyTextSelector({
    required this.partiesFuture,
    required this.controller,
    required this.selectedPartyId,
    required this.onSelected,
    required this.onTextChanged,
  });

  final Future<List<Party>> partiesFuture;
  final TextEditingController controller;
  final String? selectedPartyId;
  final ValueChanged<Party> onSelected;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Party>>(
      future: partiesFuture,
      builder: (context, snapshot) {
        final parties = snapshot.data ?? const <Party>[];
        final search = controller.text.trim().toLowerCase();
        final matches = search.isEmpty
            ? parties.take(5).toList()
            : parties
                .where((party) => party.name.toLowerCase().contains(search))
                .take(5)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const Key('deal-party-field'),
              controller: controller,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Person',
                hintText: 'Type a new or existing name',
                prefixIcon: const Icon(Icons.person_search_outlined),
                suffixIcon: selectedPartyId == null
                    ? const Icon(Icons.add_circle_outline)
                    : const Icon(Icons.check_circle_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a person name';
                }
                return null;
              },
              onChanged: (_) => onTextChanged(),
            ),
            if (matches.isNotEmpty) ...[
              const SizedBox(height: KajuSpacing.sm),
              Wrap(
                spacing: KajuSpacing.sm,
                runSpacing: KajuSpacing.xs,
                children: [
                  for (final party in matches)
                    InputChip(
                      label: Text(party.name),
                      selected: selectedPartyId == party.id,
                      onPressed: () => onSelected(party),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DealLineControllers {
  _DealLineControllers({
    this.id,
    required this.gradeController,
    required this.quantityController,
    required this.rateController,
    required this.totalController,
    required this.onChanged,
  }) {
    totalController.addListener(onChanged);
  }

  factory _DealLineControllers.fromInput(
    DealLineInput? input, {
    required VoidCallback onChanged,
  }) {
    return _DealLineControllers(
      id: input?.id,
      gradeController: TextEditingController(text: input?.grade ?? ''),
      quantityController:
          TextEditingController(text: input?.quantityText ?? ''),
      rateController: TextEditingController(text: input?.rateText ?? ''),
      totalController: TextEditingController(
        text: input == null || input.lineTotalPaise == 0
            ? ''
            : paiseToDecimalRupeesString(input.lineTotalPaise)
                .replaceFirst(RegExp(r'\.00$'), ''),
      ),
      onChanged: onChanged,
    );
  }

  final String? id;
  final TextEditingController gradeController;
  final TextEditingController quantityController;
  final TextEditingController rateController;
  final TextEditingController totalController;
  final VoidCallback onChanged;

  DealLineInput toInput() {
    return DealLineInput(
      id: id,
      grade: gradeController.text,
      quantityText: quantityController.text,
      rateText: rateController.text,
      lineTotalPaise: rupeeTextToPaise(totalController.text),
    );
  }

  void dispose() {
    totalController.removeListener(onChanged);
    gradeController.dispose();
    quantityController.dispose();
    rateController.dispose();
    totalController.dispose();
  }
}

class _DealLineEditor extends StatelessWidget {
  const _DealLineEditor({
    super.key,
    required this.line,
    required this.canRemove,
    required this.onRemove,
  });

  final _DealLineControllers line;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.kajuColors.bgCard,
        border: Border.all(color: context.kajuColors.borderSubtle),
        borderRadius: BorderRadius.circular(KajuRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KajuSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Grade row',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove grade',
                  ),
              ],
            ),
            const SizedBox(height: KajuSpacing.sm),
            TextFormField(
              key: const Key('deal-grade-field'),
              controller: line.gradeController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Grade / item',
                hintText: 'W320, W240, Split...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Grade is required';
                }
                return null;
              },
            ),
            const SizedBox(height: KajuSpacing.md),
            TextFormField(
              key: const Key('deal-quantity-field'),
              controller: line.quantityController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: '10 balti, 2 bucket, half truck...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantity is required';
                }
                return null;
              },
            ),
            const SizedBox(height: KajuSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('deal-rate-field'),
                    controller: line.rateController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      hintText: '780 per balti',
                    ),
                  ),
                ),
                const SizedBox(width: KajuSpacing.md),
                Expanded(
                  child: TextFormField(
                    key: const Key('deal-line-total-field'),
                    controller: line.totalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      prefixText: '₹ ',
                    ),
                    validator: (value) {
                      if (rupeeTextToPaise(value ?? '') <= 0) {
                        return 'Enter total';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTotal extends StatelessWidget {
  const _LiveTotal({
    required this.totalPaise,
    required this.paidPaise,
  });

  final int totalPaise;
  final int paidPaise;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final pendingPaise = totalPaise - paidPaise;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(KajuRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KajuSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _LiveAmount(
                label: 'Total',
                amountPaise: totalPaise,
              ),
            ),
            Expanded(
              child: _LiveAmount(
                label: 'Paid',
                amountPaise: paidPaise,
                tone: AmountDisplayTone.received,
              ),
            ),
            Expanded(
              child: _LiveAmount(
                label: 'Pending',
                amountPaise: pendingPaise,
                tone: pendingPaise > 0
                    ? AmountDisplayTone.pending
                    : AmountDisplayTone.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveAmount extends StatelessWidget {
  const _LiveAmount({
    required this.label,
    required this.amountPaise,
    this.tone = AmountDisplayTone.neutral,
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
