import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/currency.dart';
import 'money_models.dart';

class PaymentsApi {
  const PaymentsApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<PaymentListItem>> list({
    String? partyId,
    String? dealId,
    PaymentTypeValue? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/payments',
      queryParameters: {
        if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
        if (dealId != null && dealId.isNotEmpty) 'dealId': dealId,
        if (type != null) 'type': type.apiValue,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(paymentListItemFromResponse)
        .toList();
  }

  Future<PaymentListItem> create({
    required String id,
    required String syncId,
    required CreatePaymentInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/payments',
      data: paymentCreatePayload(id: id, syncId: syncId, input: input),
    );

    return paymentListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<PaymentListItem> update(String id, UpdatePaymentInput input) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/payments/$id',
      data: paymentUpdatePayload(input),
    );

    return paymentListItemFromResponse(response.data ?? <String, dynamic>{});
  }

  Future<PaymentListItem> delete(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/payments/$id',
    );
    return paymentListItemFromResponse(response.data ?? <String, dynamic>{});
  }
}

PaymentListItem paymentListItemFromResponse(Map<String, dynamic> json) {
  return PaymentListItem(
    payment: paymentFromJson(json),
    party: PaymentPartySummary.fromJson(json['party'] as Map<String, dynamic>?),
    deal: json['deal'] == null
        ? null
        : PaymentDealSummary.fromJson(json['deal'] as Map<String, dynamic>?),
  );
}

Payment paymentFromJson(Map<String, dynamic> json) {
  return Payment(
    id: json['id'] as String,
    userId: json['userId'] as String,
    partyId: json['partyId'] as String,
    dealId: json['dealId'] as String?,
    type: json['type'] as String,
    amountPaise: decimalRupeesToPaise(json['amount']),
    method: json['method'] as String?,
    notes: json['notes'] as String?,
    paymentDate: DateTime.parse(json['paymentDate'] as String).toUtc(),
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: _dateOrNull(json['deletedAt']),
  );
}

Map<String, Object?> paymentCreatePayload({
  required String id,
  required String syncId,
  required CreatePaymentInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'partyId': input.partyId,
    'dealId': input.dealId,
    'type': input.type.apiValue,
    'amount': paiseToDecimalRupeesString(input.amountPaise),
    'method': input.method,
    'paymentDate': input.paymentDate.toUtc().toIso8601String(),
    'notes': input.notes,
  }..removeWhere((_, value) => value == null);
}

Map<String, Object?> paymentUpdatePayload(UpdatePaymentInput input) {
  final payload = {
    'partyId': input.partyId,
    'dealId': input.dealId,
    'type': input.type.apiValue,
    'amount': paiseToDecimalRupeesString(input.amountPaise),
    'method': input.method,
    'paymentDate': input.paymentDate.toUtc().toIso8601String(),
    'notes': input.notes,
  };

  payload.removeWhere((key, value) {
    return value == null &&
        key != 'dealId' &&
        key != 'method' &&
        key != 'notes';
  });

  return payload;
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toUtc();
}
