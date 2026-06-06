import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/currency.dart';
import 'money_models.dart';

class ExpensesApi {
  const ExpensesApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<Expense>> list({
    ExpenseCategoryValue? category,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/expenses',
      queryParameters: {
        if (category != null) 'category': category.apiValue,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(expenseFromJson).toList();
  }

  Future<Expense> create({
    required String id,
    required String syncId,
    required CreateExpenseInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/expenses',
      data: expenseCreatePayload(id: id, syncId: syncId, input: input),
    );

    return expenseFromJson(response.data ?? <String, dynamic>{});
  }

  Future<Expense> update(String id, UpdateExpenseInput input) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/expenses/$id',
      data: expenseUpdatePayload(input),
    );

    return expenseFromJson(response.data ?? <String, dynamic>{});
  }

  Future<Expense> delete(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/expenses/$id',
    );
    return expenseFromJson(response.data ?? <String, dynamic>{});
  }

  Future<ExpenseSummary> summary({
    ExpenseCategoryValue? category,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/summary',
      queryParameters: {
        if (category != null) 'category': category.apiValue,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final byCategory = data['byCategory'] as Map<String, dynamic>? ?? {};

    return ExpenseSummary(
      byCategoryPaise: {
        for (final category in ExpenseCategoryValue.values)
          category: decimalRupeesToPaise(byCategory[category.apiValue]),
      },
      totalPaise: decimalRupeesToPaise(data['total']),
      periodComparison: (data['periodComparison'] as num?)?.toDouble() ?? 0,
    );
  }
}

Expense expenseFromJson(Map<String, dynamic> json) {
  return Expense(
    id: json['id'] as String,
    userId: json['userId'] as String,
    category: json['category'] as String,
    amountPaise: decimalRupeesToPaise(json['amount']),
    notes: json['notes'] as String?,
    expenseDate: DateTime.parse(json['expenseDate'] as String).toUtc(),
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: _dateOrNull(json['deletedAt']),
  );
}

Map<String, Object?> expenseCreatePayload({
  required String id,
  required String syncId,
  required CreateExpenseInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'category': input.category.apiValue,
    'amount': paiseToDecimalRupeesString(input.amountPaise),
    'expenseDate': input.expenseDate.toUtc().toIso8601String(),
    'notes': input.notes,
  }..removeWhere((_, value) => value == null);
}

Map<String, Object?> expenseUpdatePayload(UpdateExpenseInput input) {
  final payload = {
    'category': input.category.apiValue,
    'amount': paiseToDecimalRupeesString(input.amountPaise),
    'expenseDate': input.expenseDate.toUtc().toIso8601String(),
    'notes': input.notes,
  };

  payload.removeWhere((key, value) => value == null && key != 'notes');

  return payload;
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toUtc();
}
