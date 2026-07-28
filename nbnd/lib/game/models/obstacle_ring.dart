import '../game_math.dart';

class ObstacleRing {
  ObstacleRing({
    required this.radius,
    required this.thickness,
    required this.gapCenters,
    required this.gapWidth,
    required this.inwardSpeed,
    required this.rotationSpeed,
    this.preview = false,
  }) : previousRadius = radius;

  double radius;
  double previousRadius;
  double thickness;
  final List<double> gapCenters;
  double gapWidth;
  double inwardSpeed;
  double rotationSpeed;
  bool preview;
  bool checkedCollision = false;
  bool resolved = false;

  void update(double dt, {required bool freezeRotation}) {
    previousRadius = radius;
    radius -= inwardSpeed * dt;
    if (!freezeRotation) {
      for (int index = 0; index < gapCenters.length; index++) {
        gapCenters[index] = normalizeAngle(
          gapCenters[index] + rotationSpeed * dt,
        );
      }
    }
  }

  bool isAngleSafe(double angle) {
    return angleInsideGap(angle: angle, centers: gapCenters, width: gapWidth);
  }
}
