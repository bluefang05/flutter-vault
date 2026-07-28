import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/game/game_math.dart';

void main() {
  test('normalizeAngle keeps values inside one revolution', () {
    expect(normalizeAngle(-math.pi / 2), closeTo(math.pi * 1.5, .0001));
    expect(normalizeAngle(math.pi * 5), closeTo(math.pi, .0001));
  });

  test('angleInsideGap supports wraparound', () {
    expect(
      angleInsideGap(
        angle: 0.02,
        centers: <double>[math.pi * 2 - .02],
        width: .2,
      ),
      isTrue,
    );
  });
}
