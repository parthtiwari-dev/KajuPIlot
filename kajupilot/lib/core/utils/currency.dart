import 'package:intl/intl.dart';

final NumberFormat _indianIntegerFormatter = NumberFormat.decimalPattern(
  'en_IN',
);

String formatInrFromPaise(
  int amountPaise, {
  bool showDecimals = false,
}) {
  final isNegative = amountPaise < 0;
  final absolutePaise = amountPaise.abs();
  final rupees = absolutePaise ~/ 100;
  final paise = absolutePaise % 100;
  final formattedRupees = _indianIntegerFormatter.format(rupees);
  final shouldShowDecimals = showDecimals || paise != 0;
  final formattedAmount = shouldShowDecimals
      ? '$formattedRupees.${paise.toString().padLeft(2, '0')}'
      : formattedRupees;

  return '${isNegative ? '-' : ''}₹$formattedAmount';
}

int rupeesToPaise(num rupees) {
  return (rupees * 100).round();
}

double paiseToRupees(int paise) {
  return paise / 100;
}

int decimalRupeesToPaise(Object? value) {
  final text = value?.toString().trim().replaceAll(',', '') ?? '0';
  if (text.isEmpty) {
    return 0;
  }

  final isNegative = text.startsWith('-');
  final unsigned = isNegative ? text.substring(1) : text;
  final parts = unsigned.split('.');
  final rupees = int.tryParse(parts.first) ?? 0;
  final paiseText = parts.length > 1 ? parts[1] : '';
  final paise = int.tryParse(
        paiseText.padRight(2, '0').substring(0, 2),
      ) ??
      0;
  final amount = (rupees * 100) + paise;

  return isNegative ? -amount : amount;
}

String paiseToDecimalRupeesString(int paise) {
  final isNegative = paise < 0;
  final absolutePaise = paise.abs();
  final rupees = absolutePaise ~/ 100;
  final decimalPaise = absolutePaise % 100;

  return '${isNegative ? '-' : ''}$rupees.${decimalPaise.toString().padLeft(2, '0')}';
}

String formatIndianNumber(num value) {
  return _indianIntegerFormatter.format(value);
}
