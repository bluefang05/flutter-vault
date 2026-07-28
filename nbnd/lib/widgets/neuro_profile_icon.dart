import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/neuro_type.dart';

class NeuroProfileIcon extends StatelessWidget {
  const NeuroProfileIcon({
    super.key,
    required this.neuroType,
    required this.size,
    this.selected = false,
    this.showBackground = true,
    this.borderColor,
  });

  final NeuroType neuroType;
  final double size;
  final bool selected;
  final bool showBackground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color color = borderColor ?? neuroType.color;
    final Widget icon = Image.asset(
      neuroType.iconAsset,
      width: size * .82,
      height: size * .82,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              neuroType.code,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      image: true,
      label: AppLocalizations.of(context).neuroTypeName(neuroType),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.04 : 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: selected ? 1 : .86,
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: showBackground
                    ? const Color(0xCC070811)
                    : Colors.transparent,
                border: Border.all(
                  color: selected ? color : color.withValues(alpha: .46),
                  width: selected ? 1.8 : 1.1,
                ),
                boxShadow: showBackground
                    ? <BoxShadow>[
                        BoxShadow(
                          color: color.withValues(alpha: selected ? .24 : .12),
                          blurRadius: selected ? 14 : 8,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(child: Center(child: icon)),
            ),
          ),
        ),
      ),
    );
  }
}
