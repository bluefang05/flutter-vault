import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../data/gesture_database.dart';
import '../models/category.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/common/section_header.dart';
import '../widgets/illustrations/illustration_widget.dart';

class ComparePair {
  final String title;
  final String gestureIdA;
  final String gestureIdB;
  final String coreDifference;

  const ComparePair({
    required this.title,
    required this.gestureIdA,
    required this.gestureIdB,
    required this.coreDifference,
  });
}

class CompareScreen extends StatefulWidget {
  final String? initialGestureIdA;
  final String? initialGestureIdB;

  const CompareScreen({
    super.key,
    this.initialGestureIdA,
    this.initialGestureIdB,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  static const List<ComparePair> presetPairs = [
    ComparePair(
      title: 'Sonrisa Genuina vs. Sonrisa Social',
      gestureIdA: 'duchenne_smile',
      gestureIdB: 'sonrisa_social',
      coreDifference: 'En la sonrisa genuina se contraen los ojos ("patas de gallo"); en la social los ojos quedan inmóviles.',
    ),
    ComparePair(
      title: 'Postura Abierta vs. Brazos Cruzados',
      gestureIdA: 'postura_abierta',
      gestureIdB: 'postura_cerrada',
      coreDifference: 'La postura abierta despeja el torso y denota receptividad; los brazos cruzados crean una barrera física defensiva.',
    ),
    ComparePair(
      title: 'Inclinación Adelante vs. Inclinación Atrás',
      gestureIdA: 'inclinacion_adelante',
      gestureIdB: 'inclinacion_atras',
      coreDifference: 'Inclinarse hacia adelante reduce la distancia y muestra alto interés; recostarse atrás marca distancia o escepticismo.',
    ),
    ComparePair(
      title: 'Manos en Ojiva vs. Frotarse las Manos',
      gestureIdA: 'manos_ojiva',
      gestureIdB: 'frotar_manos',
      coreDifference: 'La ojiva transmite máxima autoridad y convicción intelectual; frotarse las manos denota expectativa o nerviosismo.',
    ),
    ComparePair(
      title: 'Tono Asertivo vs. Inflexión Sarcástica',
      gestureIdA: 'tono_asertivo',
      gestureIdB: 'tono_sarcastico',
      coreDifference: 'El tono asertivo mantiene cadencia estable y transparente; el sarcasmo modula con caída irónica que contradice las palabras.',
    ),
    ComparePair(
      title: 'Mesa Redonda vs. Escritorio Barrera',
      gestureIdA: 'mesa_redonda',
      gestureIdB: 'mesa_barrera',
      coreDifference: 'La mesa redonda distribuye el poder de forma igualitaria; el escritorio frontal actúa como escudo de dominancia jerárquica.',
    ),
  ];

  late String _selectedIdA;
  late String _selectedIdB;

  @override
  void initState() {
    super.initState();
    _selectedIdA = widget.initialGestureIdA ?? presetPairs.first.gestureIdA;
    _selectedIdB = widget.initialGestureIdB ?? presetPairs.first.gestureIdB;
  }

  void _applyPreset(ComparePair pair) {
    FeedbackService.lightClick();
    setState(() {
      _selectedIdA = pair.gestureIdA;
      _selectedIdB = pair.gestureIdB;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemA = GestureDatabase.getById(_selectedIdA) ?? GestureDatabase.items.first;
    final itemB = GestureDatabase.getById(_selectedIdB) ?? GestureDatabase.items[1];

    final catA = CategoryInfo.getInfo(itemA.category);
    final catB = CategoryInfo.getInfo(itemB.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador Visual A/B'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const SectionHeader(
            title: 'Pares Clásicos de Alto Contraste',
            subtitle: 'Selecciona una pareja de gestos para comparar sus diferencias físicas',
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presetPairs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final pair = presetPairs[i];
                final isSelected = _selectedIdA == pair.gestureIdA && _selectedIdB == pair.gestureIdB;
                return ChoiceChip(
                  label: Text(pair.title),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (_) => _applyPreset(pair),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Side by Side Visual Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card A
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      BadgePill(text: 'Señal A', color: catA.primaryColor),
                      const SizedBox(height: 8),
                      ConoVeIllustration(
                        illustrationKey: itemA.illustrationKey,
                        width: 120,
                        height: 120,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemA.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      BadgePill(
                        text: itemA.signalType.label.split(' ').first,
                        color: itemA.signalType.color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // VS Badge
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('VS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              // Card B
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      BadgePill(text: 'Señal B', color: catB.primaryColor),
                      const SizedBox(height: 8),
                      ConoVeIllustration(
                        illustrationKey: itemB.illustrationKey,
                        width: 120,
                        height: 120,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemB.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      BadgePill(
                        text: itemB.signalType.label.split(' ').first,
                        color: itemB.signalType.color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Point-by-Point Differences Breakdown
          const SectionHeader(
            title: 'Diferencias Físicas y de Significado',
            subtitle: 'En qué fijarse para no confundirlos',
          ),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildComparisonRow(
                  label: 'Pista Física Visual',
                  textA: itemA.physiologicalDetails,
                  textB: itemB.physiologicalDetails,
                  colorA: catA.primaryColor,
                  colorB: catB.primaryColor,
                ),
                const Divider(height: 24),
                _buildComparisonRow(
                  label: 'Significado Principal',
                  textA: itemA.probableMeaning,
                  textB: itemB.probableMeaning,
                  colorA: catA.primaryColor,
                  colorB: catB.primaryColor,
                ),
                const Divider(height: 24),
                _buildComparisonRow(
                  label: 'Consejo de Reacción',
                  textA: itemA.whatToDo,
                  textB: itemB.whatToDo,
                  colorA: catA.primaryColor,
                  colorB: catB.primaryColor,
                ),
                const Divider(height: 24),
                _buildComparisonRow(
                  label: 'Aplicación en Ventas',
                  textA: itemA.salesTip,
                  textB: itemB.salesTip,
                  colorA: catA.primaryColor,
                  colorB: catB.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String textA,
    required String textB,
    required Color colorA,
    required Color colorB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorA.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(textA, style: const TextStyle(fontSize: 12.5, height: 1.35)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorB.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(textB, style: const TextStyle(fontSize: 12.5, height: 1.35)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
