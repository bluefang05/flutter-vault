import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/game/rewind_helpers.dart';

void main() {
  test('snapshot restoration removes entities created after the snapshot', () {
    final List<int> currentEntities = <int>[1, 2, 3, 4];

    restoreSnapshotList<int, int>(
      target: currentEntities,
      snapshots: const <int>[10, 20],
      restore: (int value) => value,
    );

    expect(currentEntities, <int>[10, 20]);
  });
}
