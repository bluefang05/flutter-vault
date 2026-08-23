import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BodyPosturePainter extends CustomPainter {
  final String postureKey;
  final bool isDark;
  final bool isHighContrast;

  BodyPosturePainter({
    required this.postureKey,
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

    final bodyFillPaint = Paint()
      ..color = isHighContrast
          ? AppColors.hcYellow.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;

    switch (postureKey) {
      case 'open_posture':
      case 'postura_abierta':
        _paintOpenPosture(canvas, size, linePaint, bodyFillPaint);
        break;

      case 'closed_posture':
      case 'brazos_cruzados':
      case 'postura_cerrada':
        _paintClosedPosture(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'leaning_forward':
      case 'inclinacion_adelante':
        _paintLeaningForward(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'leaning_back':
      case 'inclinacion_atras':
        _paintLeaningBack(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'shrug':
      case 'encogerse_hombros':
        _paintShrug(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'hand_wringing':
      case 'frotar_manos':
        _paintHandWringing(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'finger_tapping':
      case 'tamborileo_dedos':
        _paintFingerTapping(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'hands_on_hips':
      case 'manos_caderas':
      case 'manos_jarra':
        _paintHandsOnHips(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'hands_behind_head':
      case 'manos_nuca':
        _paintHandsBehindHead(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'steepling_hands':
      case 'manos_ojiva':
      case 'ojiva':
        _paintSteeplingHands(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'head_tilt':
      case 'cabeza_inclinada':
      case 'cabeza_ladeada':
        _paintHeadTilt(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'touching_neck':
      case 'tocarse_cuello':
      case 'frotar_cuello':
        _paintTouchingNeck(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'hands_behind_back':
      case 'brazos_espalda':
      case 'manos_espalda':
        _paintHandsBehindBack(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'hands_in_pockets':
      case 'manos_bolsillos':
        _paintHandsInPockets(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'legs_crossed':
      case 'piernas_cruzadas':
      case 'cruce_piernas':
        _paintLegsCrossed(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      case 'handshake_firm':
      case 'apreton_manos':
        _paintHandshake(canvas, size, linePaint, bodyFillPaint, accentPaint);
        break;

      default:
        _paintOpenPosture(canvas, size, linePaint, bodyFillPaint);
    }
  }

  void _paintOpenPosture(Canvas canvas, Size size, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.11, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.11, line);

    // Torso (Open and broad)
    final torso = Path();
    torso.moveTo(w * 0.35, h * 0.38);
    torso.lineTo(w * 0.65, h * 0.38);
    torso.lineTo(w * 0.60, h * 0.72);
    torso.lineTo(w * 0.40, h * 0.72);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Arms open at sides, hands relaxed downwards
    canvas.drawLine(Offset(w * 0.35, h * 0.38), Offset(w * 0.22, h * 0.56), line);
    canvas.drawLine(Offset(w * 0.22, h * 0.56), Offset(w * 0.18, h * 0.72), line);

    canvas.drawLine(Offset(w * 0.65, h * 0.38), Offset(w * 0.78, h * 0.56), line);
    canvas.drawLine(Offset(w * 0.78, h * 0.56), Offset(w * 0.82, h * 0.72), line);

    // Legs
    canvas.drawLine(Offset(w * 0.44, h * 0.72), Offset(w * 0.40, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.72), Offset(w * 0.60, h * 0.90), line);
  }

  void _paintClosedPosture(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.11, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.11, line);

    // Torso
    final torso = Path();
    torso.moveTo(w * 0.35, h * 0.38);
    torso.lineTo(w * 0.65, h * 0.38);
    torso.lineTo(w * 0.60, h * 0.72);
    torso.lineTo(w * 0.40, h * 0.72);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Arms crossed across chest (Barrier)
    canvas.drawLine(Offset(w * 0.34, h * 0.40), Offset(w * 0.66, h * 0.52), accent);
    canvas.drawLine(Offset(w * 0.66, h * 0.40), Offset(w * 0.34, h * 0.52), accent);

    // Forearms tucked
    canvas.drawLine(Offset(w * 0.34, h * 0.52), Offset(w * 0.30, h * 0.48), line);
    canvas.drawLine(Offset(w * 0.66, h * 0.52), Offset(w * 0.70, h * 0.48), line);

    // Legs
    canvas.drawLine(Offset(w * 0.45, h * 0.72), Offset(w * 0.45, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.55, h * 0.72), Offset(w * 0.55, h * 0.90), line);
  }

  void _paintLeaningForward(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head tilted forward (toward left viewer)
    canvas.drawCircle(Offset(w * 0.40, h * 0.22), w * 0.11, fill);
    canvas.drawCircle(Offset(w * 0.40, h * 0.22), w * 0.11, line);

    // Spine tilted forward
    final spine = Path();
    spine.moveTo(w * 0.40, h * 0.34);
    spine.lineTo(w * 0.60, h * 0.68);
    canvas.drawPath(spine, line);

    // Arms resting on table / forward
    canvas.drawLine(Offset(w * 0.44, h * 0.42), Offset(w * 0.26, h * 0.56), line);
    canvas.drawLine(Offset(w * 0.26, h * 0.56), Offset(w * 0.20, h * 0.62), line);

    // Chair/Desk line
    canvas.drawLine(Offset(w * 0.10, h * 0.64), Offset(w * 0.45, h * 0.64), accent);
    canvas.drawLine(Offset(w * 0.60, h * 0.68), Offset(w * 0.65, h * 0.90), line);
  }

  void _paintLeaningBack(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head tilted back (toward right)
    canvas.drawCircle(Offset(w * 0.62, h * 0.22), w * 0.11, fill);
    canvas.drawCircle(Offset(w * 0.62, h * 0.22), w * 0.11, line);

    // Spine tilted back
    final spine = Path();
    spine.moveTo(w * 0.60, h * 0.34);
    spine.lineTo(w * 0.40, h * 0.68);
    canvas.drawPath(spine, line);

    // Relaxed arms
    canvas.drawLine(Offset(w * 0.58, h * 0.42), Offset(w * 0.76, h * 0.54), line);
    canvas.drawLine(Offset(w * 0.76, h * 0.54), Offset(w * 0.78, h * 0.66), line);

    // Chair back angle
    canvas.drawLine(Offset(w * 0.70, h * 0.26), Offset(w * 0.44, h * 0.74), accent);
    canvas.drawLine(Offset(w * 0.40, h * 0.68), Offset(w * 0.35, h * 0.90), line);
  }

  void _paintShrug(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head slightly tilted
    canvas.drawCircle(Offset(w * 0.50, h * 0.26), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.26), w * 0.10, line);

    // Shoulders raised high near ears
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.44, h * 0.36), accent);
    canvas.drawLine(Offset(w * 0.70, h * 0.32), Offset(w * 0.56, h * 0.36), accent);

    // Torso
    canvas.drawLine(Offset(w * 0.50, h * 0.36), Offset(w * 0.50, h * 0.72), line);

    // Arms bent with palms facing up
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.22, h * 0.52), line);
    canvas.drawLine(Offset(w * 0.22, h * 0.52), Offset(w * 0.12, h * 0.46), accent); // Hand open up

    canvas.drawLine(Offset(w * 0.70, h * 0.32), Offset(w * 0.78, h * 0.52), line);
    canvas.drawLine(Offset(w * 0.78, h * 0.52), Offset(w * 0.88, h * 0.46), accent); // Hand open up

    // Legs
    canvas.drawLine(Offset(w * 0.45, h * 0.72), Offset(w * 0.42, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.55, h * 0.72), Offset(w * 0.58, h * 0.90), line);
  }

  void _paintHandWringing(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Focus on hands clasped/rubbing
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, line);

    canvas.drawLine(Offset(w * 0.38, h * 0.34), Offset(w * 0.46, h * 0.56), line);
    canvas.drawLine(Offset(w * 0.62, h * 0.34), Offset(w * 0.54, h * 0.56), line);

    // Clenched interlocking hands
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.58), width: w * 0.22, height: h * 0.16), accent);
    canvas.drawLine(Offset(w * 0.44, h * 0.54), Offset(w * 0.56, h * 0.62), line);
    canvas.drawLine(Offset(w * 0.44, h * 0.62), Offset(w * 0.56, h * 0.54), line);

    // Motion lines (friction / anxiety)
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.34, h * 0.58), width: w * 0.10, height: h * 0.12), -1.2, 2.4, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.66, h * 0.58), width: w * 0.10, height: h * 0.12), 1.9, 2.4, false, line);
  }

  void _paintFingerTapping(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Desk surface
    canvas.drawLine(Offset(w * 0.10, h * 0.65), Offset(w * 0.90, h * 0.65), line);

    // Arm and hand on desk
    canvas.drawLine(Offset(w * 0.20, h * 0.35), Offset(w * 0.42, h * 0.55), line);
    canvas.drawLine(Offset(w * 0.42, h * 0.55), Offset(w * 0.58, h * 0.55), line);

    // Tapping fingers
    canvas.drawLine(Offset(w * 0.58, h * 0.55), Offset(w * 0.62, h * 0.64), accent);
    canvas.drawLine(Offset(w * 0.64, h * 0.55), Offset(w * 0.68, h * 0.62), accent);
    canvas.drawLine(Offset(w * 0.70, h * 0.55), Offset(w * 0.74, h * 0.64), accent);

    // Tap vibration ripples
    canvas.drawCircle(Offset(w * 0.62, h * 0.65), w * 0.04, accent);
    canvas.drawCircle(Offset(w * 0.74, h * 0.65), w * 0.04, accent);
  }

  void _paintHandsOnHips(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, line);

    // Torso (Broad posture)
    final torso = Path();
    torso.moveTo(w * 0.36, h * 0.34);
    torso.lineTo(w * 0.64, h * 0.34);
    torso.lineTo(w * 0.58, h * 0.68);
    torso.lineTo(w * 0.42, h * 0.68);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Left Arm flared out with hand on hip
    canvas.drawLine(Offset(w * 0.36, h * 0.34), Offset(w * 0.18, h * 0.50), accent);
    canvas.drawLine(Offset(w * 0.18, h * 0.50), Offset(w * 0.38, h * 0.62), accent);

    // Right Arm flared out with hand on hip
    canvas.drawLine(Offset(w * 0.64, h * 0.34), Offset(w * 0.82, h * 0.50), accent);
    canvas.drawLine(Offset(w * 0.82, h * 0.50), Offset(w * 0.62, h * 0.62), accent);

    // Confident wide legs stance
    canvas.drawLine(Offset(w * 0.44, h * 0.68), Offset(w * 0.36, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.68), Offset(w * 0.64, h * 0.90), line);
  }

  void _paintHandsBehindHead(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.24), w * 0.11, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.24), w * 0.11, line);

    // Arms bent behind head with elbows flared out
    canvas.drawLine(Offset(w * 0.35, h * 0.36), Offset(w * 0.16, h * 0.22), accent);
    canvas.drawLine(Offset(w * 0.16, h * 0.22), Offset(w * 0.42, h * 0.18), accent);

    canvas.drawLine(Offset(w * 0.65, h * 0.36), Offset(w * 0.84, h * 0.22), accent);
    canvas.drawLine(Offset(w * 0.84, h * 0.22), Offset(w * 0.58, h * 0.18), accent);

    // Hands interlaced behind head
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.16), width: w * 0.20, height: h * 0.08), 0, 3.14, false, accent);

    // Torso leaning back
    final torso = Path();
    torso.moveTo(w * 0.35, h * 0.36);
    torso.lineTo(w * 0.65, h * 0.36);
    torso.lineTo(w * 0.58, h * 0.72);
    torso.lineTo(w * 0.42, h * 0.72);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Legs
    canvas.drawLine(Offset(w * 0.44, h * 0.72), Offset(w * 0.40, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.72), Offset(w * 0.60, h * 0.90), line);
  }

  void _paintSteeplingHands(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.09, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.09, line);

    // Upper torso
    canvas.drawLine(Offset(w * 0.34, h * 0.30), Offset(w * 0.66, h * 0.30), line);

    // Forearms rising up toward center
    canvas.drawLine(Offset(w * 0.34, h * 0.30), Offset(w * 0.28, h * 0.60), line);
    canvas.drawLine(Offset(w * 0.28, h * 0.60), Offset(w * 0.44, h * 0.46), line);

    canvas.drawLine(Offset(w * 0.66, h * 0.30), Offset(w * 0.72, h * 0.60), line);
    canvas.drawLine(Offset(w * 0.72, h * 0.60), Offset(w * 0.56, h * 0.46), line);

    // Steeple fingers touching in pyramid (A-frame)
    final steeple = Path();
    steeple.moveTo(w * 0.42, h * 0.48);
    steeple.lineTo(w * 0.50, h * 0.36);
    steeple.lineTo(w * 0.58, h * 0.48);
    canvas.drawPath(steeple, accent);

    // Inner finger ridge lines
    canvas.drawLine(Offset(w * 0.46, h * 0.44), Offset(w * 0.50, h * 0.38), line);
    canvas.drawLine(Offset(w * 0.54, h * 0.44), Offset(w * 0.50, h * 0.38), line);

    // Authority aura pulse
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.36), width: w * 0.30, height: h * 0.20), 3.4, 2.3, false, accent);
  }

  void _paintHeadTilt(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head tilted sideways to the left (curiosity / empathy)
    canvas.save();
    canvas.translate(w * 0.48, h * 0.22);
    canvas.rotate(-0.25); // ~15 degrees tilt

    canvas.drawCircle(Offset.zero, w * 0.11, fill);
    canvas.drawCircle(Offset.zero, w * 0.11, line);

    // Friendly eyes and smile on tilted face
    canvas.drawCircle(Offset(-w * 0.04, -h * 0.02), w * 0.015, line);
    canvas.drawCircle(Offset(w * 0.04, -h * 0.02), w * 0.015, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(0, h * 0.03), width: w * 0.08, height: h * 0.05), 0.2, 2.7, false, line);
    canvas.restore();

    // Exposed neck accent on right side
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.56, h * 0.32), width: w * 0.14, height: h * 0.10), 0.2, 1.8, false, accent);

    // Torso in open attentive posture
    canvas.drawLine(Offset(w * 0.34, h * 0.38), Offset(w * 0.66, h * 0.38), line);
    canvas.drawLine(Offset(w * 0.50, h * 0.38), Offset(w * 0.50, h * 0.72), line);

    canvas.drawLine(Offset(w * 0.34, h * 0.38), Offset(w * 0.24, h * 0.66), line);
    canvas.drawLine(Offset(w * 0.66, h * 0.38), Offset(w * 0.76, h * 0.66), line);

    // Legs
    canvas.drawLine(Offset(w * 0.44, h * 0.72), Offset(w * 0.42, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.72), Offset(w * 0.58, h * 0.90), line);
  }

  void _paintTouchingNeck(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head slightly lowered
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, line);

    // Hand placed over neck / suprasternal notch (pacifying gesture)
    canvas.drawLine(Offset(w * 0.66, h * 0.34), Offset(w * 0.74, h * 0.48), line); // Right arm
    canvas.drawLine(Offset(w * 0.74, h * 0.48), Offset(w * 0.52, h * 0.32), accent); // Hand covering neck

    // Neck touch target highlight
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.31), width: w * 0.12, height: h * 0.08), accent);

    // Left arm hanging tensely
    canvas.drawLine(Offset(w * 0.34, h * 0.34), Offset(w * 0.30, h * 0.66), line);

    // Torso
    canvas.drawLine(Offset(w * 0.34, h * 0.34), Offset(w * 0.66, h * 0.34), line);
    canvas.drawLine(Offset(w * 0.50, h * 0.34), Offset(w * 0.50, h * 0.72), line);

    // Stress pulsation ripples around neck
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.50, h * 0.31), width: w * 0.24, height: h * 0.16), -1.2, 2.4, false, accent);

    // Legs
    canvas.drawLine(Offset(w * 0.44, h * 0.72), Offset(w * 0.44, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.72), Offset(w * 0.56, h * 0.90), line);
  }

  void _paintHandsBehindBack(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Upright tall head
    canvas.drawCircle(Offset(w * 0.50, h * 0.19), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.19), w * 0.10, line);

    // Broad upright chest (open front)
    final torso = Path();
    torso.moveTo(w * 0.34, h * 0.32);
    torso.lineTo(w * 0.66, h * 0.32);
    torso.lineTo(w * 0.60, h * 0.70);
    torso.lineTo(w * 0.40, h * 0.70);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Arms pulled backwards behind torso
    canvas.drawLine(Offset(w * 0.34, h * 0.32), Offset(w * 0.26, h * 0.54), line);
    canvas.drawLine(Offset(w * 0.26, h * 0.54), Offset(w * 0.44, h * 0.66), accent);

    canvas.drawLine(Offset(w * 0.66, h * 0.32), Offset(w * 0.74, h * 0.54), line);
    canvas.drawLine(Offset(w * 0.74, h * 0.54), Offset(w * 0.56, h * 0.66), accent);

    // Hands clasped at lower back
    canvas.drawCircle(Offset(w * 0.50, h * 0.66), w * 0.05, accent);

    // Firm military/authoritative stance
    canvas.drawLine(Offset(w * 0.44, h * 0.70), Offset(w * 0.38, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.70), Offset(w * 0.62, h * 0.90), line);
  }

  void _paintHandsInPockets(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.10, line);

    // Torso
    final torso = Path();
    torso.moveTo(w * 0.36, h * 0.34);
    torso.lineTo(w * 0.64, h * 0.34);
    torso.lineTo(w * 0.60, h * 0.68);
    torso.lineTo(w * 0.40, h * 0.68);
    torso.close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Arms going directly into pant pockets
    canvas.drawLine(Offset(w * 0.36, h * 0.34), Offset(w * 0.28, h * 0.54), line);
    canvas.drawLine(Offset(w * 0.28, h * 0.54), Offset(w * 0.40, h * 0.68), accent); // Hand inside pocket

    canvas.drawLine(Offset(w * 0.64, h * 0.34), Offset(w * 0.72, h * 0.54), line);
    canvas.drawLine(Offset(w * 0.72, h * 0.54), Offset(w * 0.60, h * 0.68), accent); // Hand inside pocket

    // Pocket lines
    canvas.drawLine(Offset(w * 0.38, h * 0.65), Offset(w * 0.44, h * 0.71), accent);
    canvas.drawLine(Offset(w * 0.62, h * 0.65), Offset(w * 0.56, h * 0.71), accent);

    // Legs
    canvas.drawLine(Offset(w * 0.44, h * 0.68), Offset(w * 0.42, h * 0.90), line);
    canvas.drawLine(Offset(w * 0.56, h * 0.68), Offset(w * 0.58, h * 0.90), line);
  }

  void _paintLegsCrossed(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Seated upper body
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.10, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.10, line);

    // Torso
    canvas.drawLine(Offset(w * 0.36, h * 0.30), Offset(w * 0.64, h * 0.30), line);
    canvas.drawLine(Offset(w * 0.50, h * 0.30), Offset(w * 0.50, h * 0.58), line);

    // Relaxed arms
    canvas.drawLine(Offset(w * 0.36, h * 0.30), Offset(w * 0.30, h * 0.52), line);
    canvas.drawLine(Offset(w * 0.64, h * 0.30), Offset(w * 0.70, h * 0.52), line);

    // Chair seat line
    canvas.drawLine(Offset(w * 0.20, h * 0.60), Offset(w * 0.80, h * 0.60), line);

    // Crossed Leg 1 (Supporting)
    canvas.drawLine(Offset(w * 0.45, h * 0.60), Offset(w * 0.45, h * 0.88), line);

    // Crossed Leg 2 over Leg 1 (Barrier / Figure 4)
    final crossedLeg = Path();
    crossedLeg.moveTo(w * 0.55, h * 0.60);
    crossedLeg.lineTo(w * 0.38, h * 0.70);
    crossedLeg.lineTo(w * 0.68, h * 0.70);
    canvas.drawPath(crossedLeg, accent);

    canvas.drawLine(Offset(w * 0.68, h * 0.70), Offset(w * 0.70, h * 0.88), accent);
  }

  void _paintHandshake(Canvas canvas, Size size, Paint line, Paint fill, Paint accent) {
    final w = size.width;
    final h = size.height;

    // Left person forearm
    canvas.drawLine(Offset(w * 0.10, h * 0.45), Offset(w * 0.38, h * 0.50), line);
    // Right person forearm
    canvas.drawLine(Offset(w * 0.90, h * 0.45), Offset(w * 0.62, h * 0.50), line);

    // Clasping hands in center
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.28, height: h * 0.18), fill);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.28, height: h * 0.18), accent);

    // Thumb locks & interlocking fingers
    canvas.drawLine(Offset(w * 0.44, h * 0.42), Offset(w * 0.56, h * 0.46), line);
    canvas.drawLine(Offset(w * 0.42, h * 0.52), Offset(w * 0.58, h * 0.52), line);
    canvas.drawLine(Offset(w * 0.44, h * 0.58), Offset(w * 0.56, h * 0.56), line);

    // Connection pulse lines
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.22, accent);
  }

  @override
  bool shouldRepaint(covariant BodyPosturePainter oldDelegate) =>
      oldDelegate.postureKey != postureKey ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isHighContrast != isHighContrast;
}

