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

double flowMultiplier(int cleanPasses) {
  if (cleanPasses >= 15) return 3;
  if (cleanPasses >= 8) return 2;
  if (cleanPasses >= 3) return 1.5;
  return 1;
}

int cleanPassReward(int cleanPasses, {required bool nearMiss}) {
  final double base = nearMiss ? 180 : 100;
  return (base * flowMultiplier(cleanPasses)).round();
}
