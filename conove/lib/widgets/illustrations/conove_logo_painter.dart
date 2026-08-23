import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConoVeLogoPainter extends CustomPainter {
  final bool isDark;
  final bool isHighContrast;

  ConoVeLogoPainter({
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
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      -0.8,
      1.6,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      2.34,
      1.6,
      false,
      wavePaint,
    );

    // Human Head Silhouette in Calm Teal
    final facePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? AppColors.primaryLight : AppColors.primary)
      ..style = PaintingStyle.fill;

    // Stylized face profile path
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Left piece (Face & Mind)
    path.moveTo(w * 0.35, h * 0.28);
    path.cubicTo(w * 0.45, h * 0.20, w * 0.65, h * 0.22, w * 0.68, h * 0.35);
    path.cubicTo(w * 0.70, h * 0.45, w * 0.65, h * 0.52, w * 0.62, h * 0.58);
    // Puzzle notch on right
    path.cubicTo(w * 0.67, h * 0.60, w * 0.72, h * 0.65, w * 0.68, h * 0.72);
    path.cubicTo(w * 0.62, h * 0.78, w * 0.55, h * 0.75, w * 0.50, h * 0.78);
    path.cubicTo(w * 0.40, h * 0.82, w * 0.30, h * 0.78, w * 0.28, h * 0.65);
    path.cubicTo(w * 0.25, h * 0.50, w * 0.25, h * 0.38, w * 0.35, h * 0.28);
    path.close();
    canvas.drawPath(path, facePaint);

    // Complementary amber puzzle piece (Understanding NT)
    final puzzlePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcCyan
          : (isDark ? AppColors.accentLight : AppColors.accent)
      ..style = PaintingStyle.fill;

    final puzzlePath = Path();
    puzzlePath.moveTo(w * 0.60, h * 0.42);
    puzzlePath.cubicTo(w * 0.72, h * 0.40, w * 0.78, h * 0.48, w * 0.76, h * 0.58);
    puzzlePath.cubicTo(w * 0.74, h * 0.68, w * 0.66, h * 0.75, w * 0.56, h * 0.70);
    puzzlePath.cubicTo(w * 0.58, h * 0.62, w * 0.54, h * 0.52, w * 0.60, h * 0.42);
    puzzlePath.close();
    canvas.drawPath(puzzlePath, puzzlePaint);

    // Eye dot of perception
    final eyePaint = Paint()
      ..color = isHighContrast ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.46, h * 0.42), w * 0.045, eyePaint);
  }

  @override
  bool shouldRepaint(covariant ConoVeLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isHighContrast != isHighContrast;
}

class ConoVeLogoWidget extends StatelessWidget {
  final double size;
  final bool showBadge;

  const ConoVeLogoWidget({
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
        painter: ConoVeLogoPainter(isDark: isDark),
      ),
    );
  }
}
