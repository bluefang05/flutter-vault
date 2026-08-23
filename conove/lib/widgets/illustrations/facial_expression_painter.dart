import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FacialExpressionPainter extends CustomPainter {
  final String expressionKey;
  final bool isDark;
  final bool isHighContrast;
  final bool highlightAnatomy;

  FacialExpressionPainter({
    required this.expressionKey,
    this.isDark = false,
    this.isHighContrast = false,
    this.highlightAnatomy = false,
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
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.15)),
      bgPaint,
    );

    // Head base (Soft human tone)
    final headPaint = Paint()
      ..color = isHighContrast
          ? const Color(0xFF262626)
          : (isDark ? const Color(0xFF334155) : const Color(0xFFFFEDD5))
      ..style = PaintingStyle.fill;

    final headBorder = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;

    final headRect = Rect.fromCenter(center: center, width: w * 0.72, height: h * 0.78);
    canvas.drawOval(headRect, headPaint);
    canvas.drawOval(headRect, headBorder);

    // Common Paints for Features
    final featurePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round;

    final fillEyePaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow
          : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = AppColors.coral.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;

    // Dispatch by expressionKey
    switch (expressionKey) {
      case 'duchenne_smile':
      case 'sonrisa_genuina':
        _paintDuchenneSmile(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'polite_smile':
      case 'sonrisa_falsa':
        _paintPoliteSmile(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'frowning_brow':
      case 'ceno_fruncido':
        _paintFrowningBrow(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'narrowed_eyes':
      case 'ojos_entrecerrados':
        _paintNarrowedEyes(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'winking_face':
      case 'guino':
        _paintWink(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'smirk_contempt':
      case 'desden':
      case 'desprecio':
        _paintSmirk(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'tight_lips':
      case 'labios_apretados':
        _paintTightLips(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'surprised_look':
      case 'sorpresa':
        _paintSurprise(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'turned_down_lips':
      case 'tristeza':
        _paintTurnedDownLips(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'closed_eyelids':
      case 'parpados_cerrados':
        _paintClosedEyelids(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'averted_gaze':
      case 'mirada_esquiva':
        _paintAvertedGaze(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'jaw_clenching':
      case 'mandibula_apretada':
        _paintJawClenching(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'lip_biting':
      case 'morder_labio':
        _paintLipBiting(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'eyebrow_flash':
      case 'flash_cejas':
        _paintEyebrowFlash(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'pupil_dilation':
      case 'pupilas_dilatadas':
        _paintPupilDilation(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      case 'nostril_flaring':
      case 'aleteo_nasal':
        _paintNostrilFlaring(canvas, size, featurePaint, fillEyePaint, highlightPaint);
        break;

      default:
        _paintNeutral(canvas, size, featurePaint, fillEyePaint);
    }
  }

  void _paintJawClenching(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Tense flat eyebrows
    canvas.drawLine(Offset(w * 0.25, h * 0.35), Offset(w * 0.44, h * 0.38), line);
    canvas.drawLine(Offset(w * 0.75, h * 0.35), Offset(w * 0.56, h * 0.38), line);

    // Focused staring eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.04, fill);

    // Locked square jaw contours
    final jawPath = Path();
    jawPath.moveTo(w * 0.32, h * 0.62);
    jawPath.lineTo(w * 0.30, h * 0.72);
    jawPath.lineTo(w * 0.70, h * 0.72);
    jawPath.lineTo(w * 0.68, h * 0.62);
    canvas.drawPath(jawPath, highlight);

    // Tight mouth
    canvas.drawLine(Offset(w * 0.35, h * 0.64), Offset(w * 0.65, h * 0.64), line);

    // Masseter muscle tension bulge ripples
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.26, h * 0.68), width: w * 0.08, height: h * 0.10), -1.5, 3.0, false, highlight);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.74, h * 0.68), width: w * 0.08, height: h * 0.10), 1.6, 3.0, false, highlight);
  }

  void _paintLipBiting(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows slightly worried
    canvas.drawLine(Offset(w * 0.26, h * 0.38), Offset(w * 0.44, h * 0.35), line);
    canvas.drawLine(Offset(w * 0.74, h * 0.38), Offset(w * 0.56, h * 0.35), line);

    // Eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.04, fill);

    // Upper teeth biting down on bottom lip
    canvas.drawLine(Offset(w * 0.36, h * 0.62), Offset(w * 0.64, h * 0.62), line);

    // Teeth rectangle
    final teeth = Rect.fromCenter(center: Offset(w * 0.50, h * 0.64), width: w * 0.14, height: h * 0.04);
    canvas.drawRect(teeth, line);

    // Lower lip pulled upward
    final lipPath = Path();
    lipPath.moveTo(w * 0.38, h * 0.66);
    lipPath.quadraticBezierTo(w * 0.50, h * 0.72, w * 0.62, h * 0.66);
    canvas.drawPath(lipPath, highlight);
  }

  void _paintEyebrowFlash(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // High energetic raised eyebrows
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.35, h * 0.28), width: w * 0.22, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, highlight);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.28), width: w * 0.22, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, highlight);

    // Upward motion arrows/rays above brows
    canvas.drawLine(Offset(w * 0.35, h * 0.22), Offset(w * 0.35, h * 0.16), highlight);
    canvas.drawLine(Offset(w * 0.65, h * 0.22), Offset(w * 0.65, h * 0.16), highlight);

    // Bright friendly open eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.05, line);
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.03, fill);

    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.05, line);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.03, fill);

    // Warm welcoming smile
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.34, h * 0.64);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.74, w * 0.66, h * 0.64);
    canvas.drawPath(mouthPath, line);
  }

  void _paintPupilDilation(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.35, h * 0.34), width: w * 0.20, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.34), width: w * 0.20, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);

    // Eye contours
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.45), width: w * 0.22, height: h * 0.14), line);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.65, h * 0.45), width: w * 0.22, height: h * 0.14), line);

    // Giant dilated pupils (Arousal / High Interest)
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.055, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), w * 0.055, fill);

    // Pupil light shine reflection
    final shinePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.33, h * 0.43), w * 0.015, shinePaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.43), w * 0.015, shinePaint);

    // Light aura
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.07, highlight);
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), w * 0.07, highlight);

    // Gentle smile
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.36, h * 0.66);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.74, w * 0.64, h * 0.66);
    canvas.drawPath(mouthPath, line);
  }

  void _paintNostrilFlaring(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Angry/intense eyebrows
    canvas.drawLine(Offset(w * 0.24, h * 0.34), Offset(w * 0.44, h * 0.40), line);
    canvas.drawLine(Offset(w * 0.76, h * 0.34), Offset(w * 0.56, h * 0.40), line);

    // Intense eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), w * 0.04, fill);

    // Flared nostrils (wings of nose expanded)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.44, h * 0.54), width: w * 0.10, height: h * 0.08), 1.0, 3.2, false, highlight);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.56, h * 0.54), width: w * 0.10, height: h * 0.08), -1.0, -3.2, false, highlight);

    // Airflow puffs from nostrils
    canvas.drawLine(Offset(w * 0.42, h * 0.56), Offset(w * 0.36, h * 0.60), highlight);
    canvas.drawLine(Offset(w * 0.58, h * 0.56), Offset(w * 0.64, h * 0.60), highlight);

    // Firm straight mouth
    canvas.drawLine(Offset(w * 0.36, h * 0.66), Offset(w * 0.64, h * 0.66), line);
  }

  void _paintDuchenneSmile(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows (relaxed, slightly curved)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.36, h * 0.35), width: w * 0.22, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.64, h * 0.35), width: w * 0.22, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);

    // Eyes crinkled in smile crescents (Orbicularis Oculi)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.36, h * 0.44), width: w * 0.18, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.64, h * 0.44), width: w * 0.18, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, line);

    // Crow's feet wrinkles (Anatomical marker of genuine smile)
    canvas.drawLine(Offset(w * 0.24, h * 0.42), Offset(w * 0.20, h * 0.40), highlight);
    canvas.drawLine(Offset(w * 0.24, h * 0.45), Offset(w * 0.19, h * 0.46), highlight);
    canvas.drawLine(Offset(w * 0.76, h * 0.42), Offset(w * 0.80, h * 0.40), highlight);
    canvas.drawLine(Offset(w * 0.76, h * 0.45), Offset(w * 0.81, h * 0.46), highlight);

    // Wide, genuine upward mouth
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.32, h * 0.62);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.78, w * 0.68, h * 0.62);
    canvas.drawPath(mouthPath, line);

    // Cheek elevation lines
    final cheekPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.30, h * 0.55), w * 0.06, cheekPaint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.55), w * 0.06, cheekPaint);
  }

  void _paintPoliteSmile(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows (flat / neutral)
    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.44, h * 0.36), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    // Eyes static & open (no orbicularis oculi contraction)
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.045, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.045, fill);

    // Mouth stretched horizontally / polite smile
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.34, h * 0.64);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.69, w * 0.66, h * 0.64);
    canvas.drawPath(mouthPath, line);

    // Marker: Highlight showing smooth eye area (lack of genuine wrinkles)
    if (highlightAnatomy) {
      canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.09, highlight);
      canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.09, highlight);
    }
  }

  void _paintFrowningBrow(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows slanted downwards inward (Corrugator muscle)
    canvas.drawLine(Offset(w * 0.25, h * 0.33), Offset(w * 0.44, h * 0.40), line);
    canvas.drawLine(Offset(w * 0.75, h * 0.33), Offset(w * 0.56, h * 0.40), line);

    // Vertical forehead frown wrinkles
    canvas.drawLine(Offset(w * 0.48, h * 0.32), Offset(w * 0.48, h * 0.38), highlight);
    canvas.drawLine(Offset(w * 0.52, h * 0.32), Offset(w * 0.52, h * 0.38), highlight);

    // Eyes focused
    canvas.drawCircle(Offset(w * 0.36, h * 0.46), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.64, h * 0.46), w * 0.04, fill);

    // Neutral or slightly tense mouth
    canvas.drawLine(Offset(w * 0.38, h * 0.66), Offset(w * 0.62, h * 0.66), line);
  }

  void _paintNarrowedEyes(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Slightly furrowed brows
    canvas.drawLine(Offset(w * 0.26, h * 0.35), Offset(w * 0.44, h * 0.38), line);
    canvas.drawLine(Offset(w * 0.74, h * 0.35), Offset(w * 0.56, h * 0.38), line);

    // Slit narrowed eyes
    canvas.drawLine(Offset(w * 0.27, h * 0.45), Offset(w * 0.43, h * 0.45), line);
    canvas.drawLine(Offset(w * 0.57, h * 0.45), Offset(w * 0.73, h * 0.45), line);

    // Subtle pupils visible
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.025, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), w * 0.025, fill);

    // Straight firm mouth
    canvas.drawLine(Offset(w * 0.36, h * 0.65), Offset(w * 0.64, h * 0.65), line);
  }

  void _paintWink(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Left eyebrow raised, right relaxed
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.35, h * 0.33), width: w * 0.22, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    // Left eye wide open
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.045, fill);

    // Right eye winking crescent
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.44), width: w * 0.18, height: h * 0.10), -math.pi * 0.9, math.pi * 0.8, false, line);
    canvas.drawLine(Offset(w * 0.75, h * 0.43), Offset(w * 0.80, h * 0.41), highlight);

    // Playful subtle smile
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.36, h * 0.64);
    mouthPath.quadraticBezierTo(w * 0.52, h * 0.72, w * 0.68, h * 0.62);
    canvas.drawPath(mouthPath, line);
  }

  void _paintSmirk(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Uneven eyebrows (one slightly arched)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.36, h * 0.34), width: w * 0.20, height: h * 0.08), -math.pi * 0.85, math.pi * 0.7, false, line);
    canvas.drawLine(Offset(w * 0.56, h * 0.37), Offset(w * 0.74, h * 0.37), line);

    // Eyes
    canvas.drawCircle(Offset(w * 0.36, h * 0.44), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.64, h * 0.44), w * 0.04, fill);

    // Asymmetric smirk mouth: one corner lifted significantly
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.34, h * 0.65);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.68, h * 0.57);
    canvas.drawPath(mouthPath, line);

    // Highlight on the raised corner
    canvas.drawCircle(Offset(w * 0.68, h * 0.57), w * 0.04, highlight);
  }

  void _paintTightLips(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows
    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.44, h * 0.36), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    // Direct eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.04, fill);

    // Tight thin compressed lips (tension)
    final tightLine = Paint()
      ..color = isHighContrast ? AppColors.hcYellow : (isDark ? Colors.white : const Color(0xFF0F172A))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.36, h * 0.64), Offset(w * 0.64, h * 0.64), tightLine);
    canvas.drawLine(Offset(w * 0.36, h * 0.62), Offset(w * 0.64, h * 0.62), highlight);
  }

  void _paintSurprise(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // High arched eyebrows
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.35, h * 0.30), width: w * 0.22, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.30), width: w * 0.22, height: h * 0.12), -math.pi * 0.9, math.pi * 0.8, false, line);

    // Wide open circular eyes
    canvas.drawCircle(Offset(w * 0.35, h * 0.43), w * 0.065, line);
    canvas.drawCircle(Offset(w * 0.35, h * 0.43), w * 0.035, fill);

    canvas.drawCircle(Offset(w * 0.65, h * 0.43), w * 0.065, line);
    canvas.drawCircle(Offset(w * 0.65, h * 0.43), w * 0.035, fill);

    // Open oval mouth
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.66), width: w * 0.16, height: h * 0.12), line);
  }

  void _paintTurnedDownLips(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Eyebrows tilted up in center (sadness/deception)
    canvas.drawLine(Offset(w * 0.26, h * 0.38), Offset(w * 0.44, h * 0.33), line);
    canvas.drawLine(Offset(w * 0.74, h * 0.38), Offset(w * 0.56, h * 0.33), line);

    // Eyes looking down
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.45), w * 0.04, fill);

    // Downturned mouth
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.34, h * 0.68);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.60, w * 0.66, h * 0.68);
    canvas.drawPath(mouthPath, line);
  }

  void _paintClosedEyelids(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    // Neutral eyebrows
    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.44, h * 0.36), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    // Closed downward curved eyelids (disconnection/fatigue)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.35, h * 0.44), width: w * 0.18, height: h * 0.08), 0, math.pi, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.44), width: w * 0.18, height: h * 0.08), 0, math.pi, false, line);

    // Neutral mouth
    canvas.drawLine(Offset(w * 0.38, h * 0.65), Offset(w * 0.62, h * 0.65), line);
  }

  void _paintAvertedGaze(Canvas canvas, Size size, Paint line, Paint fill, Paint highlight) {
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.44, h * 0.36), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    // Eye contours
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.44), width: w * 0.18, height: h * 0.10), line);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.65, h * 0.44), width: w * 0.18, height: h * 0.10), line);

    // Pupils shifted all the way to bottom-left (avoiding eye contact)
    canvas.drawCircle(Offset(w * 0.30, h * 0.46), w * 0.035, fill);
    canvas.drawCircle(Offset(w * 0.60, h * 0.46), w * 0.035, fill);

    canvas.drawLine(Offset(w * 0.38, h * 0.65), Offset(w * 0.62, h * 0.65), line);
  }

  void _paintNeutral(Canvas canvas, Size size, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.44, h * 0.36), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.36), Offset(w * 0.74, h * 0.36), line);

    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.04, fill);

    canvas.drawLine(Offset(w * 0.38, h * 0.65), Offset(w * 0.62, h * 0.65), line);
  }

  @override
  bool shouldRepaint(covariant FacialExpressionPainter oldDelegate) =>
      oldDelegate.expressionKey != expressionKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast ||
      oldDelegate.highlightAnatomy != highlightAnatomy;
}
