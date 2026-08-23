import 'package:flutter/material.dart';
import 'facial_expression_painter.dart';
import 'body_posture_painter.dart';
import 'proxemics_painter.dart';
import 'digital_signals_painter.dart';
import 'paralinguistics_painter.dart';
import 'environment_painter.dart';
import 'scenario_painter.dart';
import 'conove_logo_painter.dart';

class ConoVeIllustration extends StatelessWidget {
  final String illustrationKey;
  final double width;
  final double height;
  final bool highlightAnatomy;
  final BorderRadius? borderRadius;

  const ConoVeIllustration({
    super.key,
    required this.illustrationKey,
    this.width = 120,
    this.height = 120,
    this.highlightAnatomy = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = Theme.of(context).scaffoldBackgroundColor == Colors.black;

    Widget child;

    if (illustrationKey == 'logo' || illustrationKey == 'conove_logo') {
      child = CustomPaint(
        painter: ConoVeLogoPainter(isDark: isDark, isHighContrast: isHighContrast),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('proxemics_') || illustrationKey.contains('proxemica') || illustrationKey == 'espacio') {
      final zone = illustrationKey.replaceAll('proxemics_', '').replaceAll('proxemica_', '');
      child = CustomPaint(
        painter: ProxemicsPainter(
          activeZone: zone.isEmpty ? 'all' : zone,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('voice_') ||
        illustrationKey.startsWith('paralinguistics_') ||
        illustrationKey.startsWith('silence_') ||
        illustrationKey.contains('volumen') ||
        illustrationKey.contains('tono') ||
        illustrationKey.contains('silencio') ||
        illustrationKey.contains('voz') ||
        illustrationKey.contains('pausa') ||
        illustrationKey.contains('sarcastico')) {
      final cleanKey = illustrationKey.replaceAll('voice_', '').replaceAll('paralinguistics_', '');
      child = CustomPaint(
        painter: ParalinguisticsPainter(
          soundKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('env_') ||
        illustrationKey.startsWith('dress_') ||
        illustrationKey.startsWith('desk_') ||
        illustrationKey.contains('vestimenta') ||
        illustrationKey.contains('mesa') ||
        illustrationKey.contains('escritorio') ||
        illustrationKey.contains('angulo') ||
        illustrationKey.contains('iluminacion') ||
        illustrationKey.contains('apariencia') ||
        illustrationKey.contains('entorno')) {
      final cleanKey = illustrationKey.replaceAll('env_', '');
      child = CustomPaint(
        painter: EnvironmentPainter(
          envKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('digital_') ||
        illustrationKey.contains('mayusculas') ||
        illustrationKey.contains('visto') ||
        illustrationKey.contains('ghosting') ||
        illustrationKey.contains('emoji') ||
        illustrationKey.contains('audio') ||
        illustrationKey.contains('chat')) {
      final cleanKey = illustrationKey.replaceAll('digital_', '');
      child = CustomPaint(
        painter: DigitalSignalsPainter(
          digitalKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('posture_') ||
        illustrationKey.contains('postura') ||
        illustrationKey.contains('brazos') ||
        illustrationKey.contains('inclinacion') ||
        illustrationKey.contains('hombros') ||
        illustrationKey.contains('manos') ||
        illustrationKey.contains('dedos') ||
        illustrationKey.contains('cabeza') ||
        illustrationKey.contains('cuello') ||
        illustrationKey.contains('piernas') ||
        illustrationKey.contains('apreton') ||
        illustrationKey.contains('ojiva') ||
        illustrationKey.contains('shrug') ||
        illustrationKey.contains('hand') ||
        illustrationKey.contains('finger') ||
        illustrationKey.contains('head_') ||
        illustrationKey.contains('legs_') ||
        illustrationKey.contains('neck') ||
        illustrationKey.contains('steeple') ||
        illustrationKey.contains('leaning')) {
      final cleanKey = illustrationKey.replaceAll('posture_', '');
      child = CustomPaint(
        painter: BodyPosturePainter(
          postureKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('scenario_') ||
        illustrationKey.contains('ventas') ||
        illustrationKey.contains('laboral') ||
        illustrationKey.contains('entrevista') ||
        illustrationKey.contains('cafe')) {
      final cleanKey = illustrationKey.replaceAll('scenario_', '');
      child = CustomPaint(
        painter: ScenarioPainter(
          scenarioKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else {
      // Default to facial expression
      child = CustomPaint(
        painter: FacialExpressionPainter(
          expressionKey: illustrationKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
          highlightAnatomy: highlightAnatomy,
        ),
        size: Size(width, height),
      );
    }

    return Semantics(
      label: 'Ilustración visual de comunicación no verbal: ${illustrationKey.replaceAll('_', ' ')}',
      image: true,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}

