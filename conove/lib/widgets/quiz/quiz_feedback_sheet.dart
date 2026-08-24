import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/app_card.dart';
import '../../core/services/feedback_service.dart';
import '../../core/services/tts_service.dart';

class QuizFeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final String keyVisualClue;
  final String explanation;
  final VoidCallback onContinue;

  const QuizFeedbackSheet({
    super.key,
    required this.isCorrect,
    required this.keyVisualClue,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successContainer : AppColors.errorContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header with TTS
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCorrect ? '¡Excelente observación!' : '¡Buen intento! Aprende el detalle:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                  ),
                  tooltip: 'Escuchar explicación',
                  onPressed: () {
                    FeedbackService.lightClick();
                    TtsService.speak('${isCorrect ? "¡Excelente observación!" : "¡Buen intento!"}. Pista anatómica: $keyVisualClue. Explicación: $explanation');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Key Clue Box
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.visibility_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
                        children: [
                          const TextSpan(
                            text: 'Pista anatómica clave: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: keyVisualClue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Detailed Explanation
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            // Continue button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? const Color(0xFF059669) : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                FeedbackService.lightClick();
                onContinue();
              },
              child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
