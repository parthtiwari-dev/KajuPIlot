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

String formatIndianNumber(num value) {
  return _indianIntegerFormatter.format(value);
}
