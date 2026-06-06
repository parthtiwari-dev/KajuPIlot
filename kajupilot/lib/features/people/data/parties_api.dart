import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/currency.dart';
import 'party_models.dart';

class PartiesApi {
  const PartiesApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<List<PartyListItem>> list({
    String? search,
    PartyTypeValue? type,
    TrustTagValue? trustTag,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/parties',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (type != null) 'type': type.apiValue,
        if (trustTag != null) 'trustTag': trustTag.apiValue,
      },
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => PartyListItem(
              party: partyFromJson(json),
              stats:
                  PartyStats.fromJson(json['stats'] as Map<String, dynamic>?),
            ))
        .toList();
  }

  Future<PartyListItem> create({
    required String id,
    required String syncId,
    required CreatePartyInput input,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/parties',
      data: {
        'id': id,
        'syncId': syncId,
        'name': input.name,
        if (input.phone != null) 'phone': input.phone,
        'type': input.type.apiValue,
        'trustTag': input.trustTag.apiValue,
        if (input.notes != null) 'notes': input.notes,
      },
    );

    return partyListItemFromResponse(response.data);
  }

  Future<PartyListItem> get(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/parties/$id');
    return partyListItemFromResponse(response.data);
  }

  Future<PartyListItem> update(String id, UpdatePartyInput input) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/parties/$id',
      data: partyUpdatePayload(input),
    );

    return partyListItemFromResponse(response.data);
  }

  Future<Party> delete(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/parties/$id',
    );
    return partyFromJson(response.data ?? <String, dynamic>{});
  }

  Future<PartyLedger> ledger(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/parties/$id/ledger',
    );
    return PartyLedger.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Map<String, dynamic>> history(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/parties/$id/history',
    );
    return response.data ?? <String, dynamic>{};
  }
}

PartyListItem partyListItemFromResponse(Map<String, dynamic>? json) {
  final data = json ?? <String, dynamic>{};
  return PartyListItem(
    party: partyFromJson(data),
    stats: PartyStats.fromJson(data['stats'] as Map<String, dynamic>?),
  );
}

Party partyFromJson(Map<String, dynamic> json) {
  return Party(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,
    type: json['type'] as String,
    trustTag: json['trustTag'] as String,
    notes: json['notes'] as String?,
    syncId: json['syncId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String).toUtc(),
  );
}

Map<String, Object?> partyCreatePayload({
  required String id,
  required String syncId,
  required CreatePartyInput input,
}) {
  return {
    'id': id,
    'syncId': syncId,
    'name': input.name,
    'phone': input.phone,
    'type': input.type.apiValue,
    'trustTag': input.trustTag.apiValue,
    'notes': input.notes,
  };
}

Map<String, Object?> partyUpdatePayload(UpdatePartyInput input) {
  final payload = <String, Object?>{
    if (input.name != null) 'name': input.name,
    if (input.phone != null) 'phone': input.phone,
    if (input.type != null) 'type': input.type!.apiValue,
    if (input.trustTag != null) 'trustTag': input.trustTag!.apiValue,
    if (input.notes != null) 'notes': input.notes,
  };

  if (input.clearPhone) {
    payload['phone'] = null;
  }
  if (input.clearNotes) {
    payload['notes'] = null;
  }

  return payload;
}

Map<String, Object?> partySyncPayload(Party party) {
  return {
    'id': party.id,
    'syncId': party.syncId,
    'name': party.name,
    'phone': party.phone,
    'type': party.type,
    'trustTag': party.trustTag,
    'notes': party.notes,
    'createdAt': party.createdAt.toIso8601String(),
    'updatedAt': party.updatedAt.toIso8601String(),
    'deletedAt': party.deletedAt?.toIso8601String(),
    'pendingAmount': paiseToDecimalRupeesString(0),
  };
}
