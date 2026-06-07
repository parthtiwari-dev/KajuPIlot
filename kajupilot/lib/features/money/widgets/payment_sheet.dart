import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/amount_display.dart';
import '../../../shared/widgets/kaju_bottom_sheet.dart';
import '../../people/data/parties_repository.dart';
import '../../people/data/party_models.dart';
import '../data/money_models.dart';
import '../data/payments_repository.dart';

Future<void> showPaymentSheet(BuildContext context, {PaymentListItem? item}) {
  return showKajuBottomSheet<void>(
    context: context,
    builder: (_) => PaymentSheet(item: item),
  );
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({super.key, this.item});

  final PaymentListItem? item;

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partyController;
  late final TextEditingController _amountController;
  late final TextEditingController _methodController;
  late final TextEditingController _notesController;
  late final Future<List<Party>> _partiesFuture;
  late PaymentTypeValue _type;
  String? _selectedPartyId;
  String? _selectedDealId;
  DateTime _paymentDate = DateTime.now();
  var _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final payment = item?.payment;
    _partiesFuture = ref.read(paymentsRepositoryProvider).localParties();
    _selectedPartyId = payment?.partyId;
    _selectedDealId = payment?.dealId;
    _type = payment == null
        ? PaymentTypeValue.received
        : PaymentTypeValue.fromApi(payment.type);
    _paymentDate = payment?.paymentDate ?? DateTime.now();
    _partyController = TextEditingController(text: item?.party.name ?? '');
    _amountController = TextEditingController(
      text: payment == null
          ? ''
          : paiseToDecimalRupeesString(payment.amountPaise)
              .replaceFirst(RegExp(r'\.00$'), ''),
    );
    _methodController = TextEditingController(text: payment?.method ?? '');
    _notesController = TextEditingController(text: payment?.notes ?? '');
  }

  @override
  void dispose() {
    _partyController.dispose();
    _amountController.dispose();
    _methodController.dispose();
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
                          _isEdit ? 'Edit payment' : 'Add payment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (_isEdit)
                        IconButton(
                          key: const Key('payment-delete-button'),
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete payment',
                        ),
                    ],
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  SegmentedButton<PaymentTypeValue>(
                    segments: [
                      for (final type in PaymentTypeValue.values)
                        ButtonSegment(value: type, label: Text(type.label)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _type = selection.single;
                        _selectedDealId = null;
                      });
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
                        _selectedDealId = null;
                      });
                    },
                    onTextChanged: () => setState(() {
                      _selectedPartyId = null;
                      _selectedDealId = null;
                    }),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  _DealSelector(
                    partyId: _selectedPartyId,
                    selectedDealId: _selectedDealId,
                    type: _type,
                    selectedDeal: widget.item?.deal,
                    onSelected: (dealId) => setState(() {
                      _selectedDealId = dealId;
                    }),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('payment-amount-field'),
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
                  TextFormField(
                    key: const Key('payment-method-field'),
                    controller: _methodController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      hintText: 'Cash, UPI, bank transfer...',
                    ),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(formatKajuDate(_paymentDate)),
                  ),
                  const SizedBox(height: KajuSpacing.md),
                  TextFormField(
                    key: const Key('payment-notes-field'),
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: KajuSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('payment-save-button'),
                      onPressed: _isSaving ? null : _save,
                      child: Text(_isSaving ? 'Saving...' : 'Save payment'),
                    ),
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
    try {
      final partyId = await _resolvePartyId();
      final amountPaise = moneyTextToPaise(_amountController.text);
      final repository = ref.read(paymentsRepositoryProvider);

      if (_isEdit) {
        await repository.update(
          widget.item!.payment.id,
          UpdatePaymentInput(
            partyId: partyId,
            dealId: _selectedDealId,
            type: _type,
            amountPaise: amountPaise,
            method: _methodController.text,
            paymentDate: _paymentDate,
            notes: _notesController.text,
          ),
        );
      } else {
        await repository.create(
          CreatePaymentInput(
            partyId: partyId,
            dealId: _selectedDealId,
            type: _type,
            amountPaise: amountPaise,
            method: _methodController.text,
            paymentDate: _paymentDate,
            notes: _notesController.text,
          ),
        );
      }

      ref.invalidate(partyStatsProvider(partyId));
      ref.invalidate(partyLedgerProvider(partyId));
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
            type: _type == PaymentTypeValue.received
                ? PartyTypeValue.customer
                : PartyTypeValue.supplier,
          ),
        );

    return party.id;
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) {
      return;
    }

    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(paymentsRepositoryProvider);
    final deleted = await repository.softDelete(item.payment.id);
    if (!mounted || deleted == null) {
      return;
    }

    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.party.name} payment deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(item.payment),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null) {
      setState(() => _paymentDate = selected);
    }
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
              key: const Key('payment-party-field'),
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

class _DealSelector extends ConsumerWidget {
  const _DealSelector({
    required this.partyId,
    required this.selectedDealId,
    required this.type,
    required this.selectedDeal,
    required this.onSelected,
  });

  final String? partyId;
  final String? selectedDealId;
  final PaymentTypeValue type;
  final PaymentDealSummary? selectedDeal;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (partyId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<PaymentDealOption>>(
      future: ref.read(paymentsRepositoryProvider).localDealOptions(
            partyId: partyId!,
            type: type,
          ),
      builder: (context, snapshot) {
        final options = snapshot.data ?? const <PaymentDealOption>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link to deal', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: KajuSpacing.sm),
            Wrap(
              spacing: KajuSpacing.sm,
              runSpacing: KajuSpacing.xs,
              children: [
                ChoiceChip(
                  label: const Text('Party credit'),
                  selected: selectedDealId == null,
                  onSelected: (_) => onSelected(null),
                ),
                if (selectedDeal != null &&
                    selectedDealId == selectedDeal!.id &&
                    !options.any((deal) => deal.id == selectedDeal!.id))
                  ChoiceChip(
                    label: Text(selectedDeal!.cashewGrade),
                    selected: true,
                    onSelected: (_) => onSelected(selectedDeal!.id),
                  ),
                for (final deal in options)
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(deal.label),
                        const SizedBox(width: KajuSpacing.xs),
                        AmountDisplay(
                          amountPaise: deal.pendingPaise,
                          size: AmountDisplaySize.small,
                          tone: AmountDisplayTone.pending,
                        ),
                      ],
                    ),
                    selected: selectedDealId == deal.id,
                    onSelected: (_) => onSelected(deal.id),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
