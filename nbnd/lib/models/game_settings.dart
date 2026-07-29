class GameSettings {
  const GameSettings({
    this.haptics = true,
    this.reducedFlashes = false,
    this.practiceMode = false,
  });

  final bool haptics;
  final bool reducedFlashes;
  final bool practiceMode;

  GameSettings copyWith({
    bool? haptics,
    bool? reducedFlashes,
    bool? practiceMode,
  }) {
    return GameSettings(
      haptics: haptics ?? this.haptics,
      reducedFlashes: reducedFlashes ?? this.reducedFlashes,
      practiceMode: practiceMode ?? this.practiceMode,
    );
  }
}
