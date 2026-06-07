import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../core/utils/currency.dart';
import '../../money/data/money_models.dart';
import '../../people/data/party_models.dart';

final _apiDateFormat = DateFormat('yyyy-MM-dd');

String apiDate(DateTime value) => _apiDateFormat.format(value);

class InsightsDashboard {
  const InsightsDashboard({
    required this.aiSummary,
    required this.aiWeekly,
    required this.weekly,
    required this.people,
  });

  final AiTodaySummary aiSummary;
  final AiWeeklyInsights aiWeekly;
  final WeeklyInsights weekly;
  final PeopleInsights people;

  bool get hasData {
    return weekly.revenuePaise != 0 ||
        weekly.businessExpensesPaise != 0 ||
        weekly.dealsClosedCount != 0 ||
        weekly.newPartiesCount != 0 ||
        weekly.topBuyers.isNotEmpty ||
        people.slowPayers.isNotEmpty;
  }
}

class MoreToolsStatus {
  const MoreToolsStatus({
    required this.backend,
    required this.aiProvider,
    required this.pendingSyncCount,
  });

  final BackendHealthStatus backend;
  final AiProviderStatus aiProvider;
  final int pendingSyncCount;
}

class BackendHealthStatus {
  const BackendHealthStatus({
    required this.ok,
    this.service,
    this.timestamp,
  });

  factory BackendHealthStatus.fromJson(Map<String, dynamic> json) {
    return BackendHealthStatus(
      ok: json['status'] == 'ok',
      service: json['service'] as String?,
      timestamp: _dateOrNull(json['timestamp']),
    );
  }

  factory BackendHealthStatus.offline() {
    return const BackendHealthStatus(ok: false);
  }

  final bool ok;
  final String? service;
  final DateTime? timestamp;
}

class AiProviderStatus {
  const AiProviderStatus({
    required this.provider,
    required this.model,
    this.inputCostUsd,
    this.outputCostUsd,
  });

  factory AiProviderStatus.fromJson(Map<String, dynamic> json) {
    final active = json['active'] as Map<String, dynamic>? ?? {};
    final cost = active['cost'] as Map<String, dynamic>? ?? {};
    return AiProviderStatus(
      provider: active['provider'] as String? ?? 'unknown',
      model: active['model'] as String? ?? 'unknown',
      inputCostUsd: (cost['inputPerMillionTokensUsd'] as num?)?.toDouble(),
      outputCostUsd: (cost['outputPerMillionTokensUsd'] as num?)?.toDouble(),
    );
  }

  factory AiProviderStatus.unknown() {
    return const AiProviderStatus(provider: 'unknown', model: 'unknown');
  }

  final String provider;
  final String model;
  final double? inputCostUsd;
  final double? outputCostUsd;
}

class AiTodaySummary {
  const AiTodaySummary({
    required this.text,
    this.generatedAt,
    required this.provider,
    required this.model,
    required this.cached,
  });

  factory AiTodaySummary.fromJson(Map<String, dynamic> json) {
    return AiTodaySummary(
      text: json['text'] as String? ?? 'Review Today and Money manually.',
      generatedAt: _dateOrNull(json['generatedAt']),
      provider: json['provider'] as String? ?? 'ai',
      model: json['model'] as String? ?? 'unknown',
      cached: json['cached'] as bool? ?? false,
    );
  }

  final String text;
  final DateTime? generatedAt;
  final String provider;
  final String model;
  final bool cached;
}

class AiWeeklyInsights {
  const AiWeeklyInsights({
    required this.insights,
    this.generatedAt,
    required this.provider,
    required this.model,
    required this.cached,
  });

  factory AiWeeklyInsights.fromJson(Map<String, dynamic> json) {
    final rawInsights = json['insights'];
    return AiWeeklyInsights(
      insights: _cleanAiInsights(rawInsights),
      generatedAt: _dateOrNull(json['generatedAt']),
      provider: json['provider'] as String? ?? 'ai',
      model: json['model'] as String? ?? 'unknown',
      cached: json['cached'] as bool? ?? false,
    );
  }

