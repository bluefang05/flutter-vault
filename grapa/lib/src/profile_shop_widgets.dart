part of '../main.dart';

class _ShopPreviewSection extends StatelessWidget {
  const _ShopPreviewSection({
    required this.equippedGrapaAsset,
    required this.purchasedItems,
    required this.onEquipGrapaAsset,
    required this.onBuyItem,
  });

  final String equippedGrapaAsset;
  final Set<String> purchasedItems;
  final ValueChanged<String> onEquipGrapaAsset;
  final ValueChanged<_ShopPreviewItem> onBuyItem;

  static const items = [
    _ShopPreviewItem(
      id: 'dress_premium_01',
      name: 'Vestido',
      price: 120,
      assetPath: ShopItemAssets.grapaDressPremium,
      equippedAssetPath: GrapaEquippedAssets.dressPremium,
    ),
    _ShopPreviewItem(
      id: 'bow_premium_01',
      name: 'Lazo',
      price: 80,
      assetPath: ShopItemAssets.grapaBowPremium,
      equippedAssetPath: GrapaEquippedAssets.bowPremium,
    ),
    _ShopPreviewItem(
      id: 'hat_premium_01',
      name: 'Sombrero',
      price: 95,
      assetPath: ShopItemAssets.grapaHatPremium,
      equippedAssetPath: GrapaEquippedAssets.hatPremium,
    ),
    _ShopPreviewItem(
      id: 'backpack_premium_01',
      name: 'Mochila',
      price: 140,
      assetPath: ShopItemAssets.grapaBackpackPremium,
      equippedAssetPath: GrapaEquippedAssets.backpackPremium,
    ),
    _ShopPreviewItem(
      id: 'winter_scarf_01',
      name: 'Bufanda',
      price: 110,
      assetPath: ShopItemAssets.winterScarf,
      equippedAssetPath: GrapaEquippedAssets.scarfWinter,
    ),
    _ShopPreviewItem(
      id: 'pin_bed_01',
      name: 'Cama Pin',
      price: 160,
      assetPath: ShopItemAssets.pinPremiumBed,
    ),
    _ShopPreviewItem(
      id: 'pin_toy_01',
      name: 'Juguete',
      price: 70,
      assetPath: ShopItemAssets.pinToy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7D8F4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3AA8).withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_rounded, color: Color(0xFF6D49B6)),
              SizedBox(width: 8),
              Text(
                'Objetos disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final isOwned = purchasedItems.contains(item.id);
                return _ShopItemCard(
                  item: item,
                  isOwned: isOwned,
                  isEquipped:
                      isOwned && item.equippedAssetPath == equippedGrapaAsset,
                  onEquip: item.equippedAssetPath == null
                      ? null
                      : () => onEquipGrapaAsset(item.equippedAssetPath!),
                  onBuy: () => onBuyItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.onEquip,
    required this.onBuy,
  });

  final _ShopPreviewItem item;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback? onEquip;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final isWearable = item.equippedAssetPath != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !isOwned
            ? onBuy
            : isWearable
            ? onEquip
            : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 118,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFFECE4FF)
                : isOwned
                ? const Color(0xFFF1FAF4)
                : const Color(0xFFF9F3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF7656D6)
                  : isOwned
                  ? const Color(0xFF73CBB0)
                  : const Color(0xFFD8C2EF),
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: Image.asset(item.assetPath, fit: BoxFit.contain)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (isEquipped) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: Color(0xFF7656D6),
                    ),
                  ] else if (isOwned) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (!isOwned) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      EconomyAssets.coin,
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.price}',
                      style: const TextStyle(
                        color: Color(0xFF8B5A11),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Comprar',
                  style: TextStyle(
                    color: Color(0xFF7656D6),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ] else if (isWearable) ...[
                const SizedBox(height: 4),
                Text(
                  isEquipped ? 'Equipado' : 'Equipar',
                  style: TextStyle(
                    color: isEquipped
                        ? const Color(0xFF5B3FC1)
                        : const Color(0xFF437A5D),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                const Text(
                  'En casita',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeWorkshopCard extends StatelessWidget {
  const _UpgradeWorkshopCard({
    required this.onOpenWorkshop,
    required this.streakShields,
    required this.purchasedUpgrades,
  });

  final VoidCallback onOpenWorkshop;
  final int streakShields;
  final Set<String> purchasedUpgrades;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBF4),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onOpenWorkshop,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8D6B6), width: 1.2),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  ScenarioAssets.upgradeWorkshop,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Taller de mejoras',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFF80776D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Habilidades especiales permanentes y escudos de racha.',
                      style: TextStyle(
                        color: Color(0xFF80776D),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8DA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🛡️ $streakShields escudos',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (purchasedUpgrades.contains('coin_magnet'))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7DDFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🧲 Imán activo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5B3FC1),
                              ),
                            ),
                          ),
                        if (purchasedUpgrades.contains('gourmet_snack'))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCF0DF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🍲 Gourmet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeWorkshopSheet extends StatelessWidget {
  const _UpgradeWorkshopSheet({
    required this.coins,
    required this.streakShields,
    required this.purchasedUpgrades,
    required this.onBuyUpgrade,
  });

  final int coins;
  final int streakShields;
  final Set<String> purchasedUpgrades;
  final ValueChanged<String> onBuyUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4CDC1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Taller de Mejoras',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Desbloquea habilidades y comodines con tus monedas.',
                          style: TextStyle(
                            color: const Color(0xFF80776D),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Pill(assetPath: EconomyAssets.coin, text: '$coins'),
                ],
              ),
              const SizedBox(height: 18),
              _UpgradeRow(
                id: 'streak_shield',
                title: 'Escudo de Racha',
                description:
                    'Protege tu racha si un día no puedes entrar a completar tareas.',
                assetPath: EconomyAssets.gem,
                price: 120,
                statusText: 'Tienes $streakShields',
                isPurchased: false,
                onBuy: () => onBuyUpgrade('streak_shield'),
              ),
              const SizedBox(height: 12),
              _UpgradeRow(
                id: 'coin_magnet',
                title: 'Imán de Monedas',
                description:
                    'Otorga +2 monedas de bonificación en cada misión completada.',
                assetPath: EconomyAssets.coin,
                price: 180,
                isPurchased: purchasedUpgrades.contains('coin_magnet'),
                onBuy: () => onBuyUpgrade('coin_magnet'),
              ),
              const SizedBox(height: 12),
              _UpgradeRow(
                id: 'gourmet_snack',
                title: 'Merienda Gourmet de Pin',
                description:
                    'Alimentar a Pin restaura 2 corazones de golpe en vez de 1.',
                assetPath: PinHomeAssets.foodBowl,
                price: 150,
                isPurchased: purchasedUpgrades.contains('gourmet_snack'),
                onBuy: () => onBuyUpgrade('gourmet_snack'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.price,
    required this.isPurchased,
    required this.onBuy,
    this.statusText,
  });

  final String id;
  final String title;
  final String description;
  final String assetPath;
  final int price;
  final bool isPurchased;
  final VoidCallback onBuy;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0D5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF80776D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (statusText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    statusText!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF7656D6),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isPurchased)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5E3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Activa',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            )
          else
            FilledButton(
              onPressed: onBuy,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '$price 🪙',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopPreviewItem {
  const _ShopPreviewItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    this.equippedAssetPath,
  });

  final String id;
  final String name;
  final int price;
  final String assetPath;
  final String? equippedAssetPath;
}
