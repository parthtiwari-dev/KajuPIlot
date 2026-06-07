import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/dates.dart';
import '../deals/data/deals_repository.dart';
import '../money/data/expenses_repository.dart';
import '../money/data/payments_repository.dart';
import '../people/data/parties_repository.dart';
import '../today/data/tasks_repository.dart';
import 'ai_parse_models.dart';
import 'ai_parser_api.dart';

final aiParserApiProvider = Provider<AiParserApi>((ref) {
  return AiParserApi(ref.watch(apiClientProvider));
});

final aiParserRepositoryProvider = Provider<AiParserRepository>((ref) {
  return AiParserRepository(
    api: ref.watch(aiParserApiProvider),
    onConfirmed: () async {
      final today = dateOnly(DateTime.now());
      await Future.wait([
        _ignoreRefresh(ref.read(partiesRepositoryProvider).refresh(
              flushPending: false,
            )),
        _ignoreRefresh(ref.read(expensesRepositoryProvider).refresh(
              flushPending: false,
            )),
        _ignoreRefresh(ref.read(tasksRepositoryProvider).refreshToday(
              today,
              flushPending: false,
            )),
      ]);
      await _ignoreRefresh(ref.read(dealsRepositoryProvider).refresh(
            flushPending: false,
          ));
      await _ignoreRefresh(ref.read(paymentsRepositoryProvider).refresh(
            flushPending: false,
          ));
      ref.invalidate(todayInsightsProvider(today));
    },
  );
});

class AiParserRepository {
  const AiParserRepository({
    required AiParserApi api,
    required Future<void> Function() onConfirmed,
  })  : _api = api,
        _onConfirmed = onConfirmed;

  final AiParserApi _api;
  final Future<void> Function() _onConfirmed;

  Future<AiParseResult> parse(String text) {
    return _api.parse(
      text: text,
      localDate: DateTime.now(),
      timezone: 'Asia/Kolkata',
    );
  }

  Future<int> confirm({
    required String logId,
    required List<AiPreviewItem> items,
  }) async {
    final validItems = items.map((item) => item.validated()).toList();
    if (validItems.any((item) => item.needsReview)) {
      throw StateError('Resolve AI preview warnings before confirming.');
    }

    await _api.confirm(logId: logId, items: validItems);
    await _onConfirmed();
    return validItems.length;
  }
}

Future<void> _ignoreRefresh(Future<void> future) async {
  try {
    await future;
  } catch (_) {
    // Confirm already succeeded; the next screen refresh/app resume will retry.
  }
}
