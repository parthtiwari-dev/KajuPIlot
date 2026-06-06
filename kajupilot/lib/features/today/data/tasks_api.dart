import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import 'today_models.dart';

class TasksApi {
  const TasksApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<TaskListItem>> list(TaskListQuery query) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/tasks',
      queryParameters: _queryPayload(query),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(taskListItemFromResponse)
        .toList();
  }

  Future<List<TaskListItem>> today(DateTime date) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/tasks/today',
      queryParameters: {'date': _dateOnly(date)},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(taskListItemFromResponse)
        .toList();
  }

  Future<TaskListItem> create({
    required String id,
    required String syncId,
    required CreateTaskInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks',
      data: taskCreatePayload(id: id, syncId: syncId, input: input),
    );
    return taskListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<TaskListItem> update(String id, UpdateTaskInput input) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/tasks/$id',
      data: taskUpdatePayload(input),
    );
    return taskListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<TaskListItem> complete(String id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/tasks/$id/complete',
    );
    return taskListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<TaskListItem> postpone(String id, DateTime scheduledAt) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/tasks/$id/postpone',
      data: {'scheduledAt': scheduledAt.toUtc().toIso8601String()},
    );
    return taskListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<TaskListItem> delete(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/tasks/$id',
    );
    return taskListItemFromResponse(response.data ?? <String, dynamic>{});
  }
}

TaskListItem taskListItemFromResponse(Map<String, dynamic> json) {
  return TaskListItem(
    task: taskFromJson(json),
    party: json['party'] == null
        ? null
        : TaskPartySummary.fromJson(json['party'] as Map<String, dynamic>?),
  );
}

Task taskFromJson(Map<String, dynamic> json) {
  return Task(
    id: json['id'] as String,
    userId: json['userId'] as String,
    partyId: json['partyId'] as String?,
    type: json['type'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String?,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String).toUtc(),
    completedAt: _dateOrNull(json['completedAt']),
    status: json['status'] as String,
    priority: (json['priority'] as num?)?.toInt() ?? 0,
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: _dateOrNull(json['deletedAt']),
  );
}

Map<String, Object?> taskCreatePayload({
  required String id,
  required String syncId,
  required CreateTaskInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'partyId': input.partyId,
    'type': input.type.apiValue,
    'title': input.title,
    'notes': input.notes,
    'scheduledAt': input.scheduledAt.toUtc().toIso8601String(),
    'priority': input.priority,
  }..removeWhere((_, value) => value == null);
}

Map<String, Object?> taskUpdatePayload(UpdateTaskInput input) {
  final payload = <String, Object?>{
    if (input.partyId != null) 'partyId': input.partyId,
    if (input.type != null) 'type': input.type!.apiValue,
    if (input.title != null) 'title': input.title,
    if (input.notes != null) 'notes': input.notes,
    if (input.scheduledAt != null)
      'scheduledAt': input.scheduledAt!.toUtc().toIso8601String(),
    if (input.status != null) 'status': input.status!.apiValue,
    if (input.priority != null) 'priority': input.priority,
  };

  if (input.clearParty) {
    payload['partyId'] = null;
  }
  if (input.clearNotes) {
    payload['notes'] = null;
  }

  return payload;
}

Map<String, Object?> _queryPayload(TaskListQuery query) {
  return {
    if (query.status != null) 'status': query.status!.apiValue,
    if (query.type != null) 'type': query.type!.apiValue,
    if (query.partyId != null) 'partyId': query.partyId,
    if (query.from != null) 'from': query.from!.toUtc().toIso8601String(),
    if (query.to != null) 'to': query.to!.toUtc().toIso8601String(),
  };
}

String _dateOnly(DateTime value) {
  final local = DateTime(value.year, value.month, value.day);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toUtc();
}
