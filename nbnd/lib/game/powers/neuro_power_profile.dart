import 'dart:math' as math;

import '../../models/neuro_type.dart';

class NeuroPowerProfile {
  const NeuroPowerProfile({
    required this.type,
    required this.playerSpeed,
    required this.baseGapWidth,
    required this.cooldown,
    required this.patternRandomness,
    required this.maxSpoonHalves,
  });

  final NeuroType type;
  final double playerSpeed;
  final double baseGapWidth;
  final double cooldown;
  final double patternRandomness;
  final int maxSpoonHalves;

  static NeuroPowerProfile forType(NeuroType type) {
    return switch (type) {
      NeuroType.tdah => const NeuroPowerProfile(
        type: NeuroType.tdah,
        playerSpeed: 4.25,
        baseGapWidth: math.pi / 2.6,
        cooldown: 8,
        patternRandomness: 1,
        maxSpoonHalves: 10,
      ),
      NeuroType.tea => const NeuroPowerProfile(
        type: NeuroType.tea,
        playerSpeed: 3.15,
        baseGapWidth: math.pi / 3.2,
        cooldown: 9,
        patternRandomness: .25,
        maxSpoonHalves: 8,
      ),
      NeuroType.tlp => const NeuroPowerProfile(
        type: NeuroType.tlp,
        playerSpeed: 3.45,
        baseGapWidth: math.pi / 3,
        cooldown: 7.5,
        patternRandomness: .65,
        maxSpoonHalves: 8,
      ),
      NeuroType.tid => const NeuroPowerProfile(
        type: NeuroType.tid,
        playerSpeed: 3.2,
        baseGapWidth: math.pi / 3.6,
        cooldown: 5.5,
        patternRandomness: .6,
        maxSpoonHalves: 10,
      ),
      NeuroType.toc => const NeuroPowerProfile(
        type: NeuroType.toc,
        playerSpeed: 3.05,
        baseGapWidth: math.pi / 3.4,
        cooldown: 8.5,
        patternRandomness: .1,
        maxSpoonHalves: 12,
      ),
      NeuroType.alexitimia => const NeuroPowerProfile(
        type: NeuroType.alexitimia,
        playerSpeed: 2.75,
        baseGapWidth: math.pi / 3.05,
        cooldown: 8,
        patternRandomness: .18,
        maxSpoonHalves: 14,
      ),
      NeuroType.anhedonia => const NeuroPowerProfile(
        type: NeuroType.anhedonia,
        playerSpeed: 2.95,
        baseGapWidth: math.pi / 3.08,
        cooldown: 12,
        patternRandomness: .35,
        maxSpoonHalves: 12,
      ),
      NeuroType.tag => const NeuroPowerProfile(
        type: NeuroType.tag,
        playerSpeed: 3.25,
        baseGapWidth: math.pi / 3.1,
        cooldown: 10,
        patternRandomness: .45,
        maxSpoonHalves: 8,
      ),
    };
  }
}
