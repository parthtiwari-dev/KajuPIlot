import '../../core/utils/currency.dart';

enum AiPreviewKind {
  task('task', 'Task'),
  deal('deal', 'Deal'),
  payment('payment', 'Payment'),
  expense('expense', 'Expense');

  const AiPreviewKind(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AiPreviewKind fromApi(String value) {
    return AiPreviewKind.values.firstWhere(
      (kind) => kind.apiValue == value,
      orElse: () => AiPreviewKind.task,
    );
  }
}

class AiPartyMatch {
  const AiPartyMatch({
    required this.status,
    this.partyId,
    this.name,
    this.candidates = const [],
  });

  factory AiPartyMatch.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};
    return AiPartyMatch(
      status: data['status'] as String? ?? 'missing',
      partyId: data['partyId'] as String?,
      name: data['name'] as String?,
      candidates: (data['candidates'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(
            (candidate) => AiPartyCandidate(
              id: candidate['id'] as String? ?? '',
              name: candidate['name'] as String? ?? 'Unknown',
              phone: candidate['phone'] as String?,
            ),
          )
          .toList(),
    );
  }

  final String status;
  final String? partyId;
  final String? name;
  final List<AiPartyCandidate> candidates;
}

class AiPartyCandidate {
  const AiPartyCandidate({
    required this.id,
    required this.name,
    this.phone,
  });

  final String id;
  final String name;
  final String? phone;
}

class AiDealLinePreview {
  const AiDealLinePreview({
    required this.grade,
    required this.quantityText,
    this.rateText,
    required this.totalPaise,
  });

  factory AiDealLinePreview.fromJson(Map<String, dynamic> json) {
    return AiDealLinePreview(
      grade: json['grade'] as String? ?? '',
      quantityText: json['quantityText'] as String? ?? '',
      rateText: json['rateText'] as String?,
      totalPaise: (json['totalPaise'] as num?)?.toInt() ?? 0,
    );
  }

  final String grade;
  final String quantityText;
  final String? rateText;
  final int totalPaise;

  Map<String, Object?> toPayload() {
    return {
      'grade': grade,
      'quantityText': quantityText,
      'rateText': rateText,
      'totalPaise': totalPaise,
    }..removeWhere((_, value) => value == null);
  }

  AiDealLinePreview copyWith({
    String? grade,
    String? quantityText,
    String? rateText,
    int? totalPaise,
  }) {
    return AiDealLinePreview(
      grade: grade ?? this.grade,
      quantityText: quantityText ?? this.quantityText,
      rateText: rateText ?? this.rateText,
      totalPaise: totalPaise ?? this.totalPaise,
    );
  }
}

class AiPreviewItem {
  const AiPreviewItem({
    required this.kind,
    required this.tempId,
    this.partyName,
    this.partyId,
    this.partyMatch,
    this.type,
    this.title,
    this.notes,
    this.scheduledAt,
    this.priority = 0,
    this.items = const [],
    this.totalPaise = 0,
    this.paidPaise = 0,
    this.deliveryDate,
    this.paymentDue,
    this.amountPaise = 0,
    this.method,
    this.paymentDate,
    this.category,
    this.scope,
    this.expenseDate,
    this.needsReview = false,
    this.warnings = const [],
  });

  factory AiPreviewItem.fromJson(
    AiPreviewKind kind,
    Map<String, dynamic> json,
  ) {
    return AiPreviewItem(
      kind: kind,
      tempId: json['tempId'] as String? ?? '${kind.apiValue}-preview',
      partyName: json['partyName'] as String?,
      partyId: json['partyId'] as String?,
      partyMatch:
          AiPartyMatch.fromJson(json['partyMatch'] as Map<String, dynamic>?),
      type: json['type'] as String?,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      scheduledAt: _dateOrNull(json['scheduledAt']),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AiDealLinePreview.fromJson)
          .toList(),
      totalPaise: (json['totalPaise'] as num?)?.toInt() ?? 0,
      paidPaise: (json['paidPaise'] as num?)?.toInt() ?? 0,
      deliveryDate: _dateOrNull(json['deliveryDate']),
      paymentDue: _dateOrNull(json['paymentDue']),
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      method: json['method'] as String?,
      paymentDate: _dateOrNull(json['paymentDate']),
      category: json['category'] as String?,
      scope: json['scope'] as String?,
      expenseDate: _dateOrNull(json['expenseDate']),
      needsReview: json['needsReview'] as bool? ?? false,
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((warning) => warning.toString())
          .where((warning) => warning.trim().isNotEmpty)
          .toList(),
    );
  }

  final AiPreviewKind kind;
  final String tempId;
  final String? partyName;
  final String? partyId;
  final AiPartyMatch? partyMatch;
  final String? type;
  final String? title;
  final String? notes;
  final DateTime? scheduledAt;
  final int priority;
  final List<AiDealLinePreview> items;
  final int totalPaise;
  final int paidPaise;
  final DateTime? deliveryDate;
  final DateTime? paymentDue;
  final int amountPaise;
  final String? method;
  final DateTime? paymentDate;
  final String? category;
  final String? scope;
  final DateTime? expenseDate;
  final bool needsReview;
  final List<String> warnings;

  int get displayAmountPaise {
    if (kind == AiPreviewKind.deal) {
      return totalPaise;
    }
    if (kind == AiPreviewKind.payment || kind == AiPreviewKind.expense) {
      return amountPaise;
    }
    return amountPaise;
  }

