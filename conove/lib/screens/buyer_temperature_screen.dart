import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/common/section_header.dart';
import '../core/services/feedback_service.dart';
import '../core/services/tts_service.dart';

class BuyerSignal {
  final String id;
  final String label;
  final int score;
  final String category; // 'green', 'yellow', 'red'
  final String takeaway;
  final IconData icon;

  const BuyerSignal({
    required this.id,
    required this.label,
    required this.score,
    required this.category,
    required this.takeaway,
    required this.icon,
  });
}

class BuyerTemperatureScreen extends StatefulWidget {
  const BuyerTemperatureScreen({super.key});

  static const List<BuyerSignal> signals = [
    // --- LUZ VERDE (SEÑALES DE COMPRA) ---
    BuyerSignal(
      id: 'lean_forward',
      label: 'Inclinación frontal hacia la mesa',
      score: 3,
      category: 'green',
      takeaway: 'Indica alto compromiso, interés genuino y deseo de acercamiento.',
      icon: Icons.airline_seat_recline_normal_rounded,
    ),
    BuyerSignal(
      id: 'duchenne',
      label: 'Sonrisa genuina (ojos achinados)',
      score: 2,
      category: 'green',
      takeaway: 'Comodidad real y aprobación emocional de la propuesta.',
      icon: Icons.sentiment_very_satisfied_rounded,
    ),
    BuyerSignal(
      id: 'open_hands',
      label: 'Palmas abiertas y visibles',
      score: 3,
      category: 'green',
      takeaway: 'Transparencia, receptividad y ausencia de agendas ocultas.',
      icon: Icons.pan_tool_rounded,
    ),
    BuyerSignal(
      id: 'slow_nod',
      label: 'Asentimiento de cabeza rítmico y lento',
      score: 2,
      category: 'green',
      takeaway: 'Validación activa de los argumentos que estás exponiendo.',
      icon: Icons.check_circle_outline_rounded,
    ),
    BuyerSignal(
      id: 'steepling',
      label: 'Manos en ojiva / campanario',
      score: 2,
      category: 'green',
      takeaway: 'Confianza y autoridad en la decisión que está a punto de tomar.',
      icon: Icons.change_history_rounded,
    ),

    // --- LUZ AMARILLA (EVALUACIÓN / DUDA) ---
    BuyerSignal(
      id: 'hand_chin',
      label: 'Mano en la barbilla (pensando)',
      score: 0,
      category: 'yellow',
      takeaway: 'Procesamiento analítico. Está sopesando el balance costo/beneficio.',
      icon: Icons.psychology_rounded,
    ),
    BuyerSignal(
      id: 'head_tilt',
      label: 'Inclinación lateral de la cabeza',
      score: 1,
      category: 'yellow',
      takeaway: 'Curiosidad y escucha atenta, esperando un dato que lo convenza.',
      icon: Icons.hearing_rounded,
    ),
    BuyerSignal(
      id: 'glasses_adjust',
      label: 'Mirar por encima de lentes / frotar puente',
      score: -1,
      category: 'yellow',
      takeaway: 'Escrutinio crítico o sobrecarga momentánea de datos.',
      icon: Icons.remove_red_eye_outlined,
    ),

    // --- LUZ ROJA (BARRERA / OBJECIÓN) ---
    BuyerSignal(
      id: 'crossed_arms',
      label: 'Brazos cruzados en el pecho',
      score: -3,
      category: 'red',
      takeaway: 'Barrera física de autoprotección o desacuerdo con el precio/plazo.',
      icon: Icons.cancel_rounded,
    ),
    BuyerSignal(
      id: 'tight_lips',
      label: 'Labios apretados en línea fina',
      score: -2,
      category: 'red',
      takeaway: 'Contención de una objeción o desacuerdo que no quiere verbalizar aún.',
      icon: Icons.remove_circle_outline_rounded,
    ),
    BuyerSignal(
      id: 'neck_touch',
      label: 'Mano tocando o frotando la nuca',
      score: -2,
      category: 'red',
      takeaway: 'Estrés, inseguridad o incomodidad con las condiciones planteadas.',
      icon: Icons.pan_tool_alt_rounded,
    ),
    BuyerSignal(
      id: 'finger_tap',
      label: 'Tamborileo de dedos en la mesa',
      score: -2,
      category: 'red',
      takeaway: 'Impaciencia. Siente que la reunión es demasiado larga.',
      icon: Icons.touch_app_outlined,
    ),
    BuyerSignal(
      id: 'lean_back_distance',
      label: 'Reclinarse hacia atrás con distancia',
      score: -3,
      category: 'red',
      takeaway: 'Retracción y desconexión psicológica de la propuesta.',
      icon: Icons.airline_seat_flat_rounded,
    ),
  ];

  @override
  State<BuyerTemperatureScreen> createState() => _BuyerTemperatureScreenState();
}

class _BuyerTemperatureScreenState extends State<BuyerTemperatureScreen> {
  final Set<String> _selectedSignalIds = {};

