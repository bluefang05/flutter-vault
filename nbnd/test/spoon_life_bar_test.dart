import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/widgets/spoon_life_bar.dart';

void main() {
  test('spoon bar maps half units to full, half and empty assets', () {
    expect(
      spoonFillStateForIndex(index: 0, currentHalves: 5),
      SpoonFillState.full,
    );
    expect(
      spoonFillStateForIndex(index: 1, currentHalves: 5),
      SpoonFillState.full,
    );
    expect(
      spoonFillStateForIndex(index: 2, currentHalves: 5),
      SpoonFillState.half,
    );
    expect(
      spoonFillStateForIndex(index: 3, currentHalves: 5),
      SpoonFillState.empty,
    );
  });
}
