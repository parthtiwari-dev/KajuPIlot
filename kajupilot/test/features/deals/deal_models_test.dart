import 'package:flutter_test/flutter_test.dart';
import 'package:kajupilot/features/deals/data/deal_models.dart';

void main() {
  group('bucket-wise deal helpers', () {
    test('sums manual line totals', () {
      expect(
        sumLineTotals(
          const [
            DealLineInput(
              grade: 'W320',
              quantityText: '10 balti',
              lineTotalPaise: 3900000,
            ),
            DealLineInput(
              grade: 'W240',
              quantityText: '5 balti',
              lineTotalPaise: 1800000,
            ),
          ],
        ),
        5700000,
      );
    });

    test('summarizes one or many grades', () {
      expect(
        dealGradeSummary(
          const [
            DealLineInput(
              grade: 'W320',
              quantityText: '10 balti',
              lineTotalPaise: 3900000,
            ),
          ],
        ),
        'W320',
      );
      expect(
        dealGradeSummary(
          const [
            DealLineInput(
              grade: 'W320',
              quantityText: '10 balti',
              lineTotalPaise: 3900000,
            ),
            DealLineInput(
              grade: 'W240',
              quantityText: '5 balti',
              lineTotalPaise: 1800000,
            ),
          ],
        ),
        'W320 + 1',
      );
    });

    test('parses rupee text to paise', () {
      expect(rupeeTextToPaise('39,000'), 3900000);
      expect(rupeeTextToPaise('780.50'), 78050);
    });
  });
}
