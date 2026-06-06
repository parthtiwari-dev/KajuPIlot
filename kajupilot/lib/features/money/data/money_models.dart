import '../../../core/db/app_database.dart';
import '../../../core/utils/currency.dart';

enum PaymentTypeValue {
  received('RECEIVED', 'Received'),
  paid('PAID', 'Paid');

  const PaymentTypeValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String get defaultPartyType {
    return switch (this) {
      PaymentTypeValue.received => 'CUSTOMER',
      PaymentTypeValue.paid => 'SUPPLIER',
    };
  }

  static PaymentTypeValue fromApi(String value) {
    return PaymentTypeValue.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => PaymentTypeValue.received,
    );
  }
}

enum ExpenseCategoryValue {
  transport('TRANSPORT', 'Transport'),
  labour('LABOUR', 'Labour'),
  packaging('PACKAGING', 'Packaging'),
  brokerCommission('BROKER_COMMISSION', 'Broker'),
  stockPurchase('STOCK_PURCHASE', 'Stock'),
  other('OTHER', 'Other');

  const ExpenseCategoryValue(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ExpenseCategoryValue fromApi(String value) {
    return ExpenseCategoryValue.values.firstWhere(
      (category) => category.apiValue == value,
      orElse: () => ExpenseCategoryValue.other,
    );
  }
}

class PaymentListQuery {
  const PaymentListQuery({
    this.partyId,
    this.dealId,
    this.type,
    this.from,
    this.to,
  });

  final String? partyId;
  final String? dealId;
  final PaymentTypeValue? type;
  final DateTime? from;
  final DateTime? to;

  @override
  bool operator ==(Object other) {
    return other is PaymentListQuery &&
        other.partyId == partyId &&
        other.dealId == dealId &&
        other.type == type &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(partyId, dealId, type, from, to);
}

class ExpenseListQuery {
  const ExpenseListQuery({
    this.category,
    this.from,
    this.to,
  });

  final ExpenseCategoryValue? category;
  final DateTime? from;
  final DateTime? to;

  @override
  bool operator ==(Object other) {
    return other is ExpenseListQuery &&
        other.category == category &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(category, from, to);
}

class PaymentPartySummary {
  const PaymentPartySummary({
    required this.id,
    required this.name,
    this.phone,
    required this.type,
    required this.trustTag,
  });

  factory PaymentPartySummary.fromParty(Party party) {
    return PaymentPartySummary(
      id: party.id,
      name: party.name,
      phone: party.phone,
      type: party.type,
      trustTag: party.trustTag,
    );
  }

  factory PaymentPartySummary.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};
    return PaymentPartySummary(
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

class PaymentDealSummary {
  const PaymentDealSummary({
    required this.id,
    required this.partyId,
    required this.type,
    required this.cashewGrade,
    required this.totalPaise,
    required this.paidPaise,
  });

  factory PaymentDealSummary.fromDeal(Deal deal) {
    return PaymentDealSummary(
      id: deal.id,
      partyId: deal.partyId,
      type: deal.type,
      cashewGrade: deal.cashewGrade,
      totalPaise: deal.totalPaise,
      paidPaise: deal.paidPaise,
    );
  }

  factory PaymentDealSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentDealSummary(
        id: '',
        partyId: '',
        type: 'SALE',
        cashewGrade: 'Deal',
        totalPaise: 0,
        paidPaise: 0,
      );
    }

    return PaymentDealSummary(
      id: json['id'] as String? ?? '',
      partyId: json['partyId'] as String? ?? '',
      type: json['type'] as String? ?? 'SALE',
      cashewGrade: json['cashewGrade'] as String? ?? 'Deal',
      totalPaise: decimalRupeesToPaise(json['totalAmount']),
      paidPaise: decimalRupeesToPaise(json['paidAmount']),
    );
  }

  final String id;
  final String partyId;
  final String type;
  final String cashewGrade;
  final int totalPaise;
  final int paidPaise;

