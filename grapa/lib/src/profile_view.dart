part of '../main.dart';

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.streak,
    required this.coins,
    required this.totalCoinsEarned,
    required this.equippedGrapaAsset,
    required this.onEquipGrapaAsset,
  });

  final int streak;
  final int coins;
  final int totalCoinsEarned;
  final String equippedGrapaAsset;
  final ValueChanged<String> onEquipGrapaAsset;

  @override
  Widget build(BuildContext context) {
    final level = 1 + totalCoinsEarned ~/ 250;
    final nextLevelCoins = level * 250;
    final levelProgress = (totalCoinsEarned % 250) / 250;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Tu progreso',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        _ProfileHeroCard(
          streak: streak,
          coins: coins,
          totalCoinsEarned: totalCoinsEarned,
          level: level,
          levelProgress: levelProgress,
          nextLevelCoins: nextLevelCoins,
          equippedGrapaAsset: equippedGrapaAsset,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _CompactProgressTile(
                icon: Icons.local_fire_department_rounded,
                value: '$streak',
                label: streak == 1 ? 'dia activo' : 'dias activos',
                color: const Color(0xFFF0A445),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactProgressTile(
                icon: Icons.paid_rounded,
                value: '$coins',
                label: 'monedas',
                color: const Color(0xFF73B597),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _ScenarioCard(
          assetPath: ScenarioAssets.rewardShop,
          title: 'Tienda de recompensas',
          subtitle: 'Ropa, accesorios y objetos desbloqueables.',
        ),
        const SizedBox(height: 10),
        _ShopPreviewSection(
          equippedGrapaAsset: equippedGrapaAsset,
          onEquipGrapaAsset: onEquipGrapaAsset,
        ),
        const SizedBox(height: 10),
        const _UpgradeWorkshopCard(),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.streak,
    required this.coins,
    required this.totalCoinsEarned,
    required this.level,
    required this.levelProgress,
    required this.nextLevelCoins,
    required this.equippedGrapaAsset,
  });

  final int streak;
  final int coins;
  final int totalCoinsEarned;
  final int level;
  final double levelProgress;
  final int nextLevelCoins;
  final String equippedGrapaAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2940),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: Image.asset(
                    equippedGrapaAsset,
                    fit: BoxFit.contain,
                    cacheHeight: (260 * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aventurero constante',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tu look y tu progreso viven aqui.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .72),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LevelBadge(level: level),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: levelProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: .14),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF0C75E)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$totalCoinsEarned / $nextLevelCoins monedas ganadas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .74),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                streak == 0 ? 'Sin racha' : 'Racha $streak',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .74),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(EconomyAssets.levelBadge, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            'Nivel $level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactProgressTile extends StatelessWidget {
  const _CompactProgressTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF80776D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
