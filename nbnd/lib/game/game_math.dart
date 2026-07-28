import 'dart:math' as math;

double normalizeAngle(double angle) {
  final double normalized = angle % (math.pi * 2);
  return normalized < 0 ? normalized + math.pi * 2 : normalized;
}

double signedAngularDifference(double a, double b) {
  return (a - b + math.pi) % (math.pi * 2) - math.pi;
}

double angularDistance(double a, double b) {
  return signedAngularDifference(a, b).abs();
}

bool angleInsideGap({
  required double angle,
  required Iterable<double> centers,
  required double width,
}) {
  return centers.any(
    (double center) => angularDistance(angle, center) <= width / 2,
  );
}
