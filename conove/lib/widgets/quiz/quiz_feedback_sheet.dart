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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final containerBg = isDark
        ? (isCorrect ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D))
        : (isCorrect ? AppColors.successContainer : AppColors.errorContainer);

    final titleColor = isDark
        ? (isCorrect ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5))
        : (isCorrect ? const Color(0xFF065F46) : const Color(0xFF991B1B));

    final iconColor = isDark
        ? (isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171))
        : (isCorrect ? AppColors.success : AppColors.error);

    final clueBoxBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.9);

    final clueTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final explanationColor = isDark
        ? (isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2))
        : const Color(0xFF1F2937);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerBg,
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
                  color: iconColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCorrect ? '¡Excelente observación!' : '¡Buen intento! Aprende el detalle:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: titleColor,
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
              color: clueBoxBg,
              borderRadius: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.visibility_rounded, size: 18, color: isDark ? AppColors.accentLight : AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: clueTextColor),
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
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: explanationColor,
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
