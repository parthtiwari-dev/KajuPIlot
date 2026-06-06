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
    );
  }

  final int dealCount;
  final int pendingAmountPaise;
  final int? avgDelayDays;
  final int overdueAmountPaise;
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
