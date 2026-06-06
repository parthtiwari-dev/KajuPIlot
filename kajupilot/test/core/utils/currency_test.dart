import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/core/utils/currency.dart';

void main() {
  group('currency helpers', () {
    test('formats paise as Indian rupees without decimals by default', () {
      expect(formatInrFromPaise(10000000), '₹1,00,000');
      expect(formatInrFromPaise(78000), '₹780');
    });

    test('keeps decimal paise when present', () {
      expect(formatInrFromPaise(1234567), '₹12,345.67');
      expect(formatInrFromPaise(-1234567), '-₹12,345.67');
    });

    test('converts rupees and paise', () {
      expect(rupeesToPaise(780), 78000);
      expect(rupeesToPaise(12.34), 1234);
      expect(paiseToRupees(1234), 12.34);
    });
  });
}
