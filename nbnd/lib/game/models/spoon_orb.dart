class SpoonOrb {
  SpoonOrb({
    required this.radius,
    required this.angle,
    required this.inwardSpeed,
    required this.angularSpeed,
  });

  double radius;
  double angle;
  final double inwardSpeed;
  final double angularSpeed;
  bool resolved = false;

  void update(double dt) {
    radius -= inwardSpeed * dt;
    angle += angularSpeed * dt;
  }
}
