import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GesturaLogoPainter extends CustomPainter {
  final bool isDark;
  final bool isHighContrast;

  GesturaLogoPainter({
    this.isDark = false,
    this.isHighContrast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = isHighContrast
          ? Colors.black
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Decorative wave arcs (Communication waves)
    final wavePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.8)
          : AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      -0.8,
      1.6,
      false,
      wavePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.58),
      -0.6,
      1.2,
      false,
      wavePaint,
    );

    // Eye silhouette (Observation & Visual Reading)
    final eyePath = Path();
    final w = size.width;
    final h = size.height;

    eyePath.moveTo(w * 0.22, h * 0.5);
    eyePath.quadraticBezierTo(w * 0.5, h * 0.25, w * 0.78, h * 0.5);
    eyePath.quadraticBezierTo(w * 0.5, h * 0.75, w * 0.22, h * 0.5);
    eyePath.close();

    final eyeOutline = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? const Color(0xFF38BDF8) : AppColors.primary)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(eyePath, eyeOutline);

    // Iris circle
    final irisPaint = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.13, irisPaint);

    // Pupil
    final pupilPaint = Paint()
      ..color = isDark ? Colors.black : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.07, pupilPaint);

    // Iris catchlight
    final eyePaint = Paint()
      ..color = isHighContrast ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.46, h * 0.42), w * 0.045, eyePaint);
  }

  @override
  bool shouldRepaint(covariant GesturaLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isHighContrast != isHighContrast;
}

class GesturaLogoWidget extends StatelessWidget {
  final double size;
  final bool showBadge;

  const GesturaLogoWidget({
    super.key,
    this.size = 64,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GesturaLogoPainter(isDark: isDark),
      ),
    );
  }
}

typedef ConoVeLogoPainter = GesturaLogoPainter;
typedef ConoVeLogoWidget = GesturaLogoWidget;
