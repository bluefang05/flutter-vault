import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'category.dart';

enum SignalTrafficLight {
  green('Luz Verde (Receptividad)', AppColors.success, Icons.check_circle_rounded),
  yellow('Luz Amarilla (Precaución / Duda)', AppColors.warning, Icons.warning_rounded),
  red('Luz Roja (Objeción / Barrera)', AppColors.error, Icons.cancel_rounded);

  final String label;
  final Color color;
  final IconData icon;

  const SignalTrafficLight(this.label, this.color, this.icon);
}

class GestureItem {
  final String id;
  final String name;
  final CategoryType category;
  final String bodyPart; // Ojos, Boca, Cejas, Voz, Brazos, Torso, Espacio, Digital
  final String summary;
  final String physiologicalDetails;
  final String probableMeaning;
  final List<String> alternativeMeanings;
  final String contextGuidance;
  final String whatToDo;
  final String salesTip;
  final String illustrationKey;
  final int difficulty; // 1: Fácil, 2: Intermedio, 3: Sutil
  final SignalTrafficLight signalType;

  const GestureItem({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyPart,
    required this.summary,
    required this.physiologicalDetails,
    required this.probableMeaning,
    required this.alternativeMeanings,
    required this.contextGuidance,
    required this.whatToDo,
    required this.salesTip,
    required this.illustrationKey,
    this.difficulty = 1,
    this.signalType = SignalTrafficLight.green,
  });
}
