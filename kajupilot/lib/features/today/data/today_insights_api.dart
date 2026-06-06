import '../../../core/network/api_client.dart';
import 'today_models.dart';

class TodayInsightsApi {
  const TodayInsightsApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<TodayInsights> today(DateTime date) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/insights/today',
      queryParameters: {'date': _dateOnly(date)},
    );
    return TodayInsights.fromJson(response.data ?? <String, dynamic>{});
  }
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
