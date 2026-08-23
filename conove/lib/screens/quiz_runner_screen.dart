import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../widgets/quiz/image_option_card.dart';
import '../widgets/quiz/quiz_feedback_sheet.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../widgets/common/app_card.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';

class QuizRunnerScreen extends StatefulWidget {
  final String title;
  final List<QuizQuestion> questions;

  const QuizRunnerScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<QuizRunnerScreen> createState() => _QuizRunnerScreenState();
}

class _QuizRunnerScreenState extends State<QuizRunnerScreen> {
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _isEvaluated = false;
  int _correctCount = 0;
  bool _isFinished = false;

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _onSelectOption(String optionId) {
    if (_isEvaluated) return;
    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _onSubmitAnswer() {
    if (_selectedOptionId == null || _isEvaluated) return;

    final selected = _currentQuestion.options.firstWhere((opt) => opt.id == _selectedOptionId);
    final isCorrect = selected.isCorrect;

    setState(() {
      _isEvaluated = true;
      if (isCorrect) {
        _correctCount++;
        FeedbackService.success();
      } else {
        FeedbackService.error();
      }
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => QuizFeedbackSheet(
        isCorrect: isCorrect,
        keyVisualClue: _currentQuestion.keyVisualClue,
        explanation: _currentQuestion.explanation,
        onContinue: () {
          Navigator.pop(context);
          _onNextStep();
        },
      ),
    );
  }

  void _onNextStep() {
    if (_currentIndex + 1 < widget.questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
        _isEvaluated = false;
      });
    } else {
      // Finished quiz
      final scorePercentage = ((_correctCount / widget.questions.length) * 100).round();
      final progress = StorageService.loadProgress();
      final updated = progress.recordQuizResult(widget.title, scorePercentage);
      StorageService.saveProgress(updated);

      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isFinished) {
      return _buildScoreSummary(isDark);
    }

    final question = _currentQuestion;
    final progressVal = (_currentIndex + 1) / widget.questions.length;
    final isGrid = question.isImageOptionGrid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progressVal,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            color: AppColors.primary,
            minHeight: 5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Progress Tag
              Text(
                'Pregunta ${_currentIndex + 1} de ${widget.questions.length}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 6),

              // Prompt Title
              Text(
                question.prompt,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              if (question.scenarioText != null) ...[
                const SizedBox(height: 4),
                Text(
                  question.scenarioText!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],

              // Header Illustration if available
              if (question.questionIllustrationKey != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: ConoVeIllustration(
                    illustrationKey: question.questionIllustrationKey!,
                    width: 140,
                    height: 140,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Options: Grid if images, List if text
              Expanded(
                child: isGrid
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: question.options.length,
                        itemBuilder: (context, index) {
                          final opt = question.options[index];
                          return ImageOptionCard(
                            option: opt,
                            isSelected: _selectedOptionId == opt.id,
                            isEvaluated: _isEvaluated,
                            onSelect: () => _onSelectOption(opt.id),
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: question.options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final opt = question.options[index];
                          return ImageOptionCard(
                            option: opt,
                            isSelected: _selectedOptionId == opt.id,
                            isEvaluated: _isEvaluated,
                            onSelect: () => _onSelectOption(opt.id),
                          );
                        },
                      ),
              ),

              // Confirm/Submit Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOptionId != null ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: _selectedOptionId != null && !_isEvaluated ? _onSubmitAnswer : null,
                  child: const Text('Comprobar Respuesta', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSummary(bool isDark) {
    final score = ((_correctCount / widget.questions.length) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: score >= 70 ? AppColors.successContainer : AppColors.warningContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    score >= 70 ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                    color: score >= 70 ? AppColors.success : AppColors.warning,
                    size: 54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                score >= 70 ? '¡Excelente Percepción!' : '¡Buen Entrenamiento!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Obtuviste $_correctCount de ${widget.questions.length} respuestas correctas ($score%).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Aciertos', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('$_correctCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Puntos Ganados', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('+${score * 2} pts', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  FeedbackService.lightClick();
                  Navigator.pop(context);
                },
                child: const Text('Volver a Práctica'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  FeedbackService.lightClick();
                  setState(() {
                    _currentIndex = 0;
                    _correctCount = 0;
                    _selectedOptionId = null;
                    _isEvaluated = false;
                    _isFinished = false;
                  });
                },
                child: const Text('Reintentar Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
