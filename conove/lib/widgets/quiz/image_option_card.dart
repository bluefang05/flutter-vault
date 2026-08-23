import 'package:flutter/material.dart';
import '../../models/quiz_question.dart';
import '../../core/constants/app_colors.dart';
import '../illustrations/illustration_widget.dart';
import '../../core/services/feedback_service.dart';

class ImageOptionCard extends StatelessWidget {
  final QuizOption option;
  final bool isSelected;
  final bool isEvaluated;
  final VoidCallback onSelect;

  const ImageOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isEvaluated,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.lightBorder;
    Color? backgroundColor;
    Widget? stateBadge;

    if (isEvaluated) {
      if (option.isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.successContainer.withValues(alpha: 0.35);
        stateBadge = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22);
      } else if (isSelected && !option.isCorrect) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.errorContainer.withValues(alpha: 0.35);
        stateBadge = const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primaryContainer.withValues(alpha: 0.25);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEvaluated
            ? null
            : () {
                FeedbackService.lightClick();
                onSelect();
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark && borderColor == AppColors.lightBorder ? AppColors.darkBorder : borderColor,
              width: isSelected || (isEvaluated && option.isCorrect) ? 2.5 : 1.2,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Image Box if present
              if (option.hasIllustration) ...[
                Expanded(
                  child: Center(
                    child: ConoVeIllustration(
                      illustrationKey: option.illustrationKey!,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Label and Selection Indicator
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.textMutedLight,
                        width: 1.8,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.circle, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.text,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (option.subtext != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            option.subtext!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (stateBadge != null) stateBadge,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
