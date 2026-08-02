part of '../main.dart';

class _ShopPreviewSection extends StatelessWidget {
  const _ShopPreviewSection({
    required this.equippedGrapaAsset,
    required this.onEquipGrapaAsset,
  });

  final String equippedGrapaAsset;
  final ValueChanged<String> onEquipGrapaAsset;

  static const items = [
    _ShopPreviewItem(
      name: 'Vestido',
      price: 120,
      assetPath: ShopItemAssets.grapaDressPremium,
      equippedAssetPath: GrapaEquippedAssets.dressPremium,
    ),
    _ShopPreviewItem(
      name: 'Lazo',
      price: 80,
      assetPath: ShopItemAssets.grapaBowPremium,
      equippedAssetPath: GrapaEquippedAssets.bowPremium,
    ),
    _ShopPreviewItem(
      name: 'Sombrero',
      price: 95,
      assetPath: ShopItemAssets.grapaHatPremium,
      equippedAssetPath: GrapaEquippedAssets.hatPremium,
    ),
    _ShopPreviewItem(
      name: 'Mochila',
      price: 140,
      assetPath: ShopItemAssets.grapaBackpackPremium,
      equippedAssetPath: GrapaEquippedAssets.backpackPremium,
    ),
    _ShopPreviewItem(
      name: 'Bufanda',
      price: 110,
      assetPath: ShopItemAssets.winterScarf,
      equippedAssetPath: GrapaEquippedAssets.scarfWinter,
    ),
    _ShopPreviewItem(
      name: 'Cama Pin',
      price: 160,
      assetPath: ShopItemAssets.pinPremiumBed,
    ),
    _ShopPreviewItem(
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
                return _ShopItemCard(
                  item: item,
                  isEquipped: item.equippedAssetPath == equippedGrapaAsset,
                  onEquip: item.equippedAssetPath == null
                      ? null
                      : () => onEquipGrapaAsset(item.equippedAssetPath!),
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
    required this.isEquipped,
    required this.onEquip,
  });

  final _ShopPreviewItem item;
  final bool isEquipped;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEquip,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 118,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFFECE4FF)
                : const Color(0xFFF9F3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF7656D6)
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
                  ],
                ],
              ),
              const SizedBox(height: 4),
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
              if (onEquip != null) ...[
                const SizedBox(height: 4),
                Text(
                  isEquipped ? 'Equipado' : 'Equipar',
                  style: TextStyle(
                    color: isEquipped
                        ? const Color(0xFF5B3FC1)
                        : const Color(0xFF7A6F65),
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
  const _UpgradeWorkshopCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8D6B6), width: 1.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              ScenarioAssets.upgradeWorkshop,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de mejoras',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Mejoras para Pin y equipo. No es ropa de Grapa.',
                  style: TextStyle(
                    color: Color(0xFF80776D),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

class _ShopPreviewItem {
  const _ShopPreviewItem({
    required this.name,
    required this.price,
    required this.assetPath,
    this.equippedAssetPath,
  });

  final String name;
  final int price;
  final String assetPath;
  final String? equippedAssetPath;
}
