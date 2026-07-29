import 'dart:math' as math;

import '../models/neuro_type.dart';
import 'models/collision_result.dart';

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

int recoverSpoonHalf({required int currentHalves, required int maxHalves}) {
  return math.min(maxHalves, currentHalves + 1);
}

double polarDistance({
  required double firstRadius,
  required double firstAngle,
  required double secondRadius,
  required double secondAngle,
}) {
  final double angle = angularDistance(firstAngle, secondAngle);
  return math.sqrt(
    firstRadius * firstRadius +
        secondRadius * secondRadius -
        2 * firstRadius * secondRadius * math.cos(angle),
  );
}

bool sweptRingTouchesPlayer({
  required double previousRadius,
  required double currentRadius,
  required double ringThickness,
  required double playerRadius,
  required double playerRadialHalfSize,
}) {
  final double sweptOuter =
      math.max(previousRadius, currentRadius) + ringThickness / 2;
  final double sweptInner =
      math.min(previousRadius, currentRadius) - ringThickness / 2;
  final double playerInner = playerRadius - playerRadialHalfSize;
  final double playerOuter = playerRadius + playerRadialHalfSize;
  return sweptOuter >= playerInner && sweptInner <= playerOuter;
}

RingCollisionAssessment assessRingCollision({
  required double previousRadius,
  required double currentRadius,
  required double ringThickness,
  required double playerRadius,
  required double playerRadialHalfSize,
  required double playerAngle,
  required double playerHalfAngle,
  required Iterable<double> gapCenters,
  required double gapWidth,
  double lightHitThreshold = .12,
  double nearMissThreshold = .10,
}) {
  if (!sweptRingTouchesPlayer(
    previousRadius: previousRadius,
    currentRadius: currentRadius,
    ringThickness: ringThickness,
    playerRadius: playerRadius,
    playerRadialHalfSize: playerRadialHalfSize,
  )) {
    return const RingCollisionAssessment.none();
  }

  final double nearestDistance = gapCenters
      .map((double gap) => angularDistance(playerAngle, gap))
      .fold<double>(double.infinity, math.min);
  final double safeHalfWidth = math.max(0, gapWidth / 2 - playerHalfAngle);
  final double outsideMargin = nearestDistance - safeHalfWidth;
  if (outsideMargin <= 0) {
    return RingCollisionAssessment(
      contact: RingContact.safe,
      nearestGapDistance: nearestDistance,
      safeHalfWidth: safeHalfWidth,
      outsideMargin: outsideMargin,
      nearMiss: -outsideMargin <= nearMissThreshold,
    );
  }

  return RingCollisionAssessment(
    contact: outsideMargin <= lightHitThreshold
        ? RingContact.lightHit
        : RingContact.strongHit,
    nearestGapDistance: nearestDistance,
    safeHalfWidth: safeHalfWidth,
    outsideMargin: outsideMargin,
    nearMiss: false,
  );
}

RingResolution resolveRingContact({
  required RingCollisionAssessment assessment,
  required bool alreadyProcessed,
  required bool powerImmune,
  required bool damageGrace,
}) {
  if (alreadyProcessed || assessment.contact == RingContact.none) {
    return const RingResolution.none();
  }
  if (damageGrace) {
    return const RingResolution(
      outcome: RingOutcome.damageGrace,
      processed: true,
      damageHalves: 0,
      awardsCleanPass: false,
      nearMiss: false,
    );
  }
  if (powerImmune) {
    return const RingResolution(
      outcome: RingOutcome.powerProtected,
      processed: true,
      damageHalves: 0,
      awardsCleanPass: true,
      nearMiss: false,
    );
  }
  return switch (assessment.contact) {
    RingContact.none => const RingResolution.none(),
    RingContact.safe => RingResolution(
      outcome: RingOutcome.cleanPass,
      processed: true,
      damageHalves: 0,
      awardsCleanPass: true,
      nearMiss: assessment.nearMiss,
    ),
    RingContact.lightHit => const RingResolution(
      outcome: RingOutcome.lightHit,
      processed: true,
      damageHalves: 1,
      awardsCleanPass: false,
      nearMiss: false,
    ),
    RingContact.strongHit => const RingResolution(
      outcome: RingOutcome.strongHit,
      processed: true,
      damageHalves: 2,
      awardsCleanPass: false,
      nearMiss: false,
    ),
  };
}

int spoonHalvesAfterDamage({
  required int currentHalves,
  required int damageHalves,
}) {
  return math.max(0, currentHalves - damageHalves);
}

bool hasSufficientRewindHistory(int snapshotCount, {int minimum = 10}) {
  return snapshotCount >= minimum;
}

bool abilityHasEffect({
  required NeuroType neuroType,
  required int targetCount,
  required int historyCount,
}) {
  return switch (neuroType) {
    NeuroType.tlp || NeuroType.toc => targetCount > 0,
    NeuroType.tag => hasSufficientRewindHistory(historyCount),
    _ => true,
  };
}

bool hasMinimumRingSeparation({
  required double spawnRadius,
  required double spawnThickness,
  required Iterable<double> existingOuterEdges,
  required double minimumSeparation,
}) {
  if (existingOuterEdges.isEmpty) return true;
  final double spawnInnerEdge = spawnRadius - spawnThickness / 2;
  final double outermostExistingEdge = existingOuterEdges.reduce(math.max);
  return spawnInnerEdge - outermostExistingEdge >= minimumSeparation;
}
