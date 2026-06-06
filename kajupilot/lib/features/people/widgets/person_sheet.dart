import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/kaju_colors.dart';
import '../../../core/theme/spacing.dart';
import '../data/parties_repository.dart';
import '../data/party_models.dart';

Future<void> showPersonSheet(BuildContext context, {Party? party}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PersonSheet(party: party),
  );
}

class PersonSheet extends ConsumerStatefulWidget {
  const PersonSheet({super.key, this.party});

  final Party? party;

  @override
  ConsumerState<PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends ConsumerState<PersonSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  late PartyTypeValue _type;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final party = widget.party;
    _nameController = TextEditingController(text: party?.name ?? '');
    _phoneController = TextEditingController(text: party?.phone ?? '');
    _notesController = TextEditingController(text: party?.notes ?? '');
    _type = party == null
        ? PartyTypeValue.customer
        : PartyTypeValue.fromApi(party.type);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                Text(
                  widget.party == null ? 'Add person' : 'Edit person',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: KajuSpacing.lg),
                TextFormField(
                  key: const Key('person-name-field'),
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: KajuSpacing.md),
                TextFormField(
                  key: const Key('person-phone-field'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: KajuSpacing.md),
                SegmentedButton<PartyTypeValue>(
                  segments: [
                    for (final type in PartyTypeValue.values)
                      ButtonSegment(value: type, label: Text(type.label)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() => _type = selection.single);
                  },
                ),
                const SizedBox(height: KajuSpacing.md),
                TextFormField(
                  key: const Key('person-notes-field'),
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: KajuSpacing.lg),
                FilledButton(
                  key: const Key('person-save-button'),
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save'),
                ),
              ],
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
    final repository = ref.read(partiesRepositoryProvider);
    final input = UpdatePartyInput(
      name: _nameController.text,
      phone: _phoneController.text,
      type: _type,
      notes: _notesController.text,
    );

    if (widget.party == null) {
      await repository.create(
        CreatePartyInput(
          name: input.name!,
          phone: input.phone,
          type: _type,
          notes: input.notes,
        ),
      );
    } else {
      await repository.update(widget.party!.id, input);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
