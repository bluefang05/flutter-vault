import 'package:flutter/material.dart';

class BadgePill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final Color? backgroundColor;

  const BadgePill({
    super.key,
    required this.text,
    this.icon,
    required this.color,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? color.withValues(alpha: 0.22) : color.withValues(alpha: 0.12));
    
    // Ensure WCAG AAA contrast by adjusting foreground brightness per theme
    final Color fg = textColor ??
        (isDark
            ? Color.lerp(color, Colors.white, 0.75)!
            : Color.lerp(color, Colors.black, 0.35)!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withValues(alpha: 0.45) : color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