  final List<String> insights;
  final DateTime? generatedAt;
  final String provider;
  final String model;
  final bool cached;
}

class WeeklyInsights {
  const WeeklyInsights({
    required this.from,
    required this.to,
    required this.revenuePaise,
    required this.businessExpensesPaise,
    required this.personalExpensesPaise,
    required this.grossProfitEstimatePaise,
    required this.dealsClosedCount,
    required this.newPartiesCount,
    required this.topBuyers,
    required this.slowestPayers,
    required this.expenseByCategoryPaise,
  });

  factory WeeklyInsights.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final expenseBreakdown =
        json['expenseBreakdown'] as Map<String, dynamic>? ?? {};
    final byCategory =
        expenseBreakdown['byCategory'] as Map<String, dynamic>? ?? {};
    return WeeklyInsights(
      from: period['from'] as String? ?? '',
      to: period['to'] as String? ?? '',
      revenuePaise: decimalRupeesToPaise(json['revenue']),
      businessExpensesPaise: decimalRupeesToPaise(json['businessExpenses']),
      personalExpensesPaise: decimalRupeesToPaise(json['personalExpenses']),
      grossProfitEstimatePaise:
          decimalRupeesToPaise(json['grossProfitEstimate']),
      dealsClosedCount: (json['dealsClosedCount'] as num?)?.toInt() ?? 0,
      newPartiesCount: (json['newPartiesCount'] as num?)?.toInt() ?? 0,
      topBuyers: _partyInsightList(json['topBuyers']),
      slowestPayers: _partyInsightList(json['slowestPayers']),
      expenseByCategoryPaise: {
        for (final category in ExpenseCategoryValue.values)
          category: decimalRupeesToPaise(byCategory[category.apiValue]),
      },
    );
  }

  final String from;
  final String to;
  final int revenuePaise;
  final int businessExpensesPaise;
  final int personalExpensesPaise;
  final int grossProfitEstimatePaise;
  final int dealsClosedCount;
  final int newPartiesCount;
  final List<PartyInsightItem> topBuyers;
  final List<PartyInsightItem> slowestPayers;
  final Map<ExpenseCategoryValue, int> expenseByCategoryPaise;
}

class PeopleInsights {
  const PeopleInsights({
    required this.topBuyers,
    required this.slowPayers,
    required this.inactiveCustomers,
    required this.trustTagUpdates,
  });

  factory PeopleInsights.fromJson(Map<String, dynamic> json) {
    return PeopleInsights(
      topBuyers: _partyInsightList(json['topBuyers']),
      slowPayers: _partyInsightList(json['slowPayers']),
      inactiveCustomers: _partyInsightList(json['inactiveCustomers']),
      trustTagUpdates: _trustTagUpdateList(json['trustTagUpdates']),
    );
  }

  final List<PartyInsightItem> topBuyers;
  final List<PartyInsightItem> slowPayers;
  final List<PartyInsightItem> inactiveCustomers;
  final List<TrustTagUpdate> trustTagUpdates;
}

class PartyInsightItem {
  const PartyInsightItem({
    required this.partyId,
    required this.name,
    this.phone,
    required this.trustTag,
    this.amountPaise = 0,
    this.dealCount = 0,
    this.avgDelayDays = 0,
    this.overdueAmountPaise = 0,
    this.latePaymentCount = 0,
    this.daysInactive,
    this.lastActivityAt,
  });