  String get summary {
    return switch (kind) {
      AiPreviewKind.task => title ?? 'Task',
      AiPreviewKind.deal => items.isEmpty
          ? 'Deal'
          : '${items.first.grade} ${items.first.quantityText}'.trim(),
      AiPreviewKind.payment =>
        '${type ?? 'PAYMENT'} ${formatInrFromPaise(amountPaise)}',
      AiPreviewKind.expense =>
        '${scope ?? 'BUSINESS'} expense ${formatInrFromPaise(amountPaise)}',
    };
  }

  AiPreviewItem copyWith({
    String? partyName,
    String? partyId,
    String? type,
    String? title,
    String? notes,
    DateTime? scheduledAt,
    int? priority,
    List<AiDealLinePreview>? items,
    int? totalPaise,
    int? paidPaise,
    DateTime? deliveryDate,
    DateTime? paymentDue,
    int? amountPaise,
    String? method,
    DateTime? paymentDate,
    String? category,
    String? scope,
    DateTime? expenseDate,
    bool? needsReview,
    List<String>? warnings,
  }) {
    return AiPreviewItem(
      kind: kind,
      tempId: tempId,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      partyMatch: partyMatch,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      priority: priority ?? this.priority,
      items: items ?? this.items,
      totalPaise: totalPaise ?? this.totalPaise,
      paidPaise: paidPaise ?? this.paidPaise,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentDue: paymentDue ?? this.paymentDue,
      amountPaise: amountPaise ?? this.amountPaise,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
      category: category ?? this.category,
      scope: scope ?? this.scope,
      expenseDate: expenseDate ?? this.expenseDate,
      needsReview: needsReview ?? this.needsReview,
      warnings: warnings ?? this.warnings,
    );
  }

  AiPreviewItem validated() {
    final nextWarnings = <String>[];
    if (kind != AiPreviewKind.expense &&
        (partyId == null || partyId!.isEmpty) &&
        (partyName == null || partyName!.trim().isEmpty)) {
      nextWarnings.add('Person is missing');
    }
    if (kind == AiPreviewKind.task) {
      if (title == null || title!.trim().isEmpty) {
        nextWarnings.add('Task title is missing');
      }
      if (scheduledAt == null) {
        nextWarnings.add('Task date/time needs review');
      }
    }
    if (kind == AiPreviewKind.deal) {
      if (items.isEmpty) {
        nextWarnings.add('Deal item is missing');
      }
      for (final item in items) {
        if (item.grade.trim().isEmpty) {
          nextWarnings.add('Deal grade is missing');
        }
        if (item.quantityText.trim().isEmpty) {
          nextWarnings.add('Deal quantity is missing');
        }
        if (item.totalPaise <= 0) {
          nextWarnings.add('Deal item total needs review');
        }
      }
      if (totalPaise <= 0) {
        nextWarnings.add('Deal total needs review');
      }
      if (paidPaise > totalPaise) {
        nextWarnings.add('Paid amount exceeds deal total');
      }
    }
    if (kind == AiPreviewKind.payment && amountPaise <= 0) {
      nextWarnings.add('Payment amount is missing');
    }
    if (kind == AiPreviewKind.expense && amountPaise <= 0) {
      nextWarnings.add('Expense amount is missing');
    }
    if (partyMatch?.status == 'ambiguous' && partyId == null) {
      nextWarnings.add('Choose the matching person');
    }
    return copyWith(
      needsReview: nextWarnings.isNotEmpty,
      warnings: nextWarnings,
    );
  }

  Map<String, Object?> toConfirmPayload() {
    final payload = <String, Object?>{
      'kind': kind.apiValue,
      'tempId': tempId,
      'partyId': partyId,
      'partyName': partyName,
      'type': type,
      'title': title,
      'notes': notes,
      'scheduledAt': scheduledAt?.toUtc().toIso8601String(),
      'priority': priority,
      'items': items.map((item) => item.toPayload()).toList(),
      'totalPaise': totalPaise,
      'paidPaise': paidPaise,
      'deliveryDate': deliveryDate?.toUtc().toIso8601String(),
      'paymentDue': paymentDue?.toUtc().toIso8601String(),
      'amountPaise': amountPaise,
      'method': method,
      'paymentDate': paymentDate?.toUtc().toIso8601String(),
      'category': category,
      'scope': scope,
      'expenseDate': expenseDate?.toUtc().toIso8601String(),
      'needsReview': needsReview,
      'warnings': warnings,
    };
    payload.removeWhere((_, value) {
      return value == null || (value is List && value.isEmpty);
    });
    return payload;
  }
}

class AiParseResult {
  const AiParseResult({
    required this.logId,
    required this.provider,
    required this.model,
    required this.items,
    required this.itemCount,
    required this.needsReviewCount,
  });

  factory AiParseResult.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsed'] as Map<String, dynamic>? ?? {};
    final items = <AiPreviewItem>[
      for (final entry in parsed.entries)
        ..._itemsFromEntry(entry.key, entry.value),
    ];
    return AiParseResult(
      logId: json['logId'] as String,
      provider: json['provider'] as String? ?? 'ai',
      model: json['model'] as String? ?? '',
      items: items,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? items.length,
      needsReviewCount: (json['needsReviewCount'] as num?)?.toInt() ??
          items.where((item) => item.needsReview).length,
    );
  }

  final String logId;
  final String provider;
  final String model;
  final List<AiPreviewItem> items;
  final int itemCount;
  final int needsReviewCount;
}

List<AiPreviewItem> _itemsFromEntry(String key, Object? value) {
  final kind = switch (key) {
    'tasks' => AiPreviewKind.task,
    'deals' => AiPreviewKind.deal,
    'payments' => AiPreviewKind.payment,
    'expenses' => AiPreviewKind.expense,
    _ => null,
  };
  if (kind == null || value is! List) {
    return const [];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map((json) => AiPreviewItem.fromJson(kind, json))
      .toList();
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString())?.toLocal();
}
