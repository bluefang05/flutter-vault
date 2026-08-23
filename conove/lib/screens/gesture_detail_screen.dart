import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/gesture_database.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/tts_service.dart';
import '../models/gesture_item.dart';

class GestureDetailScreen extends StatefulWidget {
  final String gestureId;

  const GestureDetailScreen({super.key, required this.gestureId});

  @override
  State<GestureDetailScreen> createState() => _GestureDetailScreenState();
}

class _GestureDetailScreenState extends State<GestureDetailScreen> {
  bool _highlightAnatomy = false;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = StorageService.isBookmarked(widget.gestureId);
    _registerExplored();
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  void _registerExplored() {
    final progress = StorageService.loadProgress();
    final updated = progress.markGestureExplored(widget.gestureId);
    StorageService.saveProgress(updated);
  }

  void _toggleBookmark() async {
    await StorageService.toggleBookmark(widget.gestureId);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    FeedbackService.lightClick();
  }

  void _toggleTts(GestureItem item) {
    final speech = '${item.name}. ${item.summary}. Pistas anatómicas físicas: ${item.physiologicalDetails}. Significado principal: ${item.probableMeaning}. Qué debes hacer o responder: ${item.whatToDo}. Consejo para ventas y negociación: ${item.salesTip}';
    TtsService.speak(speech, gestureId: item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = GestureDatabase.getById(widget.gestureId);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Señal no encontrada')),
      );
    }

    final catInfo = CategoryInfo.getInfo(item.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(catInfo.shortTitle),
        actions: [
          ValueListenableBuilder<String?>(
            valueListenable: TtsService.currentSpeakingIdNotifier,
            builder: (context, speakingId, _) {
              final isSpeaking = speakingId == item.id;
              return IconButton(
                icon: Icon(
                  isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                  color: isSpeaking ? AppColors.accent : null,
                  size: 24,
                ),
                tooltip: isSpeaking ? 'Detener lectura' : 'Escuchar en voz alta',
                onPressed: () {
                  FeedbackService.lightClick();
                  _toggleTts(item);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isBookmarked ? catInfo.primaryColor : null,
            ),
            tooltip: 'Guardar para repaso',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Hero Illustration Box
          Center(
            child: Hero(
              tag: 'gesture_illustration_${item.id}',
              child: ConoVeIllustration(
                illustrationKey: item.illustrationKey,
                width: 220,
                height: 220,
                highlightAnatomy: _highlightAnatomy,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Toggles row: Anatomy + TTS Audio Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                avatar: Icon(
                  _highlightAnatomy ? Icons.remove_red_eye_rounded : Icons.remove_red_eye_outlined,
                  size: 16,
                  color: _highlightAnatomy ? Colors.white : AppColors.primary,
                ),
                label: Text(_highlightAnatomy ? 'Pistas On' : 'Pistas Off'),
                selected: _highlightAnatomy,
                selectedColor: AppColors.primary,
                backgroundColor: Theme.of(context).cardTheme.color,
                onSelected: (val) {
                  FeedbackService.lightClick();
                  setState(() => _highlightAnatomy = val);
                },
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<String?>(
                valueListenable: TtsService.currentSpeakingIdNotifier,
                builder: (context, speakingId, _) {
                  final isSpeaking = speakingId == item.id;
                  return ActionChip(
                    avatar: Icon(
                      isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                      size: 16,
                      color: isSpeaking ? Colors.white : AppColors.accent,
                    ),
                    label: Text(
                      isSpeaking ? 'Detener Audio' : 'Escuchar Ficha',
                      style: TextStyle(color: isSpeaking ? Colors.white : null, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: isSpeaking ? AppColors.accent : Theme.of(context).cardTheme.color,
                    onPressed: () {
                      FeedbackService.lightClick();
                      _toggleTts(item);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title & Body Part Tag & Traffic Light Indicator
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BadgePill(
                text: item.bodyPart,
                color: catInfo.primaryColor,
              ),
              BadgePill(
                text: item.signalType.label,
                color: item.signalType.color,
              ),
              BadgePill(
                text: catInfo.chapterReference,
                color: AppColors.textMutedLight,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.summary,
            style: TextStyle(
              fontSize: 14.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // Card 1: Pistas Anatómicas Físicas
          AppCard(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.visibility_rounded, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Pistas Anatómicas Físicas (Qué ver)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.physiologicalDetails,
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card 2: Significado Principal NT
          AppCard(
            color: isDark ? const Color(0xFF064E3B) : AppColors.successContainer,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 20, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(
                      'Significado Más Probable (en Neurotípicos)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.probableMeaning,
                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF064E3B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card 3: Trampas y Significados Alternativos
          AppCard(
            color: isDark ? const Color(0xFF451A03) : AppColors.warningContainer,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text(
                      'Trampas y Otras Posibles Razones',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final alt in item.alternativeMeanings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        Expanded(
                          child: Text(
                            alt,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card 4: Guía por Contexto
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map_rounded, size: 20, color: AppColors.indigo),
                    SizedBox(width: 8),
                    Text(
                      'Guía según el Contexto',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.contextGuidance,
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card 5: ¿Qué Hacer o Responder?
          AppCard(
            color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.chat_rounded, size: 20, color: AppColors.indigo),
                    SizedBox(width: 8),
                    Text(
                      '¿Cómo Responder o Reaccionar?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF3730A3)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.whatToDo,
                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF312E81)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card 6: Consejo de Ventas & Negociación
          AppCard(
            color: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.business_center_rounded, size: 20, color: AppColors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Consejo para Ventas y Negociación',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF6B21A8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.salesTip,
                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF581C87)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
