import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ScenarioPainter extends CustomPainter {
  final String scenarioKey;
  final bool isDark;
  final bool isHighContrast;

  ScenarioPainter({
    required this.scenarioKey,
    this.isDark = false,
    this.isHighContrast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Card
    final bgPaint = Paint()
      ..color = isHighContrast
          ? Colors.black
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.10)),
      bgPaint,
    );

    final linePaint = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    // Table across center
    canvas.drawLine(Offset(w * 0.20, h * 0.65), Offset(w * 0.80, h * 0.65), linePaint);
    canvas.drawLine(Offset(w * 0.25, h * 0.65), Offset(w * 0.25, h * 0.88), linePaint);
    canvas.drawLine(Offset(w * 0.75, h * 0.65), Offset(w * 0.75, h * 0.88), linePaint);

    // Left Person (User / You)
    canvas.drawCircle(Offset(w * 0.28, h * 0.38), w * 0.08, accentPaint);
    canvas.drawLine(Offset(w * 0.28, h * 0.46), Offset(w * 0.28, h * 0.68), linePaint);

    // Right Person (Client / Interviewer / Friend)
    final otherPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.72, h * 0.38), w * 0.08, otherPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.46), Offset(w * 0.72, h * 0.68), linePaint);

    // Context prop on desk
    if (scenarioKey.contains('sales') || scenarioKey.contains('ventas') || scenarioKey.contains('laboral')) {
      // Laptop
      final laptop = Path();
      laptop.moveTo(w * 0.42, h * 0.64);
      laptop.lineTo(w * 0.48, h * 0.52);
      laptop.lineTo(w * 0.58, h * 0.52);
      laptop.lineTo(w * 0.58, h * 0.64);
      laptop.close();
      canvas.drawPath(laptop, linePaint);
    } else {
      // Coffee cups
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.58, w * 0.08, h * 0.06), const Radius.circular(3)), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScenarioPainter oldDelegate) =>
      oldDelegate.scenarioKey != scenarioKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}
