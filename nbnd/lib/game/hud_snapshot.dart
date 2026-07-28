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
    required this.state,
  });

  final double seconds;
  final int score;
  final String stage;
  final double abilityCharge;
  final double resonance;
  final int spoonHalves;
  final int maxSpoonHalves;
  final GameRunState state;
}
