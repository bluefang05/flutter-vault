enum GameRunState { ready, running, gameOver, paused }

class HudSnapshot {
  const HudSnapshot({
    required this.seconds,
    required this.score,
    required this.stage,
    required this.abilityCharge,
    required this.resonance,
    required this.spoonHalves,
    required this.maxSpoonHalves,
    required this.cleanPasses,
    required this.flowMultiplier,
    required this.breathing,
    required this.recovering,
    required this.state,
  });

  final double seconds;
  final int score;
  final String stage;
  final double abilityCharge;
  final double resonance;
  final int spoonHalves;
  final int maxSpoonHalves;
  final int cleanPasses;
  final double flowMultiplier;
  final bool breathing;
  final bool recovering;
  final GameRunState state;
}
