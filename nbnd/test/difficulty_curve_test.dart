import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/game/difficulty_curve.dart';

void main() {
  group('DifficultyCurve', () {
    test('starts gently and scales without abrupt jumps', () {
      expect(DifficultyCurve.multiplier(0), closeTo(.72, .001));
      expect(DifficultyCurve.multiplier(20), closeTo(.82, .001));
      expect(DifficultyCurve.multiplier(45), closeTo(1, .001));
      expect(DifficultyCurve.multiplier(90), closeTo(1.25, .001));
      expect(DifficultyCurve.multiplier(180), closeTo(1.7, .001));

      double previous = DifficultyCurve.multiplier(0);
      for (int second = 1; second <= 600; second++) {
        final double current = DifficultyCurve.multiplier(second.toDouble());
        expect(current, greaterThanOrEqualTo(previous));
        expect(current - previous, lessThan(.02));
        previous = current;
      }
    });

    test('gives more space early and keeps a safe lower limit', () {
      expect(DifficultyCurve.spawnInterval(0), closeTo(1.8, .001));
      expect(DifficultyCurve.spawnInterval(45), closeTo(1.4, .001));
      expect(DifficultyCurve.spawnInterval(180), closeTo(.76, .001));
      expect(DifficultyCurve.spawnInterval(10000), closeTo(.62, .001));
    });

    test('does not narrow gaps during the introduction', () {
      expect(DifficultyCurve.gapReduction(25), 0);
      expect(DifficultyCurve.gapReduction(45), closeTo(.023, .001));
      expect(DifficultyCurve.gapReduction(10000), closeTo(.34, .001));
    });

    test('delays stages and schedules regular breathing windows', () {
      expect(DifficultyCurve.stage(34.9), 'pulse');
      expect(DifficultyCurve.stage(35), 'resonance');
      expect(DifficultyCurve.stage(85), 'fracture');

      expect(DifficultyCurve.isBreathing(35.9), isFalse);
      expect(DifficultyCurve.isBreathing(36), isTrue);
      expect(DifficultyCurve.isBreathing(39.9), isTrue);
      expect(DifficultyCurve.isBreathing(40), isFalse);
    });
  });
}
