import 'dart:math' as math;

class DifficultyCurve {
  const DifficultyCurve._();

  static double multiplier(double elapsedSeconds) {
    final double seconds = math.max(0, elapsedSeconds);
    if (seconds < 20) {
      return _smoothSegment(seconds, 0, 20, .72, .82);
    }
    if (seconds < 45) {
      return _smoothSegment(seconds, 20, 45, .82, 1);
    }
    if (seconds < 90) {
      return _smoothSegment(seconds, 45, 90, 1, 1.25);
    }
    if (seconds < 180) {
      return _smoothSegment(seconds, 90, 180, 1.25, 1.7);
    }
    return math.min(1.9, 1.7 + ((seconds - 180) / 300));
  }

  static double spawnInterval(double elapsedSeconds) {
    final double seconds = math.max(0, elapsedSeconds);
    if (seconds < 20) {
      return _smoothSegment(seconds, 0, 20, 1.8, 1.62);
    }
    if (seconds < 45) {
      return _smoothSegment(seconds, 20, 45, 1.62, 1.4);
    }
    if (seconds < 90) {
      return _smoothSegment(seconds, 45, 90, 1.4, 1.12);
    }
    if (seconds < 180) {
      return _smoothSegment(seconds, 90, 180, 1.12, .76);
    }
    return math.max(.62, .76 - ((seconds - 180) * .0007));
  }

  static double gapReduction(double elapsedSeconds) {
    final double seconds = math.max(0, elapsedSeconds);
    if (seconds <= 25) return 0;
    return math.min(.34, (seconds - 25) * .00115);
  }

  static bool isBreathing(double elapsedSeconds) {
    if (elapsedSeconds < 18) return false;
    final double cycle = (elapsedSeconds - 18) % 24;
    return cycle >= 18 && cycle < 22;
  }

  static String stage(double elapsedSeconds) {
    if (elapsedSeconds < 35) return 'pulse';
    if (elapsedSeconds < 85) return 'resonance';
    return 'fracture';
  }

  static double _smoothSegment(
    double value,
    double start,
    double end,
    double from,
    double to,
  ) {
    final double t = ((value - start) / (end - start))
        .clamp(0.0, 1.0)
        .toDouble();
    final double smooth = t * t * (3 - (2 * t));
    return from + ((to - from) * smooth);
  }
}
