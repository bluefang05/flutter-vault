import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../data/gesture_database.dart';
import '../models/gesture_item.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/common/section_header.dart';
import '../widgets/illustrations/illustration_widget.dart';
import '../core/services/tts_service.dart';
import 'gesture_detail_screen.dart';

class DecisionTreeScreen extends StatefulWidget {
  const DecisionTreeScreen({super.key});

  @override
  State<DecisionTreeScreen> createState() => _DecisionTreeScreenState();
}

class _DecisionTreeScreenState extends State<DecisionTreeScreen> {
  String? _selectedZone;
  GestureItem? _selectedGesture;

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  static const List<Map<String, dynamic>> zones = [
    {
      'id': 'Ojos',
      'label': 'Ojos y Mirada',
      'icon': Icons.visibility_rounded,
      'color': AppColors.primary,
      'clues': ['duchenne_smile', 'narrowed_eyes', 'closed_eyelids', 'averted_gaze', 'pupil_dilation', 'winking_face', 'flash_cejas'],
    },
    {
      'id': 'Boca',
      'label': 'Boca y Labios',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'color': AppColors.coral,
      'clues': ['sonrisa_social', 'tight_lips', 'smirk_contempt', 'jaw_clenching', 'morder_labio', 'tristeza', 'sorpresa'],
    },
    {
      'id': 'Brazos',
      'label': 'Brazos y Postura',
      'icon': Icons.accessibility_new_rounded,
      'color': AppColors.accent,
      'clues': ['postura_abierta', 'postura_cerrada', 'manos_ojiva', 'manos_caderas', 'tocarse_cuello', 'hands_behind_head', 'hands_behind_back', 'frotar_manos', 'tamborileo_dedos', 'inclinacion_adelante', 'inclinacion_atras'],
    },
    {
      'id': 'Voz',
      'label': 'Voz y Silencios',
      'icon': Icons.record_voice_over_rounded,
      'color': AppColors.purple,
      'clues': ['sarcastic_inflection', 'assertive_voice', 'silence_tense', 'silence_reflective', 'voice_volume_high', 'voice_volume_low', 'voice_speed_fast', 'voice_monotone'],
    },
    {
      'id': 'Espacio',
      'label': 'Espacio y Mesa',
      'icon': Icons.meeting_room_rounded,
      'color': AppColors.info,
      'clues': ['espacio_intimo', 'espacio_personal', 'espacio_social', 'round_table', 'desk_barrier', 'seating_angle'],
    },
    {
      'id': 'Digital',
      'label': 'Mensajería y Chat',
      'icon': Icons.chat_rounded,
      'color': AppColors.primaryLight,
      'clues': ['digital_mayusculas', 'digital_ok_seco', 'digital_ghosting', 'digital_emojis', 'digital_audio'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Árbol de Decisión Social'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Banner
          AppCard(
            color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded, color: AppColors.success, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Regla: Si veo X ➔ Significa Y ➔ Hago Z',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Descifra qué hacer en 3 toques sin memorizar teoría.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Paso 1: Seleccionar Zona
          const SectionHeader(
            title: 'Paso 1: ¿Dónde viste la señal?',
            subtitle: 'Toca la zona corporal que observaste',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: zones.map((z) {
              final isSelected = _selectedZone == z['id'];
              return ChoiceChip(
                avatar: Icon(z['icon'] as IconData, size: 16, color: isSelected ? Colors.white : z['color'] as Color),
                label: Text(z['label'] as String),
                selected: isSelected,
                selectedColor: (z['color'] as Color).withValues(alpha: 0.85),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                onSelected: (val) {
                  FeedbackService.lightClick();
                  setState(() {
                    _selectedZone = val ? (z['id'] as String) : null;
                    _selectedGesture = null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Paso 2: Seleccionar Gesto Específico
          if (_selectedZone != null) ...[
            const SectionHeader(
              title: 'Paso 2: ¿Qué patrón específico viste?',
              subtitle: 'Selecciona la señal que mejor describe lo ocurrido',
            ),
            _buildGestureOptionsList(isDark),
            const SizedBox(height: 24),
          ],

          // Paso 3: Diagnóstico y Acción Directa
          if (_selectedGesture != null) ...[
            const SectionHeader(
              title: 'Paso 3: Diagnóstico y Acción Inmediata',
              subtitle: 'Qué significa y cómo reaccionar paso a paso',
            ),
            _buildDiagnosisCard(_selectedGesture!, isDark),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildGestureOptionsList(bool isDark) {
    final zoneData = zones.firstWhere((z) => z['id'] == _selectedZone);
    final clueIds = zoneData['clues'] as List<String>;
    final items = GestureDatabase.items.where((g) => clueIds.contains(g.id) || clueIds.contains(g.illustrationKey)).toList();

    return Column(
      children: items.map((gesture) {
        final isSelected = _selectedGesture?.id == gesture.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
            borderSide: isSelected ? const BorderSide(color: AppColors.primary, width: 2) : null,
            onTap: () {
              FeedbackService.lightClick();
              setState(() => _selectedGesture = gesture);
            },
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ConoVeIllustration(
                  illustrationKey: gesture.illustrationKey,
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gesture.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gesture.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  gesture.signalType.icon,
                  color: gesture.signalType.color,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiagnosisCard(GestureItem g, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ConoVeIllustration(
                illustrationKey: g.illustrationKey,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BadgePill(
                          text: g.signalType.label,
                          color: g.signalType.color,
                        ),
                        const Spacer(),
                        ValueListenableBuilder<String?>(
                          valueListenable: TtsService.currentSpeakingIdNotifier,
                          builder: (context, speakingId, _) {
                            final isSpeaking = speakingId == g.id;
                            return IconButton(
                              icon: Icon(
                                isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                                color: isSpeaking ? AppColors.accent : AppColors.primary,
                                size: 22,
                              ),
                              tooltip: isSpeaking ? 'Detener lectura' : 'Escuchar en voz alta',
                              onPressed: () {
                                FeedbackService.lightClick();
                                final textToSpeak = '${g.name}. Significado: ${g.probableMeaning}. Qué debes hacer: ${g.whatToDo}. En ventas: ${g.salesTip}';
                                TtsService.speak(textToSpeak, gestureId: g.id);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      g.name,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Significado
          _buildActionItem(
            icon: Icons.psychology_rounded,
            iconColor: AppColors.purple,
            title: '¿Qué significa realmente?',
            description: g.probableMeaning,
          ),
          const SizedBox(height: 14),

          // Acción Recomendada
          _buildActionItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.success,
            title: '¿Qué debes hacer / decir tú?',
            description: g.whatToDo,
          ),
          const SizedBox(height: 14),

          // Tip de Ventas / Negociación
          _buildActionItem(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.accent,
            title: 'Táctica de Ventas y Negociación',
            description: g.salesTip,
          ),
          const SizedBox(height: 18),

          // Botón para ver ficha completa
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: const Text('Ver Ficha Completa en el Manual'),
              onPressed: () {
                FeedbackService.lightClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GestureDetailScreen(gestureId: g.id)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
