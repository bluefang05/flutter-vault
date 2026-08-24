part of '../main.dart';

class _PinView extends StatelessWidget {
  const _PinView({
    required this.hearts,
    required this.justFed,
    required this.canFeed,
    required this.purchasedItems,
    required this.onFeed,
  });

  final int hearts;
  final bool justFed;
  final bool canFeed;
  final Set<String> purchasedItems;
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
          'Tu pequeño compañero crece con tu constancia. ¡Tócalo para acariciarlo!',
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
                _PinSceneInteractive(pinScene: pinScene, hearts: hearts),
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
                        : 'Pin está esperando tu cariño y merienda',
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
        _PinHomePreview(hearts: hearts, purchasedItems: purchasedItems),
      ],
    );
  }
}

class _PinSceneInteractive extends StatefulWidget {
  const _PinSceneInteractive({required this.pinScene, required this.hearts});

  final String pinScene;
  final int hearts;

  @override
  State<_PinSceneInteractive> createState() => _PinSceneInteractiveState();
}

class _PinSceneInteractiveState extends State<_PinSceneInteractive> {
  double _scale = 1.0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPet() {
    HapticFeedback.selectionClick();
    _timer?.cancel();
    setState(() => _scale = 1.12);
    _timer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() => _scale = 1.0);
      }
    });
    final msg = widget.hearts >= 5
        ? '¡Pin da saltitos de alegría y te manda corazones! ✨'
        : widget.hearts >= 3
        ? '¡A Pin le encantan tus caricias! 💖'
        : 'Pin agradece tu cariño y se siente más animado. 🌱';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPet,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: Image.asset(
          widget.pinScene,
          key: ValueKey(widget.pinScene),
          width: 230,
          height: 230,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PinHomePreview extends StatelessWidget {
  const _PinHomePreview({required this.hearts, required this.purchasedItems});

  final int hearts;
  final Set<String> purchasedItems;

  @override
  Widget build(BuildContext context) {
    final hasBed = purchasedItems.contains('pin_bed_01');
    final hasToy = purchasedItems.contains('pin_toy_01');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 80,
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
                if (hasBed)
                  Positioned(
                    left: 2,
                    bottom: 0,
                    child: Image.asset(
                      PinHomeAssets.bed,
                      width: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (hasToy)
                  Positioned(
                    right: 4,
                    top: 6,
                    child: Image.asset(
                      PinHomeAssets.toy,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (hearts >= 4)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      PinHomeAssets.foodBowl,
                      width: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (hearts >= 5)
                  Positioned(
                    left: 0,
                    bottom: 2,
                    child: Image.asset(
                      PinHomeAssets.lamp,
                      width: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La casita de Pin',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  hasBed || hasToy
                      ? '¡Has equipado comodidades de la tienda para Pin!'
                      : 'Mejora el hogar de Pin con la tienda y tus rachas.',
                  style: const TextStyle(
                    color: Color(0xFF81786C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
