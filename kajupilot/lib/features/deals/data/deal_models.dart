import '../../../core/db/app_database.dart';
import '../../../core/utils/currency.dart';

enum DealTypeValue {
  sale('SALE', 'Sale'),
  purchase('PURCHASE', 'Purchase');

  const DealTypeValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String get defaultPartyType {
    return switch (this) {
      DealTypeValue.sale => 'CUSTOMER',
      DealTypeValue.purchase => 'SUPPLIER',
    };
  }

  static DealTypeValue fromApi(String value) {
    return DealTypeValue.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => DealTypeValue.sale,
    );
  }
}

enum DealStatusValue {
  quoted('QUOTED', 'Quoted'),
  confirmed('CONFIRMED', 'Confirmed'),
  delivered('DELIVERED', 'Delivered'),
  paid('PAID', 'Paid');

  const DealStatusValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  DealStatusValue? get next {
    return switch (this) {
      DealStatusValue.quoted => DealStatusValue.confirmed,
      DealStatusValue.confirmed => DealStatusValue.delivered,
      DealStatusValue.delivered => DealStatusValue.paid,
      DealStatusValue.paid => null,
    };
  }

  static DealStatusValue fromApi(String value) {
    return DealStatusValue.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => DealStatusValue.confirmed,
    );
  }
}

enum DealListFilter {
  all('All'),
  quoted('Quoted'),
  confirmed('Confirmed'),
  delivered('Delivered'),
  paid('Paid');

  const DealListFilter(this.label);

  final String label;

  DealStatusValue? get status {
    return switch (this) {
      DealListFilter.all => null,
      DealListFilter.quoted => DealStatusValue.quoted,
      DealListFilter.confirmed => DealStatusValue.confirmed,
      DealListFilter.delivered => DealStatusValue.delivered,
      DealListFilter.paid => DealStatusValue.paid,
    };
  }
}

class DealListQuery {
  const DealListQuery({
    this.search = '',
    this.filter = DealListFilter.all,
    this.partyId,
  });

  final String search;
  final DealListFilter filter;
  final String? partyId;

  @override
  bool operator ==(Object other) {
    return other is DealListQuery &&
        other.search == search &&
        other.filter == filter &&
        other.partyId == partyId;
  }

  @override
  int get hashCode => Object.hash(search, filter, partyId);
}

class DealPartySummary {
  const DealPartySummary({
    required this.id,
    required this.name,
    this.phone,
    required this.type,
    required this.trustTag,
  });

  factory DealPartySummary.fromParty(Party party) {
    return DealPartySummary(
      id: party.id,
      name: party.name,
      phone: party.phone,
      type: party.type,
      trustTag: party.trustTag,
    );
  }

  factory DealPartySummary.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};
    return DealPartySummary(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      phone: data['phone'] as String?,
      type: data['type'] as String? ?? 'CUSTOMER',
      trustTag: data['trustTag'] as String? ?? 'NEW',
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String type;
  final String trustTag;
}

class DealListItem {
  const DealListItem({
    required this.deal,
    required this.party,
    this.items = const [],
  });

  final Deal deal;
  final DealPartySummary party;
  final List<DealItem> items;

  DealTypeValue get type => DealTypeValue.fromApi(deal.type);
  DealStatusValue get status => DealStatusValue.fromApi(deal.status);
  int get pendingPaise => deal.totalPaise - deal.paidPaise;

  String get gradeSummary {
    if (items.isEmpty) {
      return deal.cashewGrade;
    }
    if (items.length == 1) {
      return items.single.grade;
    }
    return '${items.first.grade} + ${items.length - 1}';
  }

  String get quantitySummary {
    if (items.isEmpty) {
      return 'Bucket-wise';
    }
    if (items.length == 1) {
      return items.single.quantityText;
    }
    return '${items.length} items';
  }
}

class DealLineInput {
  const DealLineInput({
    this.id,
    required this.grade,
    required this.quantityText,
    this.rateText,
    required this.lineTotalPaise,
  });

  final String? id;
  final String grade;
  final String quantityText;
  final String? rateText;
  final int lineTotalPaise;
}

class CreateDealInput {
  const CreateDealInput({
    required this.partyId,
    this.type = DealTypeValue.sale,
    required this.items,
    required this.totalPaise,
    this.paidPaise = 0,
    this.status = DealStatusValue.confirmed,
    this.deliveryDate,
    this.paymentDue,
    this.notes,
  });

  final String partyId;
  final DealTypeValue type;
  final List<DealLineInput> items;
  final int totalPaise;
  final int paidPaise;
  final DealStatusValue status;
  final DateTime? deliveryDate;
  final DateTime? paymentDue;
  final String? notes;
}

class UpdateDealInput {
  const UpdateDealInput({
    this.partyId,
    this.type,
    this.items,
    this.totalPaise,
    this.paidPaise,
    this.deliveryDate,
    this.clearDeliveryDate = false,
    this.paymentDue,
    this.clearPaymentDue = false,
    this.notes,
    this.clearNotes = false,
  });

  final String? partyId;
  final DealTypeValue? type;
  final List<DealLineInput>? items;
  final int? totalPaise;
  final int? paidPaise;
  final DateTime? deliveryDate;
  final bool clearDeliveryDate;
  final DateTime? paymentDue;
  final bool clearPaymentDue;
  final String? notes;
  final bool clearNotes;
}

int sumLineTotals(List<DealLineInput> items) {
  return items.fold(0, (total, item) => total + item.lineTotalPaise);
}

String dealGradeSummary(List<DealLineInput> items) {
  final grades = items
      .map((item) => item.grade.trim())
      .where((grade) => grade.isNotEmpty)
      .toList();
  if (grades.isEmpty) {
    return 'Mixed';
  }
  if (grades.length == 1) {
    return grades.single;
  }
  return '${grades.first} + ${grades.length - 1}';
}

int rupeeTextToPaise(String value) {
  final normalized = value.trim().replaceAll(',', '');
  if (normalized.isEmpty) {
    return 0;
  }
  return rupeesToPaise(double.tryParse(normalized) ?? 0);
}
