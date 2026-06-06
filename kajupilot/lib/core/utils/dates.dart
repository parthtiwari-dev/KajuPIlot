import 'package:intl/intl.dart';

DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isToday(DateTime value, {DateTime? now}) {
  return dateOnly(value).isAtSameMomentAs(dateOnly(now ?? DateTime.now()));
}

bool isBeforeToday(DateTime value, {DateTime? now}) {
  return dateOnly(value).isBefore(dateOnly(now ?? DateTime.now()));
}

String formatKajuDate(DateTime value) {
  return DateFormat('dd MMM yyyy').format(value);
}
