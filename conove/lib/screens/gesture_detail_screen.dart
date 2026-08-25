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
    FeedbackService.bookmark();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 720;

          final detailCards = [
            // Card 1: Pistas Anatómicas Físicas
            AppCard(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 20, color: isDark ? AppColors.primaryLight : AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Pistas Anatómicas Físicas (Qué ver)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.physiologicalDetails,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 2: Significado Principal NT (Green)
            AppCard(
              color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : AppColors.successContainer,
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFFA7F3D0),
                width: 1.2,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, size: 20, color: isDark ? const Color(0xFF34D399) : AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'Significado Más Probable (en Neurotípicos)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.probableMeaning,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFFECFDF5) : const Color(0xFF064E3B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 3: Trampas y Significados Alternativos (Amber)
            AppCard(
              color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : AppColors.warningContainer,
              borderSide: BorderSide(
                color: isDark ? const Color(0xFFD97706).withValues(alpha: 0.5) : const Color(0xFFFDE68A),
                width: 1.2,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: isDark ? const Color(0xFFFBBF24) : AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Trampas y Otras Posibles Razones',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
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
                          Text(
                            '• ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              alt,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFFFFBEB) : const Color(0xFF78350F),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 4: Guía por Contexto (Indigo/Slate)
            AppCard(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_rounded, size: 20, color: isDark ? const Color(0xFF818CF8) : AppColors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        'Guía según el Contexto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.contextGuidance,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 5: ¿Qué Hacer o Responder? (Indigo)
            AppCard(
              color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.35) : const Color(0xFFE0E7FF),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.5) : const Color(0xFFC7D2FE),
                width: 1.2,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_rounded, size: 20, color: isDark ? const Color(0xFF818CF8) : AppColors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        '¿Cómo Responder o Reaccionar?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.whatToDo,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF312E81),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 6: Consejo de Ventas & Negociación (Purple)
            AppCard(
              color: isDark ? const Color(0xFF581C87).withValues(alpha: 0.35) : const Color(0xFFF3E8FF),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFFA855F7).withValues(alpha: 0.5) : const Color(0xFFE9D5FF),
                width: 1.2,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_center_rounded, size: 20, color: isDark ? const Color(0xFFC084FC) : AppColors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Consejo para Ventas y Negociación',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.salesTip,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFFFAF5FF) : const Color(0xFF581C87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ];

          if (isTablet) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Illustration & Header)
                    SizedBox(
                      width: 360,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Center(
                            child: Hero(
                              tag: 'gesture_illustration_${item.id}',
                              child: ConoVeIllustration(
                                illustrationKey: item.illustrationKey,
                                width: 260,
                                height: 260,
                                highlightAnatomy: _highlightAnatomy,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              BadgePill(text: item.bodyPart, color: catInfo.primaryColor),
                              BadgePill(text: item.signalType.label, color: item.signalType.color),
                              BadgePill(text: catInfo.chapterReference, color: AppColors.textMutedLight),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.summary,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    // Right Column (Details)
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: detailCards,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mobile 1-Column Layout
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
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
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BadgePill(text: item.bodyPart, color: catInfo.primaryColor),
                  BadgePill(text: item.signalType.label, color: item.signalType.color),
                  BadgePill(text: catInfo.chapterReference, color: AppColors.textMutedLight),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4),
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
              ...detailCards,
            ],
          );
        },
      ),
    );
  }
}
