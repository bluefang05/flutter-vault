enum RingContact { none, safe, lightHit, strongHit }

enum RingOutcome {
  none,
  cleanPass,
  powerProtected,
  damageGrace,
  lightHit,
  strongHit,
}

class RingCollisionAssessment {
  const RingCollisionAssessment({
    required this.contact,
    required this.nearestGapDistance,
    required this.safeHalfWidth,
    required this.outsideMargin,
    required this.nearMiss,
  });

  const RingCollisionAssessment.none()
    : contact = RingContact.none,
      nearestGapDistance = double.infinity,
      safeHalfWidth = 0,
      outsideMargin = double.infinity,
      nearMiss = false;

  final RingContact contact;
  final double nearestGapDistance;
  final double safeHalfWidth;
  final double outsideMargin;
  final bool nearMiss;
}

class RingResolution {
  const RingResolution({
    required this.outcome,
    required this.processed,
    required this.damageHalves,
    required this.awardsCleanPass,
    required this.nearMiss,
  });

  const RingResolution.none()
    : outcome = RingOutcome.none,
      processed = false,
      damageHalves = 0,
      awardsCleanPass = false,
      nearMiss = false;

  final RingOutcome outcome;
  final bool processed;
  final int damageHalves;
  final bool awardsCleanPass;
  final bool nearMiss;
}
