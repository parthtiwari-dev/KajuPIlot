import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'insights_models.dart';

final insightsApiProvider = Provider<InsightsApi>((ref) {
  return InsightsApi(ref.watch(apiClientProvider));
});

final insightsDashboardProvider =
    FutureProvider<InsightsDashboard>((ref) async {
  final api = ref.watch(insightsApiProvider);
  final now = DateTime.now();

  final weekly = await api.weekly(to: now);
  final people = await api.people(to: now);
  final aiSummary = await api.todaySummary(date: now);
  final aiWeekly = await api.weeklyAiInsights(to: now);

  return InsightsDashboard(
    aiSummary: aiSummary,
    aiWeekly: aiWeekly,
    weekly: weekly,
    people: people,
  );
});

class InsightsApi {
  const InsightsApi(this._apiClient);

  final KajuApiClient _apiClient;

  Future<WeeklyInsights> weekly({DateTime? to}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/insights/weekly',
      queryParameters: {
        if (to != null) 'to': apiDate(to),
      },
    );

    return WeeklyInsights.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PeopleInsights> people({DateTime? to}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/insights/people',
      queryParameters: {
        if (to != null) 'to': apiDate(to),
      },
    );

    return PeopleInsights.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AiTodaySummary> todaySummary({
    DateTime? date,
    bool refresh = false,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/ai/summary/today',
      queryParameters: {
        if (date != null) 'date': apiDate(date),
        'refresh': refresh.toString(),
      },
    );

    return AiTodaySummary.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AiWeeklyInsights> weeklyAiInsights({
    DateTime? to,
    bool refresh = false,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/ai/insights/weekly',
      queryParameters: {
        if (to != null) 'to': apiDate(to),
        'refresh': refresh.toString(),
      },
    );

    return AiWeeklyInsights.fromJson(response.data ?? <String, dynamic>{});
  }
}
