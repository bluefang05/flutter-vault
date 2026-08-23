import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum CategoryType {
  expresionesFaciales,
  factoresParalinguisticos,
  lenguajeCorporal,
  proxemica,
  entornoApariencia,
  comunicacionDigital,
}

class CategoryInfo {
  final CategoryType type;
  final String title;
  final String shortTitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color containerColor;
  final String chapterReference;

  const CategoryInfo({
    required this.type,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.containerColor,
    required this.chapterReference,
  });

  static const List<CategoryInfo> allCategories = [
    CategoryInfo(
      type: CategoryType.expresionesFaciales,
      title: 'Expresiones y Señales Faciales',
      shortTitle: 'Facial',
      description: 'Sonrisas Duchenne vs cortesía, ceño, mirada de desdén, ojos entrecerrados y microgestos.',
      icon: Icons.face_rounded,
      primaryColor: AppColors.primary,
      containerColor: AppColors.primaryContainer,
      chapterReference: 'Capítulo 3 y 6',
    ),
    CategoryInfo(
      type: CategoryType.factoresParalinguisticos,
      title: 'Factores Paralingüísticos',
      shortTitle: 'Voz y Tono',
      description: 'El tono, ritmo, volumen, timbre de la voz y los silencios con sus significados.',
      icon: Icons.record_voice_over_rounded,
      primaryColor: AppColors.purple,
      containerColor: Color(0xFFEDE9FE),
      chapterReference: 'Capítulo 2',
    ),
    CategoryInfo(
      type: CategoryType.lenguajeCorporal,
      title: 'Posturas y Lenguaje Corporal',
      shortTitle: 'Posturas',
      description: 'Posturas abiertas vs cerradas, orientación del cuerpo, inclinación frontal y manos.',
      icon: Icons.accessibility_new_rounded,
      primaryColor: AppColors.accent,
      containerColor: AppColors.accentLight,
      chapterReference: 'Capítulo 4 y 5',
    ),
    CategoryInfo(
      type: CategoryType.proxemica,
      title: 'Proximidad y Espacio Personal',
      shortTitle: 'Proxémica',
      description: 'Las 4 burbujas invisibles: Espacio Íntimo, Personal, Social y Público.',
      icon: Icons.radar_rounded,
      primaryColor: AppColors.indigo,
      containerColor: Color(0xFFE0E7FF),
      chapterReference: 'Capítulo 7',
    ),
    CategoryInfo(
      type: CategoryType.entornoApariencia,
      title: 'Entorno, Espacio y Apariencia',
      shortTitle: 'Entorno',
      description: 'Muebles, iluminación, vestimenta formal/casual, accesorios e higiene.',
      icon: Icons.chair_rounded,
      primaryColor: AppColors.emerald,
      containerColor: AppColors.successContainer,
      chapterReference: 'Capítulo 8 y 9',
    ),
    CategoryInfo(
      type: CategoryType.comunicacionDigital,
      title: 'Comunicación No Verbal Digital',
      shortTitle: 'Digital',
      description: 'Emojis, mayúsculas, respuestas secas ("ok"), visto y tiempos de respuesta.',
      icon: Icons.chat_bubble_outline_rounded,
      primaryColor: AppColors.coral,
      containerColor: Color(0xFFFFE4E6),
      chapterReference: 'Capítulo 10',
    ),
  ];

  static CategoryInfo getInfo(CategoryType type) {
    return allCategories.firstWhere((cat) => cat.type == type);
  }
}
