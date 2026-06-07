import '../../core/network/api_client.dart';
import 'ai_parse_models.dart';

class AiParserApi {
  const AiParserApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<AiParseResult> parse({
    required String text,
    required DateTime localDate,
    required String timezone,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/ai/parse',
      data: {
        'text': text,
        'localDate': _dateOnly(localDate),
        'timezone': timezone,
      },
    );
    return AiParseResult.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Map<String, dynamic>> confirm({
    required String logId,
    required List<AiPreviewItem> items,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/ai/parse/$logId/confirm',
      data: {
        'items':
            items.map((item) => item.validated().toConfirmPayload()).toList(),
      },
    );
    return response.data ?? <String, dynamic>{};
  }
}

String _dateOnly(DateTime value) {
  final local = DateTime(value.year, value.month, value.day);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
