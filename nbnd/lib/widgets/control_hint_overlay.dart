import 'dart:math' as math;

import 'package:flutter/material.dart';

class ControlHintOverlay extends StatefulWidget {
  const ControlHintOverlay({
    super.key,
    required this.counterClockwise,
    required this.clockwise,
    required this.touchAndHold,
    required this.powerAction,
    required this.touchCenter,
    required this.centerRadius,
    required this.reducedFlashes,
  });

  final String counterClockwise;
  final String clockwise;
  final String touchAndHold;
  final String powerAction;
  final String touchCenter;
  final double centerRadius;
  final bool reducedFlashes;

  @override
  State<ControlHintOverlay> createState() => _ControlHintOverlayState();
}

class _ControlHintOverlayState extends State<ControlHintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (!widget.reducedFlashes) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ControlHintOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedFlashes == widget.reducedFlashes) return;
    if (widget.reducedFlashes) {
      _controller
        ..stop()
        ..value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double breath = widget.reducedFlashes
              ? 0
              : Curves.easeInOut.transform(_controller.value);
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;
              final double sideWidth = math.max(
                64,
                width / 2 - widget.centerRadius - 12,
              );
              final double sideCenter = sideWidth / 2 + 6;
              final double alignmentX = (2 * sideCenter / width) - 1;
              return CustomPaint(
                painter: _ControlZonePainter(
                  centerRadius: widget.centerRadius,
                  breath: breath,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _CenterPowerLabel(
                      centerRadius: widget.centerRadius,
                      title: widget.powerAction,
                      subtitle: widget.touchCenter,
                      scale: 1 + breath * .035,
                    ),
                    _ZoneLabel(
                      alignment: Alignment(alignmentX, .18),
                      maxWidth: sideWidth,
                      arrow: Icons.rotate_left_rounded,
                      color: const Color(0xFFFF6E9A),
                      title: widget.counterClockwise,
                      subtitle: widget.touchAndHold,
                      scale: 1 + breath * .025,
                    ),
                    _ZoneLabel(
                      alignment: Alignment(-alignmentX, .18),
                      maxWidth: sideWidth,
                      arrow: Icons.rotate_right_rounded,
                      color: const Color(0xFF55E6C1),
                      title: widget.clockwise,
                      subtitle: widget.touchAndHold,
                      scale: 1 + breath * .025,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CenterPowerLabel extends StatelessWidget {
  const _CenterPowerLabel({
    required this.centerRadius,
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  final double centerRadius;
  final String title;
  final String subtitle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, centerRadius + 56),
        child: Transform.scale(
          scale: scale,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.touch_app_rounded,
                  size: 34,
                  color: Color(0xFFFFC784),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFFFC784),
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({
    required this.alignment,
    required this.maxWidth,
    required this.arrow,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  final Alignment alignment;
  final double maxWidth;
  final IconData arrow;
  final Color color;
  final String title;
  final String subtitle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.scale(
        scale: scale,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(arrow, size: 48, color: color),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlZonePainter extends CustomPainter {
  const _ControlZonePainter({required this.centerRadius, required this.breath});

  final double centerRadius;
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Path centerHole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: centerRadius));
    final double alpha = .105 + breath * .025;

    _paintSide(
      canvas,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height)),
      centerHole,
      const Color(0xFFFF6E9A),
      alpha,
      Alignment.centerLeft,
      Alignment.centerRight,
      size,
    );
    _paintSide(
      canvas,
      Path()..addRect(
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      ),
      centerHole,
      const Color(0xFF55E6C1),
      alpha,
      Alignment.centerRight,
      Alignment.centerLeft,
      size,
    );

    canvas.drawCircle(
      center,
      centerRadius + 3 + math.sin(breath * math.pi) * 2,
      Paint()
        ..color = const Color(0xFFFFC784).withValues(alpha: .42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      centerRadius + 12 + math.sin(breath * math.pi) * 5,
      Paint()
        ..color = const Color(0xFFFFC784).withValues(alpha: .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintSide(
    Canvas canvas,
    Path side,
    Path centerHole,
    Color color,
    double alpha,
    Alignment begin,
    Alignment end,
    Size size,
  ) {
    final Path visible = Path.combine(
      PathOperation.difference,
      side,
      centerHole,
    );
    canvas.drawPath(
      visible,
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: <Color>[
            color.withValues(alpha: alpha + .08),
            color.withValues(alpha: alpha),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _ControlZonePainter oldDelegate) {
    return oldDelegate.centerRadius != centerRadius ||
        oldDelegate.breath != breath;
  }
}
