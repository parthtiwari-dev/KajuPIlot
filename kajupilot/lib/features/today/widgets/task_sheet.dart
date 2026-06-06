import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/spacing.dart';
import '../../people/data/parties_repository.dart';
import '../data/tasks_repository.dart';
import '../data/today_models.dart';

Future<void> showTaskSheet(BuildContext context, {TaskListItem? item}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => TaskSheet(item: item),
  );
}

class TaskSheet extends ConsumerStatefulWidget {
  const TaskSheet({super.key, this.item});

  final TaskListItem? item;

  @override
  ConsumerState<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<TaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TaskTypeValue _type = TaskTypeValue.call;
  String? _partyId;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  var _priority = 0;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.item?.task;
    if (task != null) {
      _titleController.text = task.title;
      _notesController.text = task.notes ?? '';
      _type = TaskTypeValue.fromApi(task.type);
      _partyId = task.partyId;
      _scheduledAt = task.scheduledAt.toLocal();
      _priority = task.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KajuSpacing.lg,
          KajuSpacing.lg,
          KajuSpacing.lg,
          bottom + KajuSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: FutureBuilder<List<Party>>(
            future: ref.read(partiesRepositoryProvider).localParties(),
            builder: (context, snapshot) {
              final parties = snapshot.data ?? const <Party>[];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item == null ? 'Add task' : 'Edit task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: KajuSpacing.lg),
                    DropdownButtonFormField<TaskTypeValue>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final type in TaskTypeValue.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    DropdownButtonFormField<String?>(
                      value: _partyId,
                      decoration: const InputDecoration(
                        labelText: 'Person optional',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No person'),
                        ),
                        for (final party in parties)
                          DropdownMenuItem<String?>(
                            value: party.id,
                            child: Text(party.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => _partyId = value),
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      minLines: 2,
                      maxLines: 3,
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDateTime,
                            icon: const Icon(Icons.event_outlined),
                            label: Text(_dateTimeLabel(_scheduledAt)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    Row(
                      children: [
                        Text(
                          'Priority',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        IconButton.outlined(
                          onPressed: _priority == 0
                              ? null
                              : () => setState(() => _priority -= 1),
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KajuSpacing.md,
                          ),
                          child: Text('$_priority'),
                        ),
                        IconButton.outlined(
                          onPressed: _priority == 5
                              ? null
                              : () => setState(() => _priority += 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: KajuSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_outlined),
                        label: const Text('Save task'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _scheduledAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final repository = ref.read(tasksRepositoryProvider);
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final existing = widget.item?.task;
    if (existing == null) {
      await repository.create(
        CreateTaskInput(
          partyId: _partyId,
          type: _type,
          title: title,
          notes: notes.isEmpty ? null : notes,
          scheduledAt: _scheduledAt,
          priority: _priority,
        ),
      );
    } else {
      await repository.update(
        existing.id,
        UpdateTaskInput(
          partyId: _partyId,
          clearParty: _partyId == null && existing.partyId != null,
          type: _type,
          title: title,
          notes: notes.isEmpty ? null : notes,
          clearNotes: notes.isEmpty && existing.notes != null,
          scheduledAt: _scheduledAt,
          priority: _priority,
        ),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _dateTimeLabel(DateTime value) {
    final date = '${value.day}/${value.month}/${value.year}';
    final minute = value.minute.toString().padLeft(2, '0');
    return '$date ${value.hour}:$minute';
  }
}
