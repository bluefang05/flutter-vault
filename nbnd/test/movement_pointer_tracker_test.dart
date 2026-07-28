import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/game/controls/movement_pointer_tracker.dart';

void main() {
  test('releasing one finger keeps the other lateral movement active', () {
    final MovementPointerTracker tracker = MovementPointerTracker()
      ..press(1, ControlPointerZone.counterClockwise)
      ..press(2, ControlPointerZone.clockwise);

    tracker.release(2);

    expect(tracker.movementDirection, -1);
  });

  test('the most recent lateral touch wins while both sides are active', () {
    final MovementPointerTracker tracker = MovementPointerTracker()
      ..press(1, ControlPointerZone.clockwise)
      ..press(2, ControlPointerZone.counterClockwise);

    expect(tracker.movementDirection, -1);
    tracker.release(2);
    expect(tracker.movementDirection, 1);
  });

  test('a center touch does not cancel held lateral movement', () {
    final MovementPointerTracker tracker = MovementPointerTracker()
      ..press(1, ControlPointerZone.clockwise)
      ..press(2, ControlPointerZone.power);

    expect(tracker.movementDirection, 1);
    tracker.release(2);
    expect(tracker.movementDirection, 1);
  });
}
