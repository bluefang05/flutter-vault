enum ControlPointerZone { counterClockwise, clockwise, power }

class MovementPointerTracker {
  final Map<int, _TrackedPointer> _pointers = <int, _TrackedPointer>{};
  int _sequence = 0;

  void press(int pointerId, ControlPointerZone zone) {
    _pointers[pointerId] = _TrackedPointer(zone, _sequence++);
  }

  void release(int pointerId) {
    _pointers.remove(pointerId);
  }

  void clear() {
    _pointers.clear();
  }

  double get movementDirection {
    _TrackedPointer? latest;
    for (final _TrackedPointer pointer in _pointers.values) {
      if (pointer.zone == ControlPointerZone.power) continue;
      if (latest == null || pointer.sequence > latest.sequence) {
        latest = pointer;
      }
    }
    return switch (latest?.zone) {
      ControlPointerZone.counterClockwise => -1,
      ControlPointerZone.clockwise => 1,
      _ => 0,
    };
  }

  bool get hasLateralPointer => _pointers.values.any(
    (_TrackedPointer pointer) => pointer.zone != ControlPointerZone.power,
  );
}

class _TrackedPointer {
  const _TrackedPointer(this.zone, this.sequence);

  final ControlPointerZone zone;
  final int sequence;
}
