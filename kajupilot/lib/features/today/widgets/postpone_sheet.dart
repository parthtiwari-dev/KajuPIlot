import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

Future<DateTime?> showPostponeSheet(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (_) => PostponeSheet(initialDate: initialDate),
  );
}

class PostponeSheet extends StatefulWidget {
  const PostponeSheet({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<PostponeSheet> createState() => _PostponeSheetState();
}

class _PostponeSheetState extends State<PostponeSheet> {
  late DateTime _scheduledAt;

  @override
  void initState() {
    super.initState();
    _scheduledAt = widget.initialDate.toLocal().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(KajuSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Postpone task',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: KajuSpacing.lg),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.event_outlined),
              label: Text(_dateTimeLabel(_scheduledAt)),
            ),
            const SizedBox(height: KajuSpacing.lg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_scheduledAt),
              icon: const Icon(Icons.schedule_outlined),
              label: const Text('Postpone'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
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

  String _dateTimeLabel(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} ${value.hour}:$minute';
  }
}
