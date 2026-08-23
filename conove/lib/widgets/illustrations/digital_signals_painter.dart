import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DigitalSignalsPainter extends CustomPainter {
  final String digitalKey;
  final bool isDark;
  final bool isHighContrast;

  DigitalSignalsPainter({
    required this.digitalKey,
    this.isDark = false,
    this.isHighContrast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()
      ..color = isHighContrast
          ? Colors.black
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.12)),
      bgPaint,
    );

    final linePaint = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bubblePaint = Paint()
      ..color = isHighContrast
          ? const Color(0xFF333333)
          : (isDark ? AppColors.primaryDark : AppColors.primaryContainer)
      ..style = PaintingStyle.fill;

    switch (digitalKey) {
      case 'mayusculas':
      case 'mayusculas_grito':
        // Chat bubble with jagged exclamation
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.70, h * 0.45), const Radius.circular(12));
        canvas.drawRRect(rrect, bubblePaint);
        canvas.drawRRect(rrect, linePaint);

        // Sound exclamation burst around bubble
        final burstPaint = Paint()
          ..color = AppColors.coral
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(w * 0.10, h * 0.20), Offset(w * 0.04, h * 0.14), burstPaint);
        canvas.drawLine(Offset(w * 0.90, h * 0.20), Offset(w * 0.96, h * 0.14), burstPaint);
        canvas.drawLine(Offset(w * 0.10, h * 0.75), Offset(w * 0.04, h * 0.81), burstPaint);
        canvas.drawLine(Offset(w * 0.90, h * 0.75), Offset(w * 0.96, h * 0.81), burstPaint);
        break;

      case 'visto':
      case 'ghosting':
        // Chat bubble + Double blue ticks + hourglass
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.70, h * 0.40), const Radius.circular(12));
        canvas.drawRRect(rrect, bubblePaint);

        // Double checkmarks (Blue seen / Visto)
        final checkPaint = Paint()
          ..color = AppColors.info
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        // Check 1
        canvas.drawLine(Offset(w * 0.62, h * 0.52), Offset(w * 0.68, h * 0.58), checkPaint);
        canvas.drawLine(Offset(w * 0.68, h * 0.58), Offset(w * 0.78, h * 0.46), checkPaint);
        // Check 2
        canvas.drawLine(Offset(w * 0.68, h * 0.52), Offset(w * 0.74, h * 0.58), checkPaint);
        canvas.drawLine(Offset(w * 0.74, h * 0.58), Offset(w * 0.84, h * 0.46), checkPaint);

        // Clock below
        final clockCenter = Offset(w * 0.50, h * 0.78);
        canvas.drawCircle(clockCenter, w * 0.10, linePaint);
        canvas.drawLine(clockCenter, Offset(clockCenter.dx, clockCenter.dy - w * 0.07), linePaint);
        canvas.drawLine(clockCenter, Offset(clockCenter.dx + w * 0.05, clockCenter.dy), linePaint);
        break;

      case 'emoji':
      case 'emojis':
      case 'tono_emojis':
        // Chat bubble with warm emoji
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.20, w * 0.70, h * 0.60), const Radius.circular(16));
        canvas.drawRRect(rrect, bubblePaint);
        canvas.drawRRect(rrect, linePaint);

        // Friendly yellow emoji face
        final emojiFace = Paint()..color = AppColors.warning..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.16, emojiFace);
        canvas.drawCircle(Offset(w * 0.44, h * 0.46), w * 0.02, linePaint);
        canvas.drawCircle(Offset(w * 0.56, h * 0.46), w * 0.02, linePaint);
        canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.52), width: w * 0.14, height: h * 0.08), 0, 3.14, false, linePaint);
        break;

      case 'audio':
      case 'audio_length':
      case 'nota_voz':
        // Voice note container
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.76, h * 0.36), const Radius.circular(20));
        canvas.drawRRect(rrect, bubblePaint);
        canvas.drawRRect(rrect, linePaint);

        // Play triangle
        final playPath = Path();
        playPath.moveTo(w * 0.24, h * 0.42);
        playPath.lineTo(w * 0.32, h * 0.50);
        playPath.lineTo(w * 0.24, h * 0.58);
        playPath.close();
        final playPaint = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
        canvas.drawPath(playPath, playPaint);

        // Soundwave bars
        final barPaint = Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
        for (int i = 0; i < 7; i++) {
          final barH = (i % 2 == 0 ? 0.12 : 0.06) * h;
          final x = w * (0.38 + i * 0.06);
          canvas.drawLine(Offset(x, h * 0.50 - barH / 2), Offset(x, h * 0.50 + barH / 2), barPaint);
        }
        break;

      default:
        // Default chat bubble with typing dots ...
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.70, h * 0.44), const Radius.circular(16));
        canvas.drawRRect(rrect, bubblePaint);
        canvas.drawRRect(rrect, linePaint);

        // 3 Animated typing dots
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(Offset(w * (0.38 + i * 0.12), h * 0.50), w * 0.035, linePaint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant DigitalSignalsPainter oldDelegate) =>
      oldDelegate.digitalKey != digitalKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}
