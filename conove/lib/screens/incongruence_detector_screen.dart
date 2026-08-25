import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/incongruence_database.dart';
import '../models/incongruence_item.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../core/services/feedback_service.dart';
import '../core/services/tts_service.dart';

class IncongruenceDetectorScreen extends StatefulWidget {
  const IncongruenceDetectorScreen({super.key});

  @override
  State<IncongruenceDetectorScreen> createState() => _IncongruenceDetectorScreenState();
}

class _IncongruenceDetectorScreenState extends State<IncongruenceDetectorScreen> {
  String _selectedAudience = 'all';
  int _currentIndex = 0;
  bool? _userAnswer; // true: congruent, false: incongruent
  bool _showFeedback = false;
  int _score = 0;
  int _totalAnswered = 0;

  List<IncongruenceItem> get _items => IncongruenceDatabase.getByAudience(_selectedAudience);

  void _onAnswer(bool answer) {
    if (_showFeedback) return;
    final item = _items[_currentIndex];
    final isCorrect = answer == item.isCongruent;

    if (isCorrect) {
      FeedbackService.success();
      _score++;
    } else {
      FeedbackService.lightClick();
    }
    _totalAnswered++;

    setState(() {
      _userAnswer = answer;
      _showFeedback = true;
    });

    TtsService.speak(
      '${isCorrect ? "¡Correcto!" : "¡Observa bien!"}. ${item.isCongruent ? "El mensaje es sincero." : "Existe una incongruencia entre las palabras y el cuerpo."} Emoción real: ${item.realEmotion}. ${item.explanation}',
    );
  }

  void _nextItem() {
    FeedbackService.lightClick();
    setState(() {
      _showFeedback = false;
      _userAnswer = null;
      if (_currentIndex < _items.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Loop or restart
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _items;
    final item = items[_currentIndex.clamp(0, items.length - 1)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detector de Incongruencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Escuchar frase y señales',
            onPressed: () {
              FeedbackService.lightClick();
              TtsService.speak('Frase del interlocutor: ${item.spokenPhrase}. Señales corporales observadas: ${item.physicalSignals.join(", ")}.');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 640;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Filter Chips (Audience Route)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Todos los Casos'),
                          selected: _selectedAudience == 'all',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedAudience == 'all' ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedAudience = 'all';
                              _currentIndex = 0;
                              _showFeedback = false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.psychology_rounded, size: 16),
                          label: const Text('Ruta Social / Neurodiversidad'),
                          selected: _selectedAudience == 'autism_focus',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedAudience == 'autism_focus' ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedAudience = 'autism_focus';
                              _currentIndex = 0;
                              _showFeedback = false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.business_center_rounded, size: 16),
                          label: const Text('Ruta Ventas y Negociación'),
                          selected: _selectedAudience == 'sales_focus',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedAudience == 'sales_focus' ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedAudience = 'sales_focus';
                              _currentIndex = 0;
                              _showFeedback = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Progress & Score Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Caso ${_currentIndex + 1} de ${items.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      BadgePill(
                        text: 'Aciertos: $_score / $_totalAnswered',
                        color: AppColors.primary,
                        icon: Icons.star_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main Scenario Presentation Card
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Speaker Role Badge
                        Row(
                          children: [
                            Icon(Icons.person_pin_rounded, size: 18, color: isDark ? AppColors.primaryLight : AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.speakerRole,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Verbal Quote Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded, size: 24, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.spokenPhrase,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Body Language Illustration & Physical Signals
                        if (isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ConoVeIllustration(
                                  illustrationKey: item.illustrationKey,
                                  width: 180,
                                  height: 180,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Señales corporales que observas:',
                                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 8),
                                    for (final sig in item.physicalSignals)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.remove_red_eye_rounded, size: 16, color: AppColors.accent),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                sig,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ConoVeIllustration(
                                    illustrationKey: item.illustrationKey,
                                    width: 180,
                                    height: 180,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Señales corporales que observas:',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              for (final sig in item.physicalSignals)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.remove_red_eye_rounded, size: 16, color: AppColors.accent),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          sig,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Question and Decision Buttons
                  if (!_showFeedback) ...[
                    Center(
                      child: Text(
                        '¿Las palabras coinciden con lo que dice su cuerpo?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('Es Sincero / Congruente', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            onPressed: () => _onAnswer(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.warning_amber_rounded),
                            label: const Text('Hay Contradicción', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            onPressed: () => _onAnswer(false),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Feedback Card
                    AppCard(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderSide: BorderSide(
                        color: _userAnswer == item.isCongruent ? AppColors.success : AppColors.error,
                        width: 2.0,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _userAnswer == item.isCongruent ? Icons.check_circle_rounded : Icons.info_rounded,
                                color: _userAnswer == item.isCongruent ? AppColors.success : AppColors.error,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _userAnswer == item.isCongruent ? '¡Diagnóstico Correcto!' : '¡Detalle Importante!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _userAnswer == item.isCongruent ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46)) : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Real Emotion
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.psychology_rounded, size: 18, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Emoción o Intención Real: ${item.realEmotion}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Scientific Explanation
                          Text(
                            item.explanation,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Recommended Action
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.3) : const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.4) : const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.indigo),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Regla de Acción Recomendada:',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.recommendedAction,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF312E81),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Next button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Siguiente Caso', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              onPressed: _nextItem,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
