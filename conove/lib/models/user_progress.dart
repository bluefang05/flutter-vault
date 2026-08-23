class UserProgress {
  final int currentStreak;
  final int bestStreak;
  final String lastActiveDate; // YYYY-MM-DD
  final List<String> exploredGestureIds;
  final List<String> completedQuizIds;
  final Map<String, int> quizScores; // quizId -> score %
  final List<String> completedScenarioIds;

  const UserProgress({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate = '',
    this.exploredGestureIds = const [],
    this.completedQuizIds = const [],
    this.quizScores = const {},
    this.completedScenarioIds = const [],
  });

  factory UserProgress.initial() {
    return const UserProgress(
      currentStreak: 1,
      bestStreak: 1,
      lastActiveDate: '',
      exploredGestureIds: [],
      completedQuizIds: [],
      quizScores: {},
      completedScenarioIds: [],
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  UserProgress registerActiveDay() {
    final todayStr = _formatDate(DateTime.now());
    if (lastActiveDate == todayStr) {
      return this;
    }

    final yesterdayStr = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
    int newStreak = currentStreak;

    if (lastActiveDate.isEmpty) {
      newStreak = 1;
    } else if (lastActiveDate == yesterdayStr) {
      newStreak = currentStreak + 1;
    } else {
      newStreak = 1;
    }

    final newBest = newStreak > bestStreak ? newStreak : bestStreak;

    return copyWith(
      currentStreak: newStreak,
      bestStreak: newBest,
      lastActiveDate: todayStr,
    );
  }

  UserProgress markGestureExplored(String gestureId) {
    if (exploredGestureIds.contains(gestureId)) {
      return this;
    }
    final updated = List<String>.from(exploredGestureIds)..add(gestureId);
    return copyWith(exploredGestureIds: updated);
  }

  UserProgress recordQuizResult(String quizId, int score) {
    final updatedCompleted = List<String>.from(completedQuizIds);
    if (!updatedCompleted.contains(quizId)) {
      updatedCompleted.add(quizId);
    }
    final updatedScores = Map<String, int>.from(quizScores)..[quizId] = score;

    return copyWith(
      completedQuizIds: updatedCompleted,
      quizScores: updatedScores,
    ).registerActiveDay();
  }

  UserProgress markScenarioCompleted(String scenarioId) {
    final updated = List<String>.from(completedScenarioIds);
    if (!updated.contains(scenarioId)) {
      updated.add(scenarioId);
    }
    return copyWith(completedScenarioIds: updated).registerActiveDay();
  }

  int get totalPoints {
    int points = exploredGestureIds.length * 10;
    quizScores.forEach((_, score) {
      points += score;
    });
    points += completedScenarioIds.length * 50;
    points += currentStreak * 20;
    return points;
  }

  int get totalQuizzesTaken => completedQuizIds.length;

  double get averageQuizAccuracy {
    if (quizScores.isEmpty) return 0.0;
    final total = quizScores.values.reduce((a, b) => a + b);
    return total / quizScores.length;
  }

  UserProgress copyWith({
    int? currentStreak,
    int? bestStreak,
    String? lastActiveDate,
    List<String>? exploredGestureIds,
    List<String>? completedQuizIds,
    Map<String, int>? quizScores,
    List<String>? completedScenarioIds,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      exploredGestureIds: exploredGestureIds ?? this.exploredGestureIds,
      completedQuizIds: completedQuizIds ?? this.completedQuizIds,
      quizScores: quizScores ?? this.quizScores,
      completedScenarioIds: completedScenarioIds ?? this.completedScenarioIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastActiveDate': lastActiveDate,
      'exploredGestureIds': exploredGestureIds,
      'completedQuizIds': completedQuizIds,
      'quizScores': quizScores,
      'completedScenarioIds': completedScenarioIds,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentStreak: json['currentStreak'] as int? ?? 1,
      bestStreak: json['bestStreak'] as int? ?? 1,
      lastActiveDate: json['lastActiveDate'] as String? ?? '',
      exploredGestureIds: (json['exploredGestureIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      completedQuizIds: (json['completedQuizIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      quizScores: (json['quizScores'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
      completedScenarioIds: (json['completedScenarioIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
