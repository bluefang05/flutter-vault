import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProxemicsPainter extends CustomPainter {
  final String activeZone; // 'intima', 'personal', 'social', 'publica', 'all'
  final bool isDark;
  final bool isHighContrast;

  ProxemicsPainter({
    this.activeZone = 'all',
    this.isDark = false,
    this.isHighContrast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Background Card
    final bgPaint = Paint()
      ..color = isHighContrast
          ? Colors.black
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.12)),
      bgPaint,
    );

    // 4 Concentric Radii
    final rPublica = w * 0.44;
    final rSocial = w * 0.33;
    final rPersonal = w * 0.22;
    final rIntima = w * 0.12;

    // 1. Zona Pública (+3.6m)
    _drawRing(
      canvas,
      center,
      rPublica,
      'Pública',
      AppColors.info,
      activeZone == 'all' || activeZone == 'publica',
    );

    // 2. Zona Social (1.2m - 3.6m)
    _drawRing(
      canvas,
      center,
      rSocial,
      'Social',
      AppColors.emerald,
      activeZone == 'all' || activeZone == 'social',
    );

    // 3. Zona Personal (45cm - 1.2m)
    _drawRing(
      canvas,
      center,
      rPersonal,
      'Personal',
      AppColors.accent,
      activeZone == 'all' || activeZone == 'personal',
    );

    // 4. Zona Íntima (0 - 45cm)
    _drawRing(
      canvas,
      center,
      rIntima,
      'Íntima',
      AppColors.coral,
      activeZone == 'all' || activeZone == 'intima',
    );

    // Center Avatar (You / Ego)
    final avatarPaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? Colors.white : AppColors.textPrimaryLight)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, w * 0.05, avatarPaint);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, String label, Color color, bool isActive) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: isActive ? (isDark ? 0.25 : 0.18) : 0.04)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: isActive ? 0.9 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 2.5 : 1.0;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ProxemicsPainter oldDelegate) =>
      oldDelegate.activeZone != activeZone ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}
