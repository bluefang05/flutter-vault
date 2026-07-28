class GameSettings {
  const GameSettings({
    this.haptics = true,
    this.reducedFlashes = false,
    this.practiceMode = false,
    this.showAdPlaceholder = true,
  });

  final bool haptics;
  final bool reducedFlashes;
  final bool practiceMode;
  final bool showAdPlaceholder;

  GameSettings copyWith({
    bool? haptics,
    bool? reducedFlashes,
    bool? practiceMode,
    bool? showAdPlaceholder,
  }) {
    return GameSettings(
      haptics: haptics ?? this.haptics,
      reducedFlashes: reducedFlashes ?? this.reducedFlashes,
      practiceMode: practiceMode ?? this.practiceMode,
      showAdPlaceholder: showAdPlaceholder ?? this.showAdPlaceholder,
    );
  }
}
