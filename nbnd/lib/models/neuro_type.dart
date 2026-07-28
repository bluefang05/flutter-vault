import 'package:flutter/material.dart';

enum NeuroType {
  tdah,
  tea,
  tlp,
  tid,
  toc,
  alexitimia,
  anhedonia,
  tag;

  String get code => switch (this) {
        NeuroType.tdah => 'TDAH',
        NeuroType.tea => 'TEA',
        NeuroType.tlp => 'TLP',
        NeuroType.tid => 'TID',
        NeuroType.toc => 'TOC',
        NeuroType.alexitimia => 'ALX',
        NeuroType.anhedonia => 'ANH',
        NeuroType.tag => 'TAG',
      };

  String get powerName => switch (this) {
        NeuroType.tdah => 'Impulso',
        NeuroType.tea => 'Patrón',
        NeuroType.tlp => 'Resonancia',
        NeuroType.tid => 'Perspectivas',
        NeuroType.toc => 'Secuencia',
        NeuroType.alexitimia => 'Silencio',
        NeuroType.anhedonia => 'Vacío',
        NeuroType.tag => 'Anticipación',
      };

  String get description => switch (this) {
        NeuroType.tdah =>
          'Movimiento rápido, aperturas breves e hiperfoco que ralentiza el entorno.',
        NeuroType.tea =>
          'Patrones más legibles, vista previa y estabilidad frente a cambios bruscos.',
        NeuroType.tlp =>
          'La cercanía al peligro carga resonancia para liberar una onda protectora.',
        NeuroType.tid =>
          'Alterna perspectivas y salta al punto opuesto para atravesar patrones dobles.',
        NeuroType.toc =>
          'Secuencias geométricas predecibles y capacidad de alinear una abertura.',
        NeuroType.alexitimia =>
          'Menor velocidad, más reserva y lectura emocional reducida del entorno.',
        NeuroType.anhedonia =>
          'Inmunidad temporal absoluta. Un breve momento donde el entorno no puede herirte.',
        NeuroType.tag =>
          'Anticipa riesgos y puede retroceder brevemente cuando una decisión falla.',
      };

  Color get color => switch (this) {
        NeuroType.tdah => const Color(0xFFFFA45B),
        NeuroType.tea => const Color(0xFF59D7FF),
        NeuroType.tlp => const Color(0xFFFF6E9A),
        NeuroType.tid => const Color(0xFFB58CFF),
        NeuroType.toc => const Color(0xFF55E6C1),
        NeuroType.alexitimia => const Color(0xFF8BD3C7),
        NeuroType.anhedonia => const Color(0xFFA0AEC0),
        NeuroType.tag => const Color(0xFFFFD166),
      };

  static NeuroType fromCode(String? value) {
    return NeuroType.values.firstWhere(
      (NeuroType item) => item.code == value,
      orElse: () => NeuroType.tdah,
    );
  }
}
