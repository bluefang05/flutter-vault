import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';

class ScenarioRunnerScreen extends StatefulWidget {
  final Scenario scenario;

  const ScenarioRunnerScreen({super.key, required this.scenario});

  @override
  State<ScenarioRunnerScreen> createState() => _ScenarioRunnerScreenState();
}

class _ScenarioRunnerScreenState extends State<ScenarioRunnerScreen> {
  int _currentStepIndex = 0;
  ScenarioChoice? _selectedChoice;
  bool _isCompleted = false;

  ScenarioStep get _currentStep => widget.scenario.steps[_currentStepIndex];

  void _onSelectChoice(ScenarioChoice choice) {
    if (_selectedChoice != null) return;

    setState(() {
      _selectedChoice = choice;
    });

    if (choice.isBestAction) {
      FeedbackService.success();
    } else {
      FeedbackService.error();
    }
  }

  void _onNextStep() {
    if (_selectedChoice == null) return;

    if (_selectedChoice!.nextStepIndex != null &&
        _selectedChoice!.nextStepIndex! < widget.scenario.steps.length) {
      setState(() {
        _currentStepIndex = _selectedChoice!.nextStepIndex!;
        _selectedChoice = null;
      });
    } else {
      // Completed scenario
      final progress = StorageService.loadProgress();
      final updated = progress.markScenarioCompleted(widget.scenario.id);
      StorageService.saveProgress(updated);

      setState(() {
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isCompleted) {
      return _buildCompletionScreen(isDark);
    }

    final step = _currentStep;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.domain),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Step Counter & Scenario Title
          Text(
            widget.scenario.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Momento ${_currentStepIndex + 1} de ${widget.scenario.steps.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),

          // Illustration if available
          if (step.illustrationKey != null) ...[
            Center(
              child: ConoVeIllustration(
                illustrationKey: step.illustrationKey!,
                width: 170,
                height: 170,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Narrative Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.visibility_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Lo que sucede en la sala:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.narrative,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),

                // Signals list
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: step.visibleSignals.map((sig) {
                    return BadgePill(
                      text: sig,
                      color: AppColors.accent,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Question header
          const Text(
            '¿Qué decides hacer o decir?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          // Choices
          for (final choice in step.choices) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                borderSide: _selectedChoice == choice
                    ? BorderSide(
                        color: choice.isBestAction ? AppColors.success : AppColors.error,
                        width: 2.0,
                      )
                    : null,
                color: _selectedChoice == choice
                    ? (choice.isBestAction
                        ? AppColors.successContainer.withValues(alpha: 0.3)
                        : AppColors.errorContainer.withValues(alpha: 0.3))
                    : null,
                onTap: _selectedChoice == null ? () => _onSelectChoice(choice) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedChoice == choice
                                ? (_choiceColor(choice))
                                : Colors.transparent,
                            border: Border.all(
                              color: _selectedChoice == choice
                                  ? _choiceColor(choice)
                                  : AppColors.textMutedLight,
                              width: 1.8,
                            ),
                          ),
                          child: _selectedChoice == choice
                              ? Icon(
                                  choice.isBestAction ? Icons.check : Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            choice.text,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),

                    // Consequence & Analysis revealed after selection
                    if (_selectedChoice == choice) ...[
                      const Divider(height: 20),
                      Text(
                        choice.consequenceSummary,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: choice.isBestAction ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        choice.analysis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Next Step Button
          if (_selectedChoice != null)
            ElevatedButton(
              onPressed: () {
                FeedbackService.lightClick();
                _onNextStep();
              },
              child: Text(
                _selectedChoice!.nextStepIndex != null ? 'Siguiente Momento' : 'Concluir Escenario',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _choiceColor(ScenarioChoice choice) {
    return choice.isBestAction ? AppColors.success : AppColors.error;
  }

  Widget _buildCompletionScreen(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escenario Completado'),
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
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 54),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Entrenamiento Superado!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Has completado exitosamente "${widget.scenario.title}".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              AppCard(
                color: isDark ? const Color(0xFF134E4A) : AppColors.primaryContainer,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Recompensa', style: TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    const Text('+50 Puntos de Maestría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                  ],
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  FeedbackService.lightClick();
                  Navigator.pop(context);
                },
                child: const Text('Volver a Escenarios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