  int get pendingPaise => totalPaise - paidPaise;
}

class PaymentListItem {
  const PaymentListItem({
    required this.payment,
    required this.party,
    this.deal,
  });

  final Payment payment;
  final PaymentPartySummary party;
  final PaymentDealSummary? deal;

  PaymentTypeValue get type => PaymentTypeValue.fromApi(payment.type);
}

class PaymentDealOption {
  const PaymentDealOption({
    required this.id,
    required this.label,
    required this.type,
    required this.totalPaise,
    required this.paidPaise,
  });

  final String id;
  final String label;
  final String type;
  final int totalPaise;
  final int paidPaise;

  int get pendingPaise => totalPaise - paidPaise;
}

class CreatePaymentInput {
  const CreatePaymentInput({
    required this.partyId,
    this.dealId,
    required this.type,
    required this.amountPaise,
    this.method,
    required this.paymentDate,
    this.notes,
  });

  final String partyId;
  final String? dealId;
  final PaymentTypeValue type;
  final int amountPaise;
  final String? method;
  final DateTime paymentDate;
  final String? notes;
}

class UpdatePaymentInput {
  const UpdatePaymentInput({
    required this.partyId,
    this.dealId,
    required this.type,
    required this.amountPaise,
    this.method,
    required this.paymentDate,
    this.notes,
  });

  final String partyId;
  final String? dealId;
  final PaymentTypeValue type;
  final int amountPaise;
  final String? method;
  final DateTime paymentDate;
  final String? notes;
}

class CreateExpenseInput {
  const CreateExpenseInput({
    required this.category,
    required this.amountPaise,
    required this.expenseDate,
    this.notes,
  });

  final ExpenseCategoryValue category;
  final int amountPaise;
  final DateTime expenseDate;
  final String? notes;
}

class UpdateExpenseInput {
  const UpdateExpenseInput({
    required this.category,
    required this.amountPaise,
    required this.expenseDate,
    this.notes,
  });

  final ExpenseCategoryValue category;
  final int amountPaise;
  final DateTime expenseDate;
  final String? notes;
}

class MoneyLedgerSnapshot {
  const MoneyLedgerSnapshot({
    required this.totalReceivablePaise,
    required this.totalPayablePaise,
    required this.parties,
  });

  final int totalReceivablePaise;
  final int totalPayablePaise;
  final List<MoneyLedgerParty> parties;

  int get netPaise => totalReceivablePaise - totalPayablePaise;

  List<MoneyLedgerParty> get receivableParties {
    return parties.where((party) => party.receivablePaise > 0).toList();
  }

  List<MoneyLedgerParty> get payableParties {
    return parties.where((party) => party.payablePaise > 0).toList();
  }
}

class MoneyLedgerParty {
  const MoneyLedgerParty({
    required this.partyId,
    required this.name,
    this.phone,
    required this.type,
    required this.receivablePaise,
    required this.payablePaise,
    required this.overdueAmountPaise,
    required this.dealCount,
    this.oldestOverdueDate,
    this.lastActivityAt,
  });

  final String partyId;
  final String name;
  final String? phone;
  final String type;
  final int receivablePaise;
  final int payablePaise;
  final int overdueAmountPaise;
  final int dealCount;
  final DateTime? oldestOverdueDate;
  final DateTime? lastActivityAt;

  int get netPaise => receivablePaise - payablePaise;
}

class ExpenseSummary {
  const ExpenseSummary({
    required this.byCategoryPaise,
    required this.totalPaise,
    required this.periodComparison,
  });

  factory ExpenseSummary.empty() {
    return ExpenseSummary(
      byCategoryPaise: {
        for (final category in ExpenseCategoryValue.values) category: 0,
      },
      totalPaise: 0,
      periodComparison: 0,
    );
  }

  final Map<ExpenseCategoryValue, int> byCategoryPaise;
  final int totalPaise;
  final double periodComparison;
}

int moneyTextToPaise(String value) {
  return decimalRupeesToPaise(value.trim().replaceAll(',', ''));
}