  int get _totalScore {
    int total = 0;
    for (final s in BuyerTemperatureScreen.signals) {
      if (_selectedSignalIds.contains(s.id)) {
        total += s.score;
      }
    }
    return total;
  }

  // Calculate percentage: normalized between 0% and 100%
  double get _temperaturePercent {
    if (_selectedSignalIds.isEmpty) return 0.50; // Neutral baseline (50%)
    final score = _totalScore;
    // Map -8 to +8 into 0.0 to 1.0
    final raw = 0.50 + (score / 16.0);
    return raw.clamp(0.05, 1.0);
  }

  String get _temperatureVerdict {
    final pct = _temperaturePercent;
    if (_selectedSignalIds.isEmpty) return 'Selecciona señales para calibrar';
    if (pct >= 0.70) return '🔥 Luz Verde: Momento Óptimo de Cierre';
    if (pct >= 0.40) return '⚡ Luz Amarilla: En Evaluación / Aclarar Dudas';
    return '🧊 Luz Roja: Barrera Activa / No Empujes Cierre';
  }

  String get _tacticalAdvice {
    final pct = _temperaturePercent;
    if (_selectedSignalIds.isEmpty) {
      return 'Toca las señales corporales que estás observando en tu cliente para recibir la táctica recomendada.';
    }
    if (pct >= 0.70) {
      return 'El cliente ha mostrado múltiples señales de compra. DEJA DE EXPLICAR características técnicas. Haz el llamado a la acción directo: "¿Te parece bien si enviamos el contrato hoy para iniciar el lunes?"';
    }
    if (pct >= 0.40) {
      return 'El cliente tiene interés pero aún no está convencido. Haz preguntas abiertas de validación: "¿Qué aspecto de la propuesta consideras más prioritario resolver primero?" y escucha sin interrumpir.';
    }
    return 'El cliente tiene una objeción no resuelta. Si intentas cerrar ahora, recibirás un rechazo definitivo. Haz una pausa, descruza tus manos y pregunta amablemente: "Noto cierta duda en este punto, ¿hay algún detalle del presupuesto o cronograma que debamos ajustar?"';
  }

  Color get _verdictColor {
    final pct = _temperaturePercent;
    if (_selectedSignalIds.isEmpty) return AppColors.primary;
    if (pct >= 0.70) return const Color(0xFF059669);
    if (pct >= 0.40) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  void _toggleSignal(String id) {
    FeedbackService.lightClick();
    setState(() {
      if (_selectedSignalIds.contains(id)) {
        _selectedSignalIds.remove(id);
      } else {
        _selectedSignalIds.add(id);
      }
    });
  }

  void _reset() {
    FeedbackService.lightClick();
    setState(() {
      _selectedSignalIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = _temperaturePercent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termómetro de Negociación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reiniciar Señales',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Escuchar Diagnóstico',
            onPressed: () {
              FeedbackService.lightClick();
              TtsService.speak('Temperatura del cliente: $_temperatureVerdict. Táctica recomendada: $_tacticalAdvice');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 640;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Gauge / Meter Banner
                  AppCard(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderSide: BorderSide(color: _verdictColor, width: 2.0),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thermostat_rounded, size: 28, color: _verdictColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _temperatureVerdict,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: _verdictColor,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedSignalIds.length} señales observadas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _verdictColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(pct * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _verdictColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Progress Gauge Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 12,
                            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(_verdictColor),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tactical Advice Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bolt_rounded, size: 20, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _tacticalAdvice,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Signals Selection Sections
                  const SectionHeader(
                    title: '🟢 Señales de Compra y Apertura',
                    subtitle: 'Suma puntos de receptividad y luz verde',
                  ),
                  _buildSignalGroup(BuyerTemperatureScreen.signals.where((s) => s.category == 'green').toList(), isDark),
                  const SizedBox(height: 16),

                  const SectionHeader(
                    title: '🟡 Señales de Evaluación y Duda',
                    subtitle: 'El cliente está procesando la información',
                  ),
                  _buildSignalGroup(BuyerTemperatureScreen.signals.where((s) => s.category == 'yellow').toList(), isDark),
                  const SizedBox(height: 16),

                  const SectionHeader(
                    title: '🔴 Señales de Barrera y Objeción',
                    subtitle: 'Indican resistencia, molestia o incomodidad',
                  ),
                  _buildSignalGroup(BuyerTemperatureScreen.signals.where((s) => s.category == 'red').toList(), isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignalGroup(List<BuyerSignal> list, bool isDark) {
    return Column(
      children: list.map((s) {
        final isSelected = _selectedSignalIds.contains(s.id);
        final color = s.category == 'green'
            ? const Color(0xFF059669)
            : (s.category == 'yellow' ? const Color(0xFFD97706) : const Color(0xFFDC2626));

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AppCard(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderSide: BorderSide(
              color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.8 : 1.0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => _toggleSignal(s.id),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: isSelected ? color : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.takeaway,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.score > 0 ? '+${s.score}' : '${s.score}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