  factory PartyInsightItem.fromJson(Map<String, dynamic> json) {
    return PartyInsightItem(
      partyId: json['partyId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
      trustTag: TrustTagValue.fromApi(json['trustTag'] as String? ?? 'NEW'),
      amountPaise: decimalRupeesToPaise(json['amount']),
      dealCount: (json['dealCount'] as num?)?.toInt() ?? 0,
      avgDelayDays: (json['avgDelayDays'] as num?)?.toInt() ?? 0,
      overdueAmountPaise: decimalRupeesToPaise(json['overdueAmount']),
      latePaymentCount: (json['latePaymentCount'] as num?)?.toInt() ?? 0,
      daysInactive: (json['daysInactive'] as num?)?.toInt(),
      lastActivityAt: _dateOrNull(json['lastActivityAt']),
    );
  }

  final String partyId;
  final String name;
  final String? phone;
  final TrustTagValue trustTag;
  final int amountPaise;
  final int dealCount;
  final int avgDelayDays;
  final int overdueAmountPaise;
  final int latePaymentCount;
  final int? daysInactive;
  final DateTime? lastActivityAt;
}

class TrustTagUpdate {
  const TrustTagUpdate({
    required this.partyId,
    required this.name,
    required this.previousTrustTag,
    required this.trustTag,
    required this.avgDelayDays,
  });

  factory TrustTagUpdate.fromJson(Map<String, dynamic> json) {
    return TrustTagUpdate(
      partyId: json['partyId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      previousTrustTag:
          TrustTagValue.fromApi(json['previousTrustTag'] as String? ?? 'NEW'),
      trustTag: TrustTagValue.fromApi(json['trustTag'] as String? ?? 'NEW'),
      avgDelayDays: (json['avgDelayDays'] as num?)?.toInt() ?? 0,
    );
  }

  final String partyId;
  final String name;
  final TrustTagValue previousTrustTag;
  final TrustTagValue trustTag;
  final int avgDelayDays;
}

List<PartyInsightItem> _partyInsightList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map(PartyInsightItem.fromJson)
      .toList();
}

List<TrustTagUpdate> _trustTagUpdateList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map(TrustTagUpdate.fromJson)
      .toList();
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String).toLocal();
}

List<String> _cleanAiInsights(Object? value) {
  if (value is String) {
    return _parseInsightText(value);
  }
  if (value is! List) {
    return const [];
  }

  final lines = value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  if (lines.any(_looksLikeJsonScaffold)) {
    return _parseInsightText(lines.join('\n'));
  }

  return lines
      .map(_cleanInsightLine)
      .where((item) => item.isNotEmpty)
      .take(5)
      .toList();
}

List<String> _parseInsightText(String text) {
  final normalized = _stripCodeFence(text);
  try {
    final parsed = jsonDecode(normalized);
    if (parsed is Map<String, dynamic>) {
      final insights = parsed['insights'];
      if (insights is List) {
        return _cleanAiInsights(insights);
      }
    }
  } catch (_) {
    // Fall through to line cleanup.
  }

  return normalized
      .split(RegExp(r'\r?\n'))
      .map(_cleanInsightLine)
      .where((item) => item.isNotEmpty)
      .take(5)
      .toList();
}

String _stripCodeFence(String text) {
  return text
      .trim()
      .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'\s*```$', caseSensitive: false), '')
      .trim();
}

String _cleanInsightLine(String line) {
  final cleaned = line
      .trim()
      .replaceFirst(RegExp(r'^[-*\d.\s]+'), '')
      .replaceFirst(RegExp(r'^"+'), '')
      .replaceFirst(RegExp(r'",?$'), '')
      .replaceFirst(RegExp(r"^'+"), '')
      .replaceFirst(RegExp(r"',?$"), '')
      .trim();

  if (cleaned.isEmpty || _looksLikeJsonScaffold(cleaned)) {
    return '';
  }

  return cleaned;
}

bool _looksLikeJsonScaffold(String value) {
  final trimmed = value.trim();
  return trimmed.startsWith('```') ||
      trimmed == '{' ||
      trimmed == '}' ||
      trimmed == '[' ||
      trimmed == ']' ||
      trimmed.contains('"insights"');
}
