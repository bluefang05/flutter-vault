import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EnvironmentPainter extends CustomPainter {
  final String envKey;
  final bool isDark;
  final bool isHighContrast;

  EnvironmentPainter({
    required this.envKey,
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
          : AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;

    final warnPaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    switch (envKey) {
      case 'dress_formal':
      case 'vestimenta_formal':
        _paintDressFormal(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'dress_casual':
      case 'vestimenta_casual':
        _paintDressCasual(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'desk_barrier':
      case 'mesa_barrera':
      case 'escritorio_bloqueo':
        _paintDeskBarrier(canvas, size, linePaint, fillPaint, warnPaint);
        break;

      case 'round_table':
      case 'mesa_redonda':
      case 'disposicion_circular':
        _paintRoundTable(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'seating_angle':
      case 'angulo_noventa':
      case 'sentarse_en_l':
        _paintSeatingAngle(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      case 'lighting_atmosphere':
      case 'iluminacion':
        _paintLighting(canvas, size, linePaint, fillPaint, accentPaint);
        break;

      default:
        _paintDressFormal(canvas, size, linePaint, fillPaint, accentPaint);
    }
  }

  void _paintDressFormal(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Jacket outline
    final jacket = Path();
    jacket.moveTo(w * 0.25, h * 0.28);
    jacket.lineTo(w * 0.75, h * 0.28);
    jacket.lineTo(w * 0.82, h * 0.85);
    jacket.lineTo(w * 0.18, h * 0.85);
    jacket.close();
    canvas.drawPath(jacket, fill);
    canvas.drawPath(jacket, line);

    // V-neck lapel
    final lapel = Path();
    lapel.moveTo(w * 0.35, h * 0.28);
    lapel.lineTo(w * 0.50, h * 0.62);
    lapel.lineTo(w * 0.65, h * 0.28);
    canvas.drawPath(lapel, line);

    // Tie
    final tie = Path();
    tie.moveTo(w * 0.46, h * 0.32);
    tie.lineTo(w * 0.54, h * 0.32);
    tie.lineTo(w * 0.56, h * 0.74);
    tie.lineTo(w * 0.50, h * 0.82);
    tie.lineTo(w * 0.44, h * 0.74);
    tie.close();
    canvas.drawPath(tie, accent);

    // Tie knot
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.50, h * 0.34), width: w * 0.08, height: h * 0.06), line);
  }

  void _paintDressCasual(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // T-shirt / Polo shirt body
    final shirt = Path();
    shirt.moveTo(w * 0.30, h * 0.30);
    shirt.lineTo(w * 0.70, h * 0.30);
    shirt.lineTo(w * 0.78, h * 0.48);
    shirt.lineTo(w * 0.68, h * 0.50);
    shirt.lineTo(w * 0.68, h * 0.85);
    shirt.lineTo(w * 0.32, h * 0.85);
    shirt.lineTo(w * 0.32, h * 0.50);
    shirt.lineTo(w * 0.22, h * 0.48);
    shirt.close();
    canvas.drawPath(shirt, fill);
    canvas.drawPath(shirt, line);

    // Open relaxed crew collar
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.30), width: w * 0.24, height: h * 0.16), 0, 3.14, false, accent);
  }

  void _paintDeskBarrier(Canvas canvas, Size size, Paint line, Paint fill, Paint warn) {
    final w = size.width;
    final h = size.height;

    // Boss seated behind desk
    canvas.drawCircle(Offset(w * 0.50, h * 0.25), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.25), w * 0.10, line);
    canvas.drawLine(Offset(w * 0.35, h * 0.38), Offset(w * 0.65, h * 0.38), line);

    // Massive thick desk barrier
    final desk = Rect.fromLTWH(w * 0.12, h * 0.48, w * 0.76, h * 0.20);
    canvas.drawRect(desk, fill);
    canvas.drawRect(desk, warn);

    // Barrier cross indicator
    canvas.drawLine(Offset(w * 0.15, h * 0.58), Offset(w * 0.85, h * 0.58), warn);

    // Visitor chair in front of desk
    canvas.drawCircle(Offset(w * 0.50, h * 0.84), w * 0.08, line);
  }

  void _paintRoundTable(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Round table top-down view
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.25, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.25, accent);

    // 4 egalitarian seats around the table
    canvas.drawCircle(Offset(w * 0.50, h * 0.15), w * 0.07, line); // Top
    canvas.drawCircle(Offset(w * 0.50, h * 0.85), w * 0.07, line); // Bottom
    canvas.drawCircle(Offset(w * 0.15, h * 0.50), w * 0.07, line); // Left
    canvas.drawCircle(Offset(w * 0.85, h * 0.50), w * 0.07, line); // Right

    // Equal connection arrows
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.08, accent);
  }

  void _paintSeatingAngle(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Table corner (L-Shape top view)
    final table = Path();
    table.moveTo(w * 0.35, h * 0.20);
    table.lineTo(w * 0.85, h * 0.20);
    table.lineTo(w * 0.85, h * 0.70);
    table.lineTo(w * 0.65, h * 0.70);
    table.lineTo(w * 0.65, h * 0.40);
    table.lineTo(w * 0.35, h * 0.40);
    table.close();
    canvas.drawPath(table, fill);
    canvas.drawPath(table, line);

    // Seat A (Top)
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), w * 0.07, line);

    // Seat B (Right side, 90 degree angle)
    canvas.drawCircle(Offset(w * 0.92, h * 0.50), w * 0.07, line);

    // 90 degree cooperative connection arc
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.40), width: w * 0.30, height: h * 0.30), -1.57, 1.57, false, accent);

    // Collaboration heart / check badge
    canvas.drawCircle(Offset(w * 0.65, h * 0.40), w * 0.04, accent);
  }

  void _paintLighting(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Lamp / Light bulb
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.16, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.16, line);

    // Filament
    final filament = Path();
    filament.moveTo(w * 0.45, h * 0.44);
    filament.lineTo(w * 0.47, h * 0.34);
    filament.lineTo(w * 0.53, h * 0.34);
    filament.lineTo(w * 0.55, h * 0.44);
    canvas.drawPath(filament, accent);

    // Bulb base & socket
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.50, h * 0.58), width: w * 0.12, height: h * 0.08), line);

    // Radiant warmth light rays
    canvas.drawLine(Offset(w * 0.50, h * 0.15), Offset(w * 0.50, h * 0.08), accent);
    canvas.drawLine(Offset(w * 0.28, h * 0.22), Offset(w * 0.20, h * 0.15), accent);
    canvas.drawLine(Offset(w * 0.72, h * 0.22), Offset(w * 0.80, h * 0.15), accent);
    canvas.drawLine(Offset(w * 0.22, h * 0.38), Offset(w * 0.12, h * 0.38), accent);
    canvas.drawLine(Offset(w * 0.78, h * 0.38), Offset(w * 0.88, h * 0.38), accent);
  }

  @override
  bool shouldRepaint(covariant EnvironmentPainter oldDelegate) =>
      oldDelegate.envKey != envKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}
