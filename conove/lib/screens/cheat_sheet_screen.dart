import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../data/gesture_database.dart';
import '../models/gesture_item.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/illustrations/illustration_widget.dart';
import 'gesture_detail_screen.dart';

class CheatSheetScreen extends StatefulWidget {
  const CheatSheetScreen({super.key});

  @override
  State<CheatSheetScreen> createState() => _CheatSheetScreenState();
}

class _CheatSheetScreenState extends State<CheatSheetScreen> {
  SignalTrafficLight? _filterLight;

  static const List<String> priorityIds = [
    'duchenne_smile',
    'sonrisa_social',
    'postura_abierta',
    'postura_cerrada',
    'inclinacion_adelante',
    'inclinacion_atras',
    'manos_ojiva',
    'manos_caderas',
    'tocarse_cuello',
    'frotar_manos',
    'tight_lips',
    'smirk_contempt',
    'jaw_clenching',
    'pupil_dilation',
    'sarcastic_inflection',
    'assertive_voice',
    'mesa_redonda',
    'mesa_barrera',
    'seating_angle',
    'digital_visto',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var items = priorityIds
        .map((id) => GestureDatabase.getById(id))
        .whereType<GestureItem>()
        .toList();

    if (_filterLight != null) {
      items = items.where((i) => i.signalType == _filterLight).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Bolsillo (Cheat Sheet)'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Banner
          AppCard(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.accent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Resumen Táctico de Negociación',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Las 20 señales críticas de compra, duda y objeción para repasar en 30 segundos.',
                  style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Semáforo Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todas (20)'),
                  selected: _filterLight == null,
                  onSelected: (_) {
                    FeedbackService.lightClick();
                    setState(() => _filterLight = null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  label: const Text('Luz Verde'),
                  selected: _filterLight == SignalTrafficLight.green,
                  onSelected: (_) {
                    FeedbackService.lightClick();
                    setState(() => _filterLight = SignalTrafficLight.green);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.warning_rounded, size: 16, color: AppColors.warning),
                  label: const Text('Luz Amarilla'),
                  selected: _filterLight == SignalTrafficLight.yellow,
                  onSelected: (_) {
                    FeedbackService.lightClick();
                    setState(() => _filterLight = SignalTrafficLight.yellow);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.error),
                  label: const Text('Luz Roja'),
                  selected: _filterLight == SignalTrafficLight.red,
                  onSelected: (_) {
                    FeedbackService.lightClick();
                    setState(() => _filterLight = SignalTrafficLight.red);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cards list
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {
                  FeedbackService.lightClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GestureDetailScreen(gestureId: item.id)),
                  );
                },
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConoVeIllustration(
                      illustrationKey: item.illustrationKey,
                      width: 68,
                      height: 68,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              BadgePill(
                                text: item.signalType.label.split(' ').first,
                                color: item.signalType.color,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: 'Significado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: item.probableMeaning),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: 'Acción: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: item.whatToDo),
                              ],
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
          }),
        ],
      ),
    );
  }
}
