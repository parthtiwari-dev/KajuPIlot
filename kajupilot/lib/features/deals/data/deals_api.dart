import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/currency.dart';
import 'deal_models.dart';

class DealsApi {
  const DealsApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<DealListItem>> list({
    DealStatusValue? status,
    String? partyId,
    String? grade,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/deals',
      queryParameters: {
        if (status != null) 'status': status.apiValue,
        if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
        if (grade != null && grade.trim().isNotEmpty) 'grade': grade.trim(),
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(dealListItemFromResponse)
        .toList();
  }

  Future<DealListItem> create({
    required String id,
    required String syncId,
    required CreateDealInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/deals',
      data: dealCreatePayload(id: id, syncId: syncId, input: input),
    );

    return dealListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<DealListItem> get(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/deals/$id');
    return dealListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<DealListItem> update(String id, UpdateDealInput input) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/deals/$id',
      data: dealUpdatePayload(input),
    );

    return dealListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<DealListItem> updateStatus(String id, DealStatusValue status) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/deals/$id/status',
      data: {'status': status.apiValue},
    );

    return dealListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<DealListItem> delete(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/deals/$id',
    );
    return dealListItemFromResponse(response.data ?? <String, dynamic>{});
  }
}

DealListItem dealListItemFromResponse(Map<String, dynamic> json) {
  final deal = dealFromJson(json);
  final items = (json['items'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .map((item) => dealItemFromJson(deal.id, item))
      .toList();

  return DealListItem(
    deal: deal,
    party: DealPartySummary.fromJson(json['party'] as Map<String, dynamic>?),
    items: items,
  );
}

Deal dealFromJson(Map<String, dynamic> json) {
  return Deal(
    id: json['id'] as String,
    userId: json['userId'] as String,
    partyId: json['partyId'] as String,
    type: json['type'] as String,
    cashewGrade: json['cashewGrade'] as String,
    quantityGrams: 0,
    ratePaisePerKg: 0,
    totalPaise: decimalRupeesToPaise(json['totalAmount']),
    paidPaise: decimalRupeesToPaise(json['paidAmount']),
    status: json['status'] as String,
    deliveryDate: _dateOrNull(json['deliveryDate']),
    paymentDue: _dateOrNull(json['paymentDue']),
    notes: json['notes'] as String?,
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: _dateOrNull(json['deletedAt']),
  );
}

DealItem dealItemFromJson(String dealId, Map<String, dynamic> json) {
  return DealItem(
    id: json['id'] as String,
    dealId: dealId,
    grade: json['grade'] as String,
    quantityText: json['quantityText'] as String,
    rateText: json['rateText'] as String?,
    lineTotalPaise: decimalRupeesToPaise(json['totalAmount']),
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
  );
}

Map<String, Object?> dealCreatePayload({
  required String id,
  required String syncId,
  required CreateDealInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'partyId': input.partyId,
    'type': input.type.apiValue,
    'items': input.items.map(dealLinePayload).toList(),
    'totalAmount': paiseToDecimalRupeesString(input.totalPaise),
    'paidAmount': paiseToDecimalRupeesString(input.paidPaise),
    'status': input.status.apiValue,
    'deliveryDate': input.deliveryDate?.toUtc().toIso8601String(),
    'paymentDue': input.paymentDue?.toUtc().toIso8601String(),
    'notes': input.notes,
  }..removeWhere((_, value) => value == null);
}

Map<String, Object?> dealUpdatePayload(UpdateDealInput input) {
  final payload = <String, Object?>{
    if (input.partyId != null) 'partyId': input.partyId,
    if (input.type != null) 'type': input.type!.apiValue,
    if (input.items != null)
      'items': input.items!.map(dealLinePayload).toList(),
    if (input.totalPaise != null)
      'totalAmount': paiseToDecimalRupeesString(input.totalPaise!),
    if (input.paidPaise != null)
      'paidAmount': paiseToDecimalRupeesString(input.paidPaise!),
    if (input.deliveryDate != null)
      'deliveryDate': input.deliveryDate!.toUtc().toIso8601String(),
    if (input.paymentDue != null)
      'paymentDue': input.paymentDue!.toUtc().toIso8601String(),
    if (input.notes != null) 'notes': input.notes,
  };

  if (input.clearDeliveryDate) {
    payload['deliveryDate'] = null;
  }
  if (input.clearPaymentDue) {
    payload['paymentDue'] = null;
  }
  if (input.clearNotes) {
    payload['notes'] = null;
  }

  return payload;
}

Map<String, Object?> dealLinePayload(DealLineInput input) {
  return {
    if (input.id != null) 'id': input.id,
    'grade': input.grade,
    'quantityText': input.quantityText,
    'rateText': input.rateText,
    'totalAmount': paiseToDecimalRupeesString(input.lineTotalPaise),
  }..removeWhere((_, value) => value == null);
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toUtc();
}
