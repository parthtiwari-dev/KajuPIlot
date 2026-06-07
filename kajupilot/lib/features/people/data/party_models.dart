import '../../../core/db/app_database.dart';
import '../../../core/utils/currency.dart';

enum PartyTypeValue {
  customer('CUSTOMER', 'Customer'),
  supplier('SUPPLIER', 'Supplier'),
  both('BOTH', 'Both');

  const PartyTypeValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PartyTypeValue fromApi(String value) {
    return PartyTypeValue.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => PartyTypeValue.customer,
    );
  }
}

enum TrustTagValue {
  reliable('RELIABLE', 'Reliable'),
  slowPayer('SLOW_PAYER', 'Slow Payer'),
  risky('RISKY', 'Risky'),
  fresh('NEW', 'New');

  const TrustTagValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TrustTagValue fromApi(String value) {
    return TrustTagValue.values.firstWhere(
      (tag) => tag.apiValue == value,
      orElse: () => TrustTagValue.fresh,
    );
  }
}

enum PartyListFilter {
  all('All'),
  customers('Customers'),
  suppliers('Suppliers'),
  both('Both'),
  overdue('Overdue');

  const PartyListFilter(this.label);

  final String label;
}

class PartyListQuery {
  const PartyListQuery({
    this.search = '',
    this.filter = PartyListFilter.all,
  });

  final String search;
  final PartyListFilter filter;

  @override
  bool operator ==(Object other) {
    return other is PartyListQuery &&
        other.search == search &&
        other.filter == filter;
  }

  @override
  int get hashCode => Object.hash(search, filter);
}

class PartyStats {
  const PartyStats({
    this.dealCount = 0,
    this.pendingAmountPaise = 0,
    this.avgDelayDays,
    this.overdueAmountPaise = 0,
    this.totalSaleValuePaise = 0,
  });

  factory PartyStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PartyStats();
    }

    return PartyStats(
      dealCount: (json['dealCount'] as num?)?.toInt() ?? 0,
      pendingAmountPaise: decimalRupeesToPaise(json['pendingAmount']),
      avgDelayDays: (json['avgDelayDays'] as num?)?.round(),
      overdueAmountPaise: decimalRupeesToPaise(json['overdueAmount']),
      totalSaleValuePaise: decimalRupeesToPaise(json['totalSaleValue']),
    );
  }

  final int dealCount;
  final int pendingAmountPaise;
  final int? avgDelayDays;
  final int overdueAmountPaise;
  final int totalSaleValuePaise;
}

class PartyListItem {
  const PartyListItem({
    required this.party,
    this.stats = const PartyStats(),
  });

  final Party party;
  final PartyStats stats;

  PartyTypeValue get type => PartyTypeValue.fromApi(party.type);
  TrustTagValue get trustTag => TrustTagValue.fromApi(party.trustTag);
}

class PartyLedger {
  const PartyLedger({
    required this.receivablePaise,
    required this.payablePaise,
    required this.netPaise,
    required this.overdueAmountPaise,
    required this.oldestOverdueDate,
  });

  factory PartyLedger.empty() {
    return const PartyLedger(
      receivablePaise: 0,
      payablePaise: 0,
      netPaise: 0,
      overdueAmountPaise: 0,
      oldestOverdueDate: null,
    );
  }

  factory PartyLedger.fromJson(Map<String, dynamic> json) {
    return PartyLedger(
      receivablePaise: decimalRupeesToPaise(json['receivable']),
      payablePaise: decimalRupeesToPaise(json['payable']),
      netPaise: decimalRupeesToPaise(json['net']),
      overdueAmountPaise: decimalRupeesToPaise(json['overdueAmount']),
      oldestOverdueDate: json['oldestOverdueDate'] == null
          ? null
          : DateTime.parse(json['oldestOverdueDate'] as String),
    );
  }

  final int receivablePaise;
  final int payablePaise;
  final int netPaise;
  final int overdueAmountPaise;
  final DateTime? oldestOverdueDate;
}

enum PartyTimelineKind {
  deal('deal', 'Deal'),
  payment('payment', 'Payment'),
  call('call', 'Call');

  const PartyTimelineKind(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PartyTimelineKind fromApi(String value) {
    return PartyTimelineKind.values.firstWhere(
      (kind) => kind.apiValue == value,
      orElse: () => PartyTimelineKind.deal,
    );
  }
}

class PartyHistory {
  const PartyHistory({required this.timeline});

  factory PartyHistory.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'];
    return PartyHistory(
      timeline: rawTimeline is List
          ? rawTimeline
              .whereType<Map<String, dynamic>>()
              .map(PartyTimelineItem.fromJson)
              .toList()
          : const [],
    );
  }

  final List<PartyTimelineItem> timeline;
}

class PartyTimelineItem {
  const PartyTimelineItem({
    required this.kind,
    required this.id,
    required this.title,
    this.amountPaise,
    required this.occurredAt,
    this.notes,
  });

  factory PartyTimelineItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PartyTimelineItem(
      kind: PartyTimelineKind.fromApi(json['kind'] as String? ?? 'deal'),
      id: json['id'] as String? ?? '',
      title: _title(json),
      amountPaise:
          json['amount'] == null ? null : decimalRupeesToPaise(json['amount']),
      occurredAt: DateTime.parse(json['occurredAt'] as String).toLocal(),
      notes: data['notes'] as String?,
    );
  }

  final PartyTimelineKind kind;
  final String id;
  final String title;
  final int? amountPaise;
  final DateTime occurredAt;
  final String? notes;
}

String _title(Map<String, dynamic> json) {
  final title = json['title'] as String?;
  if (title == null || title.trim().isEmpty) {
    return 'Activity';
  }
  return title
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class CreatePartyInput {
  const CreatePartyInput({
    required this.name,
    this.phone,
    required this.type,
    this.trustTag = TrustTagValue.fresh,
    this.notes,
  });

  final String name;
  final String? phone;
  final PartyTypeValue type;
  final TrustTagValue trustTag;
  final String? notes;
}

class UpdatePartyInput {
  const UpdatePartyInput({
    this.name,
    this.phone,
    this.clearPhone = false,
    this.type,
    this.trustTag,
    this.notes,
    this.clearNotes = false,
  });

  final String? name;
  final String? phone;
  final bool clearPhone;
  final PartyTypeValue? type;
  final TrustTagValue? trustTag;
  final String? notes;
  final bool clearNotes;
}
