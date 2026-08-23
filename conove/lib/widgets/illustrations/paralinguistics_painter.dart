import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ParalinguisticsPainter extends CustomPainter {
  final String soundKey;
  final bool isDark;
  final bool isHighContrast;

  ParalinguisticsPainter({
    required this.soundKey,
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
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.15)),
      bgPaint,
    );

    final linePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.2)
          : AppColors.purple.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = AppColors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final warnPaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    switch (soundKey) {
      case 'voice_volume_high':
      case 'volumen_alto':
      case 'tono_alto':
        _paintVolumeHigh(canvas, size, linePaint, fillPaint, warnPaint);
        break;

      case 'voice_volume_low':
      case 'volumen_bajo':
      case 'tono_bajo':
      case 'susurro':
        _paintVolumeLow(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'voice_speed_fast':
      case 'velocidad_rapida':
      case 'ritmo_rapido':
        _paintSpeedFast(canvas, size, linePaint, fillPaint, warnPaint);
        break;

      case 'voice_monotone':
      case 'tono_monotono':
      case 'voz_plana':
        _paintMonotone(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'silence_tense':
      case 'silencio_tenso':
      case 'silencio_incomodo':
        _paintSilenceTense(canvas, size, linePaint, fillPaint, warnPaint);
        break;

      case 'silence_reflective':
      case 'silencio_reflexivo':
      case 'pausa_reflexiva':
        _paintSilenceReflective(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'sarcastic_inflection':
      case 'tono_sarcastico':
      case 'inflexion_ironica':
        _paintSarcasticInflection(canvas, size, linePaint, fillPaint, warnPaint);
        break;

      case 'assertive_voice':
      case 'tono_asertivo':
        _paintAssertiveVoice(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      default:
        _paintAssertiveVoice(canvas, size, linePaint, fillPaint, accentPaint);
    }
  }

  void _paintVolumeHigh(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Megaphone / Speaker body
    final speaker = Path();
    speaker.moveTo(w * 0.20, h * 0.42);
    speaker.lineTo(w * 0.32, h * 0.42);
    speaker.lineTo(w * 0.50, h * 0.28);
    speaker.lineTo(w * 0.50, h * 0.72);
    speaker.lineTo(w * 0.32, h * 0.58);
    speaker.lineTo(w * 0.20, h * 0.58);
    speaker.close();
    canvas.drawPath(speaker, fill);
    canvas.drawPath(speaker, line);

    // Large high-amplitude shockwaves
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.28, height: h * 0.38), -0.7, 1.4, false, accent);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.48, height: h * 0.62), -0.8, 1.6, false, accent);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.68, height: h * 0.84), -0.9, 1.8, false, accent);
  }

  void _paintVolumeLow(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Speaker body
    final speaker = Path();
    speaker.moveTo(w * 0.25, h * 0.44);
    speaker.lineTo(w * 0.36, h * 0.44);
    speaker.lineTo(w * 0.50, h * 0.34);
    speaker.lineTo(w * 0.50, h * 0.66);
    speaker.lineTo(w * 0.36, h * 0.56);
    speaker.lineTo(w * 0.25, h * 0.56);
    speaker.close();
    canvas.drawPath(speaker, fill);
    canvas.drawPath(speaker, line);

    // Tiny faint ripple
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.18, height: h * 0.24), -0.5, 1.0, false, accent);

    // Whispering dotted cloud
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(w * (0.68 + i * 0.07), h * 0.50), w * 0.015, accent);
    }
  }

  void _paintSpeedFast(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Compressed fast wave frequencies
    final wavePath = Path();
    wavePath.moveTo(w * 0.15, h * 0.50);
    for (double x = 0.15; x <= 0.85; x += 0.05) {
      final y = h * 0.50 + math.sin((x - 0.15) * 45) * (h * 0.22);
      wavePath.lineTo(w * x, y);
    }
    canvas.drawPath(wavePath, accent);

    // Fast forward motion arrows
    canvas.drawLine(Offset(w * 0.35, h * 0.22), Offset(w * 0.65, h * 0.22), line);
    canvas.drawLine(Offset(w * 0.58, h * 0.17), Offset(w * 0.65, h * 0.22), line);
    canvas.drawLine(Offset(w * 0.58, h * 0.27), Offset(w * 0.65, h * 0.22), line);
  }

  void _paintMonotone(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Completely flat robotic frequency line
    canvas.drawLine(Offset(w * 0.15, h * 0.50), Offset(w * 0.85, h * 0.50), accent);

    // Zero variation brackets
    canvas.drawLine(Offset(w * 0.15, h * 0.35), Offset(w * 0.15, h * 0.65), line);
    canvas.drawLine(Offset(w * 0.85, h * 0.35), Offset(w * 0.85, h * 0.65), line);

    // Flat mouth face icon in corner
    canvas.drawCircle(Offset(w * 0.50, h * 0.25), w * 0.08, line);
    canvas.drawLine(Offset(w * 0.46, h * 0.27), Offset(w * 0.54, h * 0.27), line);
  }

  void _paintSilenceTense(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Crossed out microphone / silence sign
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.22, height: h * 0.32), fill);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.22, height: h * 0.32), line);

    // Stand
    canvas.drawLine(Offset(w * 0.50, h * 0.61), Offset(w * 0.50, h * 0.78), line);
    canvas.drawLine(Offset(w * 0.35, h * 0.78), Offset(w * 0.65, h * 0.78), line);

    // Tense red diagonal strike
    canvas.drawLine(Offset(w * 0.25, h * 0.25), Offset(w * 0.75, h * 0.75), accent);

    // Tension lightning sparks
    canvas.drawLine(Offset(w * 0.72, h * 0.28), Offset(w * 0.80, h * 0.34), accent);
    canvas.drawLine(Offset(w * 0.80, h * 0.34), Offset(w * 0.75, h * 0.40), accent);
  }

  void _paintSilenceReflective(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Thought bubble contour
    final cloud = Path();
    cloud.addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.40), width: w * 0.48, height: h * 0.32));
    canvas.drawPath(cloud, fill);
    canvas.drawPath(cloud, line);

    // 3 calm reflective dots (Ellipsis)
    canvas.drawCircle(Offset(w * 0.38, h * 0.40), w * 0.035, accent);
    canvas.drawCircle(Offset(w * 0.50, h * 0.40), w * 0.035, accent);
    canvas.drawCircle(Offset(w * 0.62, h * 0.40), w * 0.035, accent);

    // Small lower thought trail circles
    canvas.drawCircle(Offset(w * 0.35, h * 0.65), w * 0.025, line);
    canvas.drawCircle(Offset(w * 0.28, h * 0.74), w * 0.015, line);
  }

  void _paintSarcasticInflection(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Tone curve: climbs unnaturally high and suddenly plummets with irony
    final toneCurve = Path();
    toneCurve.moveTo(w * 0.15, h * 0.65);
    toneCurve.quadraticBezierTo(w * 0.45, h * 0.18, w * 0.60, h * 0.35);
    toneCurve.quadraticBezierTo(w * 0.70, h * 0.55, w * 0.85, h * 0.75);
    canvas.drawPath(toneCurve, accent);

    // Arrowhead dropping down
    canvas.drawLine(Offset(w * 0.85, h * 0.75), Offset(w * 0.76, h * 0.73), accent);
    canvas.drawLine(Offset(w * 0.85, h * 0.75), Offset(w * 0.83, h * 0.66), accent);

    // Mask / quotation marks icon
    canvas.drawCircle(Offset(w * 0.30, h * 0.30), w * 0.06, line);
    canvas.drawCircle(Offset(w * 0.70, h * 0.30), w * 0.06, line);
  }

  void _paintAssertiveVoice(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Stable harmonic sine wave
    final harmonic = Path();
    harmonic.moveTo(w * 0.15, h * 0.50);
    harmonic.quadraticBezierTo(w * 0.32, h * 0.26, w * 0.50, h * 0.50);
    harmonic.quadraticBezierTo(w * 0.68, h * 0.74, w * 0.85, h * 0.50);
    canvas.drawPath(harmonic, accent);

    // Steady equilibrium center line
    canvas.drawLine(Offset(w * 0.15, h * 0.50), Offset(w * 0.85, h * 0.50), line);

    // Confidence badge check in top corner
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.08, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.08, line);
    canvas.drawLine(Offset(w * 0.46, h * 0.22), Offset(w * 0.49, h * 0.25), accent);
    canvas.drawLine(Offset(w * 0.49, h * 0.25), Offset(w * 0.55, h * 0.19), accent);
  }

  @override
  bool shouldRepaint(covariant ParalinguisticsPainter oldDelegate) =>
      oldDelegate.soundKey != soundKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}
