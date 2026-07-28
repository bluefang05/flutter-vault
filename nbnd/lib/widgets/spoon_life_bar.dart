import 'package:flutter/material.dart';

enum SpoonFillState { full, half, empty }

SpoonFillState spoonFillStateForIndex({
  required int index,
  required int currentHalves,
}) {
  final int remainingForSpoon = currentHalves - (index * 2);
  if (remainingForSpoon >= 2) return SpoonFillState.full;
  if (remainingForSpoon == 1) return SpoonFillState.half;
  return SpoonFillState.empty;
}

class SpoonLifeBar extends StatelessWidget {
  const SpoonLifeBar({
    super.key,
    required this.currentHalves,
    required this.maxHalves,
  });

  final int currentHalves;
  final int maxHalves;

  String _assetFor(SpoonFillState state) {
    return switch (state) {
      SpoonFillState.full => 'assets/images/spoons/spoon_full.png',
      SpoonFillState.half => 'assets/images/spoons/spoon_half.png',
      SpoonFillState.empty => 'assets/images/spoons/spoon_empty.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final int spoonCount = (maxHalves / 2).ceil();
    final int safeCurrent = currentHalves.clamp(0, maxHalves).toInt();

    return Semantics(
      label: 'Reserva: $safeCurrent de $maxHalves medias cucharas',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xD9141727),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: .13)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(spoonCount, (int index) {
              final SpoonFillState state = spoonFillStateForIndex(
                index: index,
                currentHalves: safeCurrent,
              );
              return Padding(
                padding: EdgeInsets.only(right: index == spoonCount - 1 ? 0 : 2),
                child: Image.asset(
                  _assetFor(state),
                  width: 20,
                  height: 40,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
