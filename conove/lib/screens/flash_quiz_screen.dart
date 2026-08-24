import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/tts_service.dart';
import '../data/quiz_database.dart';
import '../models/quiz_question.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../widgets/quiz/quiz_feedback_sheet.dart';

class FlashQuizScreen extends StatefulWidget {
  const FlashQuizScreen({super.key});

  @override
  State<FlashQuizScreen> createState() => _FlashQuizScreenState();
}

class _FlashQuizScreenState extends State<FlashQuizScreen> with SingleTickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  bool _isImageVisible = true;
  bool _isAnswered = false;
  QuizOption? _selectedOption;

  late AnimationController _timerController;
  Timer? _countdownTimer;

  static const int flashSeconds = 3;

  @override
  void initState() {
    super.initState();
    final allVisual = QuizDatabase.questions.where((q) => q.questionIllustrationKey != null || q.isImageOptionGrid).toList();
    _questions = (allVisual.isNotEmpty ? allVisual : QuizDatabase.questions).toList()..shuffle();
    if (_questions.length > 8) {
      _questions = _questions.sublist(0, 8);
    }

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: flashSeconds),
    );

    _startQuestionFlash();
  }

  void _startQuestionFlash() {
    setState(() {
      _isImageVisible = true;
      _isAnswered = false;
      _selectedOption = null;
    });

    _timerController.reset();
    _timerController.forward();
    FeedbackService.tick();

    _countdownTimer?.cancel();
    int ticksLeft = flashSeconds - 1;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isAnswered) {
        timer.cancel();
        return;
      }
      if (ticksLeft > 0) {
        FeedbackService.tick();
        ticksLeft--;
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isImageVisible = false;
          });
          FeedbackService.lightClick();
        }
      }
    });
  }

  void _submitAnswer(QuizOption option) {
    if (_isAnswered) return;
    _countdownTimer?.cancel();
    _timerController.stop();

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
      if (option.isCorrect) {
        _score += 15;
        _correctCount++;
        FeedbackService.success();
      } else {
        FeedbackService.error();
      }
    });

    final currentQ = _questions[_currentIndex];

    if (StorageService.getAutoNarration()) {
      TtsService.speakQuizFeedback(
        isCorrect: option.isCorrect,
        keyVisualClue: currentQ.keyVisualClue,
        explanation: currentQ.explanation,
      );
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => QuizFeedbackSheet(
        isCorrect: option.isCorrect,
        keyVisualClue: currentQ.keyVisualClue,
        explanation: currentQ.explanation,
        onContinue: () {
          TtsService.stop();
          Navigator.pop(ctx);
          _nextQuestion();
        },
      ),
    );
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestionFlash();
    } else {
      _saveProgressAndFinish();
    }
  }

  void _saveProgressAndFinish() async {
    FeedbackService.complete();
    final progress = StorageService.loadProgress();
    final updated = progress.recordQuizResult('Flash Contrarreloj', _score);
    await StorageService.saveProgress(updated);
    _showSummaryDialog();
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Sesión Completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 48),
            const SizedBox(height: 12),
            Text('Aciertos: $_correctCount de ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Puntos ganados: +$_score XP', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timerController.dispose();
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentQ = _questions[_currentIndex];

    // Determine the key illustration to show
    String illustrationToShow = currentQ.questionIllustrationKey ?? currentQ.options.firstWhere((o) => o.isCorrect).illustrationKey ?? 'duchenne_smile';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Flash Contrarreloj'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Escuchar pregunta y opciones',
            onPressed: () {
              FeedbackService.lightClick();
              TtsService.speakQuizQuestion(
                question: currentQ.prompt,
                visualClue: currentQ.keyVisualClue,
                options: currentQ.options.map((o) => o.text).toList(),
                tag: 'flash_q_${currentQ.id}',
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: AnimatedBuilder(
            animation: _timerController,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: 1.0 - _timerController.value,
                backgroundColor: isDark ? Colors.black38 : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timerController.value > 0.7 ? AppColors.error : AppColors.accent,
                ),
              );
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BadgePill(
                text: 'Pregunta ${_currentIndex + 1} de ${_questions.length}',
                color: AppColors.primary,
              ),
              BadgePill(
                text: '$_score XP',
                color: AppColors.accent,
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question Prompt
          Text(
            currentQ.prompt,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),

          // Flash Image Display Container
          Center(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 200,
                height: 200,
                child: _isImageVisible
                    ? ConoVeIllustration(
                        illustrationKey: illustrationToShow,
                        width: 200,
                        height: 200,
                        borderRadius: BorderRadius.circular(16),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_off_rounded, size: 48, color: AppColors.accent),
                            SizedBox(height: 8),
                            Text(
                              '¡Tiempo de visualización agotado!',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Elige la opción correcta por memoria',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options Grid / List
          Column(
            children: currentQ.options.map((option) {
              final isSelected = _selectedOption == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: _isAnswered ? null : () => _submitAnswer(option),
                  color: isSelected
                      ? (option.isCorrect ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15))
                      : null,
                  borderSide: isSelected
                      ? BorderSide(color: option.isCorrect ? AppColors.success : AppColors.error, width: 2)
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.text,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                            if (option.subtext != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                option.subtext!,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          option.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: option.isCorrect ? AppColors.success : AppColors.error,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
