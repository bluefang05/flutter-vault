import 'package:flutter/material.dart';

class TopAdPlaceholder extends StatelessWidget {
  const TopAdPlaceholder({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return SafeArea(
      bottom: false,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: .25),
            ),
          ),
        ),
        child: Text(
          'ESPACIO PUBLICITARIO',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.3,
          ),
        ),
      ),
    );
  }
}
