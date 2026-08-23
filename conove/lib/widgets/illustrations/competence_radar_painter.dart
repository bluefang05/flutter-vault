import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CompetenceRadarPainter extends CustomPainter {
  final Map<String, double> scores; // 0.0 to 1.0 for each of the 6 categories
  final bool isDark;
  final bool isHighContrast;

  CompetenceRadarPainter({
    required this.scores,
    this.isDark = false,
    this.isHighContrast = false,
  });

  static const List<String> categories = [
    'Rostro',
    'Voz',
    'Cuerpo',
    'Espacio',
    'Entorno',
    'Digital',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;

    final gridPaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.4)
          : (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final spokePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.5)
          : (isDark ? Colors.white30 : const Color(0xFF94A3B8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw concentric polygon webs (levels 25%, 50%, 75%, 100%)
    const int levels = 4;
    for (int lvl = 1; lvl <= levels; lvl++) {
      final r = radius * (lvl / levels);
      final webPath = Path();
      for (int i = 0; i < categories.length; i++) {
        final angle = -math.pi / 2 + (i * 2 * math.pi / categories.length);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          webPath.moveTo(x, y);
        } else {
          webPath.lineTo(x, y);
        }
      }
      webPath.close();
      canvas.drawPath(webPath, gridPaint);
    }

    // Draw spokes and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < categories.length; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / categories.length);
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, spokePaint);

      // Label position
      final labelR = radius + 22;
      final labelPos = Offset(
        center.dx + labelR * math.cos(angle),
        center.dy + labelR * math.sin(angle),
      );

      final catName = categories[i];
      final pct = ((scores[catName] ?? 0.0) * 100).round();
      final labelText = '$catName\n$pct%';

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isHighContrast
              ? AppColors.hcYellow
              : (isDark ? Colors.white70 : const Color(0xFF334155)),
          height: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2),
      );
    }

    // Draw Data Polygon
    final dataPath = Path();
    final points = <Offset>[];
    for (int i = 0; i < categories.length; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / categories.length);
      final score = (scores[categories[i]] ?? 0.2).clamp(0.05, 1.0);
      final r = radius * score;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      points.add(pt);
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();

    // Fill
    final dataFill = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.3)
          : AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, dataFill);

    // Border
    final dataStroke = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(dataPath, dataStroke);

    // Vertex dots
    final dotPaint = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : AppColors.primaryDark
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      canvas.drawCircle(pt, 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompetenceRadarPainter oldDelegate) => true;
}
