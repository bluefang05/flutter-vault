part of '../main.dart';

class _PinView extends StatelessWidget {
  const _PinView({
    required this.hearts,
    required this.justFed,
    required this.canFeed,
    required this.onFeed,
  });

  final int hearts;
  final bool justFed;
  final bool canFeed;
  final VoidCallback onFeed;

  @override
  Widget build(BuildContext context) {
    final pinScene = PinActionAssets.forMood(hearts: hearts, justFed: justFed);
    final backgroundAsset = justFed
        ? PinActionAssets.eatingInRoom
        : ScenarioAssets.pinHomeForHearts(hearts);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'El rincón de Pin',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Tu pequeño compañero crece con tu constancia.',
          style: TextStyle(color: Color(0xFF81786C)),
        ),
        const SizedBox(height: 24),
        Container(
          height: 330,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7B8),
            image: DecorationImage(
              image: _assetImageForLogicalWidth(context, backgroundAsset, 760),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: justFed ? .06 : .24),
                BlendMode.srcATop,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 24,
                right: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < hearts
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: const Color(0xFFF06B72),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              if (!justFed)
                Image.asset(
                  pinScene,
                  key: ValueKey(pinScene),
                  width: 230,
                  height: 230,
                  fit: BoxFit.contain,
                ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201A25).withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    justFed
                        ? 'Pin está disfrutando su merienda'
                        : 'Pin está esperando su merienda',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: canFeed ? onFeed : null,
          icon: Image.asset(PinHomeAssets.foodBowl, width: 24, height: 24),
          label: Text(
            justFed || hearts >= 5
                ? 'Pin ya está satisfecho'
                : 'Dar merienda - 10 monedas',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        _PinHomePreview(hearts: hearts),
      ],
    );
  }
}

class _PinHomePreview extends StatelessWidget {
  const _PinHomePreview({required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -4,
                  child: Image.asset(
                    PinHomeAssets.rug,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  PinHomeAssets.houseForHearts(hearts),
                  width: 92,
                  fit: BoxFit.contain,
                ),
                if (hearts >= 4)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      PinHomeAssets.foodBowl,
                      width: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (hearts >= 5)
                  Positioned(
                    left: 0,
                    bottom: 2,
                    child: Image.asset(
                      PinHomeAssets.lamp,
                      width: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La casita de Pin',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Mejora el hogar de Pin con rachas y recompensas.',
                  style: TextStyle(color: Color(0xFF81786C), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
