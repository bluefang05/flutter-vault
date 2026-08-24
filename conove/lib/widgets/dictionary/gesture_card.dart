import 'package:flutter/material.dart';
import '../../models/gesture_item.dart';
import '../../models/category.dart';
import '../common/app_card.dart';
import '../common/badge_pill.dart';
import '../illustrations/illustration_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/feedback_service.dart';
import '../../core/services/tts_service.dart';

class GestureCard extends StatelessWidget {
  final GestureItem item;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const GestureCard({
    super.key,
    required this.item,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final catInfo = CategoryInfo.getInfo(item.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        onTap: () {
          FeedbackService.lightClick();
          onTap();
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Vector Illustration Thumbnail
            Hero(
              tag: 'gesture_illustration_${item.id}',
              child: ConoVeIllustration(
                illustrationKey: item.illustrationKey,
                width: 76,
                height: 76,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BadgePill(
                        text: item.bodyPart,
                        color: catInfo.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        item.signalType.icon,
                        size: 14,
                        color: item.signalType.color,
                      ),
                      const Spacer(),
                      ValueListenableBuilder<String?>(
                        valueListenable: TtsService.currentSpeakingIdNotifier,
                        builder: (context, speakingId, _) {
                          final isSpeaking = speakingId == item.id;
                          return IconButton(
                            icon: Icon(
                              isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                              color: isSpeaking ? AppColors.accent : Colors.grey,
                              size: 22,
                            ),
                            tooltip: isSpeaking ? 'Detener lectura' : 'Escuchar en voz alta',
                            onPressed: () {
                              FeedbackService.lightClick();
                              final textToRead = '${item.name}. ${item.summary}. Pista física: ${item.physiologicalDetails}. Significado: ${item.probableMeaning}';
                              TtsService.speak(textToRead, gestureId: item.id);
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: isBookmarked ? catInfo.primaryColor : Colors.grey,
                          size: 22,
                        ),
                        onPressed: () {
                          FeedbackService.bookmark();
                          onBookmarkToggle();
                        },
                        tooltip: isBookmarked ? 'Guardado en favoritos' : 'Guardar gesto',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.summary,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
