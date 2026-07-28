import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/game/game_math.dart';
import 'package:nbnd/game/models/collision_result.dart';
import 'package:nbnd/models/neuro_type.dart';

void main() {
  test('normalizeAngle keeps values inside one revolution', () {
    expect(normalizeAngle(-math.pi / 2), closeTo(math.pi * 1.5, .0001));
    expect(normalizeAngle(math.pi * 5), closeTo(math.pi, .0001));
  });

  test('angleInsideGap supports wraparound', () {
    expect(
      angleInsideGap(
        angle: 0.02,
        centers: <double>[math.pi * 2 - .02],
        width: .2,
      ),
      isTrue,
    );
  });

  test('flow multiplier grows at deliberate streak thresholds', () {
    expect(flowMultiplier(0), 1);
    expect(flowMultiplier(3), 1.5);
    expect(flowMultiplier(8), 2);
    expect(flowMultiplier(15), 3);
  });

  test('near misses reward precision without changing the multiplier', () {
    expect(cleanPassReward(3, nearMiss: false), 150);
    expect(cleanPassReward(3, nearMiss: true), 270);
  });

  test('spoon recovery adds one half without exceeding the reserve', () {
    expect(recoverSpoonHalf(currentHalves: 5, maxHalves: 8), 6);
    expect(recoverSpoonHalf(currentHalves: 8, maxHalves: 8), 8);
  });

  test('polar distance handles radial and angular separation', () {
    expect(
      polarDistance(
        firstRadius: 100,
        firstAngle: 0,
        secondRadius: 120,
        secondAngle: 0,
      ),
      closeTo(20, .0001),
    );
    expect(
      polarDistance(
        firstRadius: 100,
        firstAngle: 0,
        secondRadius: 100,
        secondAngle: math.pi,
      ),
      closeTo(200, .0001),
    );
  });

  group('swept ring collision', () {
    RingCollisionAssessment assess({required double playerAngle}) {
      return assessRingCollision(
        previousRadius: 145,
        currentRadius: 65,
        ringThickness: 16,
        playerRadius: 100,
        playerRadialHalfSize: 12,
        playerAngle: playerAngle,
        playerHalfAngle: .2,
        gapCenters: const <double>[0],
        gapWidth: 1,
      );
    }

    test('detects a ring that tunnels across the player in one frame', () {
      expect(
        sweptRingTouchesPlayer(
          previousRadius: 145,
          currentRadius: 65,
          ringThickness: 16,
          playerRadius: 100,
          playerRadialHalfSize: 12,
        ),
        isTrue,
      );
      expect(assess(playerAngle: 0).contact, RingContact.safe);
    });

    test('player completely inside the effective opening is safe', () {
      expect(assess(playerAngle: .1).contact, RingContact.safe);
    });

    test('player angular width reduces the useful opening', () {
      expect(assess(playerAngle: 0).safeHalfWidth, closeTo(.3, .0001));
    });

    test('small edge invasion is a light hit', () {
      final RingCollisionAssessment result = assess(playerAngle: .38);
      expect(result.outsideMargin, closeTo(.08, .0001));
      expect(result.contact, RingContact.lightHit);
    });

    test('deep invasion is a strong hit', () {
      expect(assess(playerAngle: .52).contact, RingContact.strongHit);
    });

    test('near miss only occurs while still inside the opening', () {
      expect(assess(playerAngle: .25).nearMiss, isTrue);
      expect(assess(playerAngle: .34).nearMiss, isFalse);
    });
  });

  group('ring resolution', () {
    const RingCollisionAssessment light = RingCollisionAssessment(
      contact: RingContact.lightHit,
      nearestGapDistance: .38,
      safeHalfWidth: .3,
      outsideMargin: .08,
      nearMiss: false,
    );
    const RingCollisionAssessment strong = RingCollisionAssessment(
      contact: RingContact.strongHit,
      nearestGapDistance: .6,
      safeHalfWidth: .3,
      outsideMargin: .3,
      nearMiss: false,
    );

    test('light and strong hits remove one and two halves', () {
      final RingResolution lightResult = resolveRingContact(
        assessment: light,
        alreadyProcessed: false,
        powerImmune: false,
        damageGrace: false,
      );
      final RingResolution strongResult = resolveRingContact(
        assessment: strong,
        alreadyProcessed: false,
        powerImmune: false,
        damageGrace: false,
      );
      expect(lightResult.damageHalves, 1);
      expect(strongResult.damageHalves, 2);
      expect(spoonHalvesAfterDamage(currentHalves: 5, damageHalves: 1), 4);
      expect(spoonHalvesAfterDamage(currentHalves: 5, damageHalves: 2), 3);
      expect(spoonHalvesAfterDamage(currentHalves: 1, damageHalves: 2), 0);
    });

    test('an already processed ring cannot deal damage twice', () {
      final RingResolution result = resolveRingContact(
        assessment: strong,
        alreadyProcessed: true,
        powerImmune: false,
        damageGrace: false,
      );
      expect(result.processed, isFalse);
      expect(result.damageHalves, 0);
    });

    test('damage grace processes without points or combo', () {
      final RingResolution result = resolveRingContact(
        assessment: strong,
        alreadyProcessed: false,
        powerImmune: false,
        damageGrace: true,
      );
      expect(result.outcome, RingOutcome.damageGrace);
      expect(result.awardsCleanPass, isFalse);
      expect(result.damageHalves, 0);
    });

    test('power immunity protects and awards only a normal pass', () {
      final RingResolution result = resolveRingContact(
        assessment: strong,
        alreadyProcessed: false,
        powerImmune: true,
        damageGrace: false,
      );
      expect(result.outcome, RingOutcome.powerProtected);
      expect(result.damageHalves, 0);
      expect(result.awardsCleanPass, isTrue);
      expect(result.nearMiss, isFalse);
    });
  });

  test('TAG requires enough snapshots before rewind is available', () {
    expect(hasSufficientRewindHistory(0), isFalse);
    expect(hasSufficientRewindHistory(9), isFalse);
    expect(hasSufficientRewindHistory(10), isTrue);
  });

  test('targeted powers are unavailable when they cannot have an effect', () {
    expect(
      abilityHasEffect(
        neuroType: NeuroType.toc,
        targetCount: 0,
        historyCount: 0,
      ),
      isFalse,
    );
    expect(
      abilityHasEffect(
        neuroType: NeuroType.tlp,
        targetCount: 0,
        historyCount: 0,
      ),
      isFalse,
    );
    expect(
      abilityHasEffect(
        neuroType: NeuroType.toc,
        targetCount: 1,
        historyCount: 0,
      ),
      isTrue,
    );
    expect(
      abilityHasEffect(
        neuroType: NeuroType.tdah,
        targetCount: 0,
        historyCount: 0,
      ),
      isTrue,
    );
  });

  test('rings cannot spawn until the minimum radial separation is free', () {
    expect(
      hasMinimumRingSeparation(
        spawnRadius: 500,
        existingRadii: const <double>[405, 260],
        minimumSeparation: 100,
      ),
      isFalse,
    );
    expect(
      hasMinimumRingSeparation(
        spawnRadius: 500,
        existingRadii: const <double>[390, 260],
        minimumSeparation: 100,
      ),
      isTrue,
    );
    expect(
      hasMinimumRingSeparation(
        spawnRadius: 500,
        existingRadii: const <double>[],
        minimumSeparation: 100,
      ),
      isTrue,
    );
  });
}
