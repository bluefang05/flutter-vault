class ScenarioChoice {
  final String text;
  final String analysis;
  final bool isBestAction;
  final int? nextStepIndex;
  final String consequenceSummary;

  const ScenarioChoice({
    required this.text,
    required this.analysis,
    required this.isBestAction,
    this.nextStepIndex,
    required this.consequenceSummary,
  });
}

class ScenarioStep {
  final String id;
  final String narrative;
  final String characterAction;
  final String? illustrationKey;
  final List<String> visibleSignals;
  final List<ScenarioChoice> choices;
  final String learningTakeaway;

  const ScenarioStep({
    required this.id,
    required this.narrative,
    required this.characterAction,
    this.illustrationKey,
    required this.visibleSignals,
    required this.choices,
    required this.learningTakeaway,
  });
}

class Scenario {
  final String id;
  final String title;
  final String domain; // Ventas & Negociación, Laboral, Social, etc.
  final String description;
  final String contextOverview;
  final String iconName;
  final List<ScenarioStep> steps;

  const Scenario({
    required this.id,
    required this.title,
    required this.domain,
    required this.description,
    required this.contextOverview,
    required this.iconName,
    required this.steps,
  });
}
