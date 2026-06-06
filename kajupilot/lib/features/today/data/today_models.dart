import '../../../core/db/app_database.dart';
import '../../../core/utils/currency.dart';

enum TaskTypeValue {
  call('CALL', 'Call'),
  delivery('DELIVERY', 'Delivery'),
  paymentCollection('PAYMENT_COLLECTION', 'Payment'),
  reminder('REMINDER', 'Reminder'),
  other('OTHER', 'Other');

  const TaskTypeValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskTypeValue fromApi(String value) {
    return TaskTypeValue.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => TaskTypeValue.other,
    );
  }
}

enum TaskStatusValue {
  pending('PENDING', 'Pending'),
  done('DONE', 'Done'),
  postponed('POSTPONED', 'Postponed'),
  cancelled('CANCELLED', 'Cancelled');

  const TaskStatusValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskStatusValue fromApi(String value) {
    return TaskStatusValue.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => TaskStatusValue.pending,
    );
  }
}

enum CallOutcomeValue {
  paymentPromised('PAYMENT_PROMISED', 'Payment promised'),
  newOrder('NEW_ORDER', 'New order'),
  noAnswer('NO_ANSWER', 'No answer'),
  notInterested('NOT_INTERESTED', 'Not interested'),
  deliveryUpdate('DELIVERY_UPDATE', 'Delivery update'),
  other('OTHER', 'Other');

  const CallOutcomeValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CallOutcomeValue fromApi(String value) {
    return CallOutcomeValue.values.firstWhere(
      (outcome) => outcome.apiValue == value,
      orElse: () => CallOutcomeValue.other,
    );
  }
}

class TaskListQuery {
  const TaskListQuery({
    this.status,
    this.type,
    this.partyId,
    this.from,
    this.to,
  });

  final TaskStatusValue? status;
  final TaskTypeValue? type;
  final String? partyId;
  final DateTime? from;
  final DateTime? to;

  @override
  bool operator ==(Object other) {
    return other is TaskListQuery &&
        other.status == status &&
        other.type == type &&
        other.partyId == partyId &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(status, type, partyId, from, to);
}

class CallLogListQuery {
  const CallLogListQuery({
    this.partyId,
    this.from,
    this.to,
  });

  final String? partyId;
  final DateTime? from;
  final DateTime? to;

  @override
  bool operator ==(Object other) {
    return other is CallLogListQuery &&
        other.partyId == partyId &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(partyId, from, to);
}

class TaskPartySummary {
  const TaskPartySummary({
    required this.id,
    required this.name,
    this.phone,
    required this.type,
    required this.trustTag,
  });

  factory TaskPartySummary.fromParty(Party party) {
    return TaskPartySummary(
      id: party.id,
      name: party.name,
      phone: party.phone,
      type: party.type,
      trustTag: party.trustTag,
    );
  }

  factory TaskPartySummary.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};
    return TaskPartySummary(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      phone: data['phone'] as String?,
      type: data['type'] as String? ?? 'CUSTOMER',
      trustTag: data['trustTag'] as String? ?? 'NEW',
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String type;
  final String trustTag;
}

class TaskListItem {
  const TaskListItem({
    required this.task,
    this.party,
  });

  final Task task;
  final TaskPartySummary? party;

  TaskTypeValue get type => TaskTypeValue.fromApi(task.type);
  TaskStatusValue get status => TaskStatusValue.fromApi(task.status);
  String get displayName => party?.name ?? task.title;

  bool isOverdue(DateTime now) {
    return task.status != TaskStatusValue.done.apiValue &&
        task.scheduledAt.isBefore(now);
  }
}

class CallLogListItem {
  const CallLogListItem({
    required this.callLog,
    this.party,
    this.taskTitle,
  });

  final CallLog callLog;
  final TaskPartySummary? party;
  final String? taskTitle;

  CallOutcomeValue get outcome => CallOutcomeValue.fromApi(callLog.outcome);
}

class CreateTaskInput {
  const CreateTaskInput({
    this.partyId,
    required this.type,
    required this.title,
    this.notes,
    required this.scheduledAt,
    this.priority = 0,
  });

  final String? partyId;
  final TaskTypeValue type;
  final String title;
  final String? notes;
  final DateTime scheduledAt;
  final int priority;
}

class UpdateTaskInput {
  const UpdateTaskInput({
    this.partyId,
    this.clearParty = false,
    this.type,
    this.title,
    this.notes,
    this.clearNotes = false,
    this.scheduledAt,
    this.status,
    this.priority,
  });

  final String? partyId;
  final bool clearParty;
  final TaskTypeValue? type;
  final String? title;
  final String? notes;
  final bool clearNotes;
  final DateTime? scheduledAt;
  final TaskStatusValue? status;
  final int? priority;
}

class FollowUpTaskInput {
  const FollowUpTaskInput({
    required this.id,
    required this.syncId,
    required this.scheduledAt,
    required this.title,
  });

  final String id;
  final String syncId;
  final DateTime scheduledAt;
  final String title;
}

class CreateCallLogInput {
  const CreateCallLogInput({
    this.taskId,
    this.partyId,
    required this.outcome,
    this.notes,
    this.promisedDate,
    this.promisedAmountPaise,
    this.followUpTask,
  });

  final String? taskId;
  final String? partyId;
  final CallOutcomeValue outcome;
  final String? notes;
  final DateTime? promisedDate;
  final int? promisedAmountPaise;
  final FollowUpTaskInput? followUpTask;
}

class TodayInsights {
  const TodayInsights({
    required this.pendingCollectionPaise,
    required this.callsDue,
    required this.deliveriesDue,
    required this.overdueCount,
  });

  factory TodayInsights.empty() {
    return const TodayInsights(
      pendingCollectionPaise: 0,
      callsDue: 0,
      deliveriesDue: 0,
      overdueCount: 0,
    );
  }

  factory TodayInsights.fromJson(Map<String, dynamic> json) {
    return TodayInsights(
      pendingCollectionPaise: decimalRupeesToPaise(
        json['pendingCollection'],
      ),
      callsDue: (json['callsDue'] as num?)?.toInt() ?? 0,
      deliveriesDue: (json['deliveriesDue'] as num?)?.toInt() ?? 0,
      overdueCount: (json['overdueCount'] as num?)?.toInt() ?? 0,
    );
  }

  final int pendingCollectionPaise;
  final int callsDue;
  final int deliveriesDue;
  final int overdueCount;
}
