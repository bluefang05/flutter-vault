import 'category.dart';

class QuizOption {
  final String id;
  final String text;
  final String? subtext;
  final String? illustrationKey;
  final bool isCorrect;

  const QuizOption({
    required this.id,
    required this.text,
    this.subtext,
    this.illustrationKey,
    required this.isCorrect,
  });

  bool get hasIllustration => illustrationKey != null && illustrationKey!.isNotEmpty;
}

class QuizQuestion {
  final String id;
  final CategoryType category;
  final String prompt;
  final String? scenarioText;
  final String? questionIllustrationKey;
  final List<QuizOption> options;
  final String explanation;
  final String keyVisualClue;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.prompt,
    this.scenarioText,
    this.questionIllustrationKey,
    required this.options,
    required this.explanation,
    required this.keyVisualClue,
  });

  bool get isImageOptionGrid => options.any((opt) => opt.hasIllustration);
}
