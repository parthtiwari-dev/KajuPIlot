import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/currency.dart';
import 'tasks_api.dart';
import 'today_models.dart';

class CallLogsApi {
  const CallLogsApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<CallLogListItem>> list(CallLogListQuery query) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/call-logs',
      queryParameters: {
        if (query.partyId != null) 'partyId': query.partyId,
        if (query.from != null) 'from': query.from!.toUtc().toIso8601String(),
        if (query.to != null) 'to': query.to!.toUtc().toIso8601String(),
      },
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(callLogListItemFromResponse)
        .toList();
  }

  Future<CallLogCreateResult> create({
    required String id,
    required String syncId,
    required CreateCallLogInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/call-logs',
      data: callLogCreatePayload(id: id, syncId: syncId, input: input),
    );
    return callLogCreateResultFromResponse(
      response.data ?? <String, dynamic>{},
    );
  }
}

class CallLogCreateResult {
  const CallLogCreateResult({
    required this.item,
    this.nextTask,
  });

  final CallLogListItem item;
  final TaskListItem? nextTask;
}

CallLogCreateResult callLogCreateResultFromResponse(
  Map<String, dynamic> json,
) {
  return CallLogCreateResult(
    item: callLogListItemFromResponse(json),
    nextTask: json['nextTask'] == null
        ? null
        : taskListItemFromResponse(json['nextTask'] as Map<String, dynamic>),
  );
}

CallLogListItem callLogListItemFromResponse(Map<String, dynamic> json) {
  final task = json['task'] as Map<String, dynamic>?;
  return CallLogListItem(
    callLog: callLogFromJson(json),
    party: json['party'] == null
        ? null
        : TaskPartySummary.fromJson(json['party'] as Map<String, dynamic>?),
    taskTitle: task?['title'] as String?,
  );
}

CallLog callLogFromJson(Map<String, dynamic> json) {
  return CallLog(
    id: json['id'] as String,
    userId: json['userId'] as String,
    taskId: json['taskId'] as String?,
    partyId: json['partyId'] as String?,
    outcome: json['outcome'] as String,
    notes: json['notes'] as String?,
    promisedDate: _dateOrNull(json['promisedDate']),
    promisedAmountPaise: json['promisedAmount'] == null
        ? null
        : decimalRupeesToPaise(json['promisedAmount']),
    nextFollowup: _dateOrNull(json['nextFollowup']),
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
  );
}

Map<String, Object?> callLogCreatePayload({
  required String id,
  required String syncId,
  required CreateCallLogInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'taskId': input.taskId,
    'partyId': input.partyId,
    'outcome': input.outcome.apiValue,
    'notes': input.notes,
    'promisedDate': input.promisedDate?.toUtc().toIso8601String(),
    'promisedAmount': input.promisedAmountPaise == null
        ? null
        : paiseToDecimalRupeesString(input.promisedAmountPaise!),
    'followUpTask': input.followUpTask == null
        ? null
        : {
            'id': input.followUpTask!.id,
            'syncId': input.followUpTask!.syncId,
            'scheduledAt':
                input.followUpTask!.scheduledAt.toUtc().toIso8601String(),
            'title': input.followUpTask!.title,
          },
  }..removeWhere((_, value) => value == null);
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toUtc();
}
