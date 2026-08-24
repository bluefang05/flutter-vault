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

  String? _resolveAssetPath(String key) {
    final clean = key.toLowerCase().trim();
    const expressions = {
      'duchenne_smile': 'assets/images/expressions/duchenne_smile.png',
      'sonrisa_genuina': 'assets/images/expressions/sonrisa_genuina.png',
      'polite_smile': 'assets/images/expressions/polite_smile.png',
      'sonrisa_falsa': 'assets/images/expressions/sonrisa_falsa.png',
      'surprised_look': 'assets/images/expressions/surprised_look.png',
      'sorpresa': 'assets/images/expressions/sorpresa.png',
      'jaw_clenching': 'assets/images/expressions/jaw_clenching.png',
      'mandibula_apretada': 'assets/images/expressions/mandibula_apretada.png',
      'frowning_brow': 'assets/images/expressions/frowning_brow.png',
      'ceno_fruncido': 'assets/images/expressions/frowning_brow.png',
    };
    const postures = {
      'closed_posture': 'assets/images/postures/closed_posture.png',
      'brazos_cruzados': 'assets/images/postures/brazos_cruzados.png',
      'shrug': 'assets/images/postures/shrug.png',
      'encogerse_hombros': 'assets/images/postures/encogerse_hombros.png',
      'steepling_hands': 'assets/images/postures/steepling_hands.png',
      'manos_ojiva': 'assets/images/postures/manos_ojiva.png',
      'hand_on_chin': 'assets/images/postures/hand_on_chin.png',
      'pensador': 'assets/images/postures/hand_on_chin.png',
    };

    if (expressions.containsKey(clean)) return expressions[clean];
    if (postures.containsKey(clean)) return postures[clean];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = Theme.of(context).scaffoldBackgroundColor == Colors.black;

    final assetPath = _resolveAssetPath(illustrationKey);
    if (assetPath != null && !isHighContrast) {
      return Semantics(
        label: 'Ilustración visual de comunicación no verbal: ${illustrationKey.replaceAll('_', ' ')}',
        image: true,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            width: width,
            height: height,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              assetPath,
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackPainter(isDark, isHighContrast),
            ),
          ),
        ),
      );
    }

    final child = _buildFallbackPainter(isDark, isHighContrast);

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

  Widget _buildFallbackPainter(bool isDark, bool isHighContrast) {
    if (illustrationKey == 'logo' || illustrationKey == 'conove_logo' || illustrationKey == 'gestura_logo') {
      return CustomPaint(
        painter: GesturaLogoPainter(isDark: isDark, isHighContrast: isHighContrast),
        size: Size(width, height),
      );
    } else if (illustrationKey.startsWith('proxemics_') || illustrationKey.contains('proxemica') || illustrationKey == 'espacio') {
      final zone = illustrationKey.replaceAll('proxemics_', '').replaceAll('proxemica_', '');
      return CustomPaint(
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
      return CustomPaint(
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
      return CustomPaint(
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
      return CustomPaint(
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
      return CustomPaint(
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
      return CustomPaint(
        painter: ScenarioPainter(
          scenarioKey: cleanKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
        ),
        size: Size(width, height),
      );
    } else {
      return CustomPaint(
        painter: FacialExpressionPainter(
          expressionKey: illustrationKey,
          isDark: isDark,
          isHighContrast: isHighContrast,
          highlightAnatomy: highlightAnatomy,
        ),
        size: Size(width, height),
      );
    }
  }
}

typedef GesturaIllustration = ConoVeIllustration;

