part of '../main.dart';

class GrapaHome extends StatefulWidget {
  const GrapaHome({super.key, this.showAds = true});

  final bool showAds;

  @override
  State<GrapaHome> createState() => _GrapaHomeState();
}

class _GrapaHomeState extends State<GrapaHome> with WidgetsBindingObserver {
  static const _missionsKey = 'daily_missions';
  static const _missionsDateKey = 'daily_missions_date';
  static const _coinsKey = 'coins';
  static const _streakKey = 'streak';
  static const _pinHeartsKey = 'pin_hearts';
  static const _lastCompletedDateKey = 'last_completed_date';
  static const _dailyRewardsEarnedKey = 'daily_rewards_earned';
  static const _equippedGrapaAssetKey = 'equipped_grapa_asset';
  static const _totalCoinsEarnedKey = 'total_coins_earned';
  static const _purchasedItemsKey = 'purchased_items';
  static const _adventureDaysCompletedKey = 'adventure_days_completed';
  static const _purchasedUpgradesKey = 'purchased_upgrades';
  static const _streakShieldsKey = 'streak_shields';
  static const _completedDatesHistoryKey = 'completed_dates_history';

  static const _maxDailyMissionRewards = 5;
  int get _rewardPerMission =>
      _purchasedUpgrades.contains('coin_magnet') ? 12 : 10;
  int get _maxDailyReward => _rewardPerMission * _maxDailyMissionRewards;

  int _tab = 0;
  int _coins = 50;
  int _totalCoinsEarned = 50;
  int _streak = 0;
  int _pinHearts = 3;
  int _dailyRewardsEarned = 0;
  int _adventureDaysCompleted = 0;
  int _streakShields = 0;
  bool _pinJustFed = false;
  String _equippedGrapaAsset = GrapaEquippedAssets.dressPremium;
  Set<String> _purchasedItems = {'dress_premium_01'};
  Set<String> _purchasedUpgrades = {};
  Set<String> _completedDatesHistory = {};
  String? _lastCompletedDate;
  late String _activeDate;
  Timer? _dayTimer;
  final _missions = <Mission>[
    Mission(
      'Preparar presentación',
      'Trabajo · 30 min',
      MissionCategoryAssets.work,
      const Color(0xFFFFB765),
    ),
    Mission(
      'Caminar 20 minutos',
      'Salud · Antes de las 6:00 p. m.',
      MissionCategoryAssets.exercise,
      const Color(0xFF73CBB0),
    ),
    Mission(
      'Leer 10 páginas',
      'Crecimiento · 15 min',
      MissionCategoryAssets.study,
      const Color(0xFF92A5E8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeDate = _todayKey;
    _loadState();
    _dayTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _rollOverDayIfNeeded(),
    );
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rollOverDayIfNeeded();
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  String get _todayKey {
    return _dateKey(DateTime.now());
  }

  Future<void> _loadState() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_missionsKey);
    final isNewDay = preferences.getString(_missionsDateKey) != _todayKey;
    var loaded = List<Mission>.from(_missions);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        loaded = decoded
            .map((item) => Mission.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Keep the starter missions if locally stored data is damaged.
      }
    }
    if (isNewDay) {
      for (final mission in loaded) {
        mission
          ..done = false
          ..rewardedToday = false;
      }
    }
    final savedDailyRewards = preferences.getInt(_dailyRewardsEarnedKey);
    var dailyRewardsEarned = isNewDay ? 0 : savedDailyRewards ?? 0;
    if (!isNewDay && savedDailyRewards == null) {
      for (final mission in loaded.where((mission) => mission.done)) {
        if (dailyRewardsEarned >= _maxDailyReward) break;
        mission.rewardedToday = true;
        dailyRewardsEarned += _rewardPerMission;
      }
    }
    final savedPurchased = preferences.getStringList(_purchasedItemsKey);
    final purchasedItems = savedPurchased != null && savedPurchased.isNotEmpty
        ? savedPurchased.toSet()
        : <String>{'dress_premium_01'};
    purchasedItems.add('dress_premium_01');

    final savedUpgrades = preferences.getStringList(_purchasedUpgradesKey);
    final purchasedUpgrades = savedUpgrades != null
        ? savedUpgrades.toSet()
        : <String>{};

    final savedHistory = preferences.getStringList(_completedDatesHistoryKey);
    final history = savedHistory != null ? savedHistory.toSet() : <String>{};

    if (!mounted) return;
    setState(() {
      _missions
        ..clear()
        ..addAll(loaded);
      _coins = preferences.getInt(_coinsKey) ?? 50;
      _totalCoinsEarned =
          preferences.getInt(_totalCoinsEarnedKey) ?? math.max(_coins, 50);
      _streak = preferences.getInt(_streakKey) ?? 0;
      _pinHearts = preferences.getInt(_pinHeartsKey) ?? 3;
      _adventureDaysCompleted =
          preferences.getInt(_adventureDaysCompletedKey) ?? 0;
      _streakShields = preferences.getInt(_streakShieldsKey) ?? 0;
      _purchasedUpgrades = purchasedUpgrades;
      _completedDatesHistory = history;

      final savedGrapaAsset = preferences.getString(_equippedGrapaAssetKey);
      _equippedGrapaAsset =
          savedGrapaAsset != null &&
              GrapaEquippedAssets.isKnown(savedGrapaAsset)
          ? savedGrapaAsset
          : GrapaEquippedAssets.dressPremium;
      for (final item in _ShopPreviewSection.items) {
        if (item.equippedAssetPath != null &&
            item.equippedAssetPath == _equippedGrapaAsset) {
          purchasedItems.add(item.id);
        }
      }
      _purchasedItems = purchasedItems;
      _dailyRewardsEarned =
          ((dailyRewardsEarned ~/ _rewardPerMission) * _rewardPerMission).clamp(
            0,
            _maxDailyReward,
          );
      _lastCompletedDate = preferences.getString(_lastCompletedDateKey);
      _activeDate = _todayKey;
      _pinJustFed = false;
    });
    await _saveState();
  }

  Future<void> _saveState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _missionsKey,
      jsonEncode(_missions.map((mission) => mission.toJson()).toList()),
    );
    await Future.wait([
      preferences.setString(_missionsDateKey, _activeDate),
      preferences.setInt(_coinsKey, _coins),
      preferences.setInt(_totalCoinsEarnedKey, _totalCoinsEarned),
      preferences.setInt(_streakKey, _streak),
      preferences.setInt(_pinHeartsKey, _pinHearts),
      preferences.setInt(_dailyRewardsEarnedKey, _dailyRewardsEarned),
      preferences.setString(_equippedGrapaAssetKey, _equippedGrapaAsset),
      preferences.setStringList(_purchasedItemsKey, _purchasedItems.toList()),
      preferences.setInt(_adventureDaysCompletedKey, _adventureDaysCompleted),
      preferences.setInt(_streakShieldsKey, _streakShields),
      preferences.setStringList(
        _purchasedUpgradesKey,
        _purchasedUpgrades.toList(),
      ),
      preferences.setStringList(
        _completedDatesHistoryKey,
        _completedDatesHistory.toList(),
      ),
      if (_lastCompletedDate != null)
        preferences.setString(_lastCompletedDateKey, _lastCompletedDate!),
    ]);
  }

  Future<void> _rollOverDayIfNeeded() async {
    final today = _todayKey;
    if (today == _activeDate || !mounted) return;
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final missedYesterday = _lastCompletedDate != yesterday;

    setState(() {
      for (final mission in _missions) {
        mission
          ..done = false
          ..rewardedToday = false;
      }
      _dailyRewardsEarned = 0;
      if (missedYesterday && _streak > 0) {
        if (_streakShields > 0) {
          _streakShields -= 1; // Shield absorbed the loss!
        } else {
          _streak = 0;
        }
      }
      _activeDate = today;
      _pinJustFed = false;
    });
    await _saveState();
  }

  void _recordCompletedDay() {
    if (_missions.isEmpty || _completed != _missions.length) return;
    if (_lastCompletedDate == _todayKey) return;
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    _streak = _lastCompletedDate == yesterday ? _streak + 1 : 1;
    _lastCompletedDate = _todayKey;
    _completedDatesHistory.add(_todayKey);
    _adventureDaysCompleted += 1;
  }

  int get _completed => _missions.where((mission) => mission.done).length;

  Future<void> _addMission() async {
    final draft = await _showMissionEditor();
    if (draft == null) return;
    setState(() {
      _missions.add(
        Mission(
          draft.title,
          draft.subtitle,
          draft.categoryAsset ??
              MissionCategoryAssets.inferFromText(draft.title),
          draft.color ?? const Color(0xFFE58BA5),
        ),
      );
      _pinJustFed = false;
    });
    await _saveState();
  }

  Future<MissionDraft?> _showMissionEditor({Mission? mission}) {
    return showModalBottomSheet<MissionDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MissionEditorSheet(mission: mission),
    );
  }

  Future<void> _editMission(int index) async {
    final mission = _missions[index];
    final draft = await _showMissionEditor(mission: mission);
    if (draft == null) return;
    setState(() {
      mission
        ..title = draft.title
        ..subtitle = draft.subtitle
        ..categoryAsset =
            draft.categoryAsset ??
            MissionCategoryAssets.inferFromText(draft.title)
        ..color = draft.color ?? mission.color;
    });
    await _saveState();
  }

  Future<void> _deleteMission(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar misión'),
        content: Text(
          '¿Eliminar “${_missions[index].title}” de todos los días?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    setState(() => _missions.removeAt(index));
    await _saveState();
  }

  void _toggleMission(int index) {
    final mission = _missions[index];
    var rewardGranted = false;
    setState(() {
      mission.done = !mission.done;
      if (mission.done &&
          _dailyRewardsEarned + _rewardPerMission <= _maxDailyReward) {
        mission.rewardedToday = true;
        _dailyRewardsEarned += _rewardPerMission;
        _coins += _rewardPerMission;
        _totalCoinsEarned += _rewardPerMission;
        rewardGranted = true;
      } else if (!mission.done && mission.rewardedToday) {
        mission.rewardedToday = false;
        _dailyRewardsEarned -= _rewardPerMission;
        _coins -= _rewardPerMission;
      }
      _pinJustFed = false;
      _recordCompletedDay();
    });
    _saveState();
    if (mission.done) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E493E),
          content: _RewardSnackContent(
            rewardGranted: rewardGranted,
            rewardAmount: _rewardPerMission,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      if (_missions.isNotEmpty && _completed == _missions.length) {
        _showDayConqueredCelebration();
      }
    }
  }

  void _showDayConqueredCelebration() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCF6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAD3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(
              GrapaAssets.celebrating,
              height: 130,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            const Text(
              '¡Día conquistado!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Has completado todas tus misiones de hoy.\nSaca Grapas ha sido derrotado y tu racha sigue activa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF81786C),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '¡Continuar la aventura!',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyShopItem(_ShopPreviewItem item) async {
    if (_purchasedItems.contains(item.id)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ya posees ${item.name}.')));
      return;
    }
    if (_coins < item.price) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitas ${item.price - _coins} monedas más para comprar ${item.name}.',
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _coins -= item.price;
      _purchasedItems.add(item.id);
      if (item.equippedAssetPath != null) {
        _equippedGrapaAsset = item.equippedAssetPath!;
      }
      _pinJustFed = false;
    });
    await _saveState();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '¡Artículo adquirido!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              item.assetPath,
              width: 74,
              height: 74,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              '¡${item.name} ahora es parte de tu colección!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (item.equippedAssetPath != null) ...[
              const SizedBox(height: 6),
              const Text(
                'Ha sido equipado en Grapa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7656D6),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('¡Genial!'),
            ),
          ),
        ],
      ),
    );
  }

  void _openFocusDuel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FocusDuelSheet(
        missions: _missions,
        onCompleteDuel: (minutes, mission) {
          _completeFocusDuel(minutes: minutes, mission: mission);
        },
      ),
    );
  }

  void _completeFocusDuel({required int minutes, Mission? mission}) {
    HapticFeedback.heavyImpact();
    setState(() {
      _coins += 15;
      _totalCoinsEarned += 15;
      if (mission != null && !mission.done) {
        final idx = _missions.indexOf(mission);
        if (idx != -1) {
          _toggleMission(idx);
        }
      }
    });
    _saveState();
  }

  void _openUpgradeWorkshop() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UpgradeWorkshopSheet(
        coins: _coins,
        streakShields: _streakShields,
        purchasedUpgrades: _purchasedUpgrades,
        onBuyUpgrade: (id) {
          _buyUpgrade(id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _buyUpgrade(String upgradeId) async {
    int price;
    String name;
    if (upgradeId == 'streak_shield') {
      price = 120;
      name = 'Escudo de Racha';
    } else if (upgradeId == 'coin_magnet') {
      price = 180;
      name = 'Imán de Monedas';
    } else if (upgradeId == 'gourmet_snack') {
      price = 150;
      name = 'Merienda Gourmet de Pin';
    } else {
      return;
    }

    if (upgradeId != 'streak_shield' &&
        _purchasedUpgrades.contains(upgradeId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ya posees la habilidad $name.')));
      return;
    }

    if (_coins < price) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitas ${price - _coins} monedas más para comprar $name.',
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _coins -= price;
      if (upgradeId == 'streak_shield') {
        _streakShields += 1;
      } else {
        _purchasedUpgrades.add(upgradeId);
      }
      _pinJustFed = false;
    });
    await _saveState();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        content: Text('¡$name adquirido exitosamente! ✨'),
      ),
    );
  }

  Future<void> _claimWorldChest() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _coins += 100;
      _totalCoinsEarned += 100;
      _adventureDaysCompleted += 1;
    });
    await _saveState();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '¡Cofre Legendario Abierto!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              EconomyAssets.legendaryChest,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Has conquistado el mundo y obtenido +100 monedas de oro!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('¡Avanzar al siguiente mundo!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            _TodayView(
              missions: _missions,
              completed: _completed,
              coins: _coins,
              streak: _streak,
              dailyRewardsEarned: _dailyRewardsEarned,
              maxDailyReward: _maxDailyReward,
              completedDatesHistory: _completedDatesHistory,
              onToggle: _toggleMission,
              onEdit: _editMission,
              onDelete: _deleteMission,
              onAdd: _addMission,
              onStartFocusDuel: _openFocusDuel,
            ),
            _AdventureView(
              coins: _coins,
              completed: _completed,
              total: _missions.length,
              adventureDaysCompleted: _adventureDaysCompleted,
              onOpenToday: () => setState(() => _tab = 0),
              onClaimWorldChest: _claimWorldChest,
            ),
            _PinView(
              hearts: _pinHearts,
              justFed: _pinJustFed,
              canFeed: _canFeedPin,
              purchasedItems: _purchasedItems,
              onFeed: _feedPin,
            ),
            _ProfileView(
              streak: _streak,
              coins: _coins,
              totalCoinsEarned: _totalCoinsEarned,
              equippedGrapaAsset: _equippedGrapaAsset,
              purchasedItems: _purchasedItems,
              purchasedUpgrades: _purchasedUpgrades,
              streakShields: _streakShields,
              completedDatesHistory: _completedDatesHistory,
              onEquipGrapaAsset: _equipGrapaAsset,
              onBuyItem: _buyShopItem,
              onOpenWorkshop: _openUpgradeWorkshop,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showAds) const _BottomBannerAd(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            backgroundColor: const Color(0xFFFFFCF6),
            indicatorColor: const Color(0xFFE7DDFC),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline_rounded),
                selectedIcon: Icon(Icons.check_circle_rounded),
                label: 'Hoy',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'Aventura',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets_rounded),
                label: 'Pin',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _canFeedPin => !_pinJustFed && _pinHearts < 5 && _coins >= 10;

  void _feedPin() {
    if (_pinJustFed || _pinHearts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pin ya está satisfecho por ahora')),
      );
      return;
    }
    if (_coins < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas 10 monedas para alimentar a Pin'),
        ),
      );
      return;
    }
    final heartsToAdd = _purchasedUpgrades.contains('gourmet_snack') ? 2 : 1;
    HapticFeedback.selectionClick();
    setState(() {
      _coins -= 10;
      _pinHearts = math.min(5, _pinHearts + heartsToAdd);
      _pinJustFed = true;
    });
    _saveState();
  }

  void _equipGrapaAsset(String assetPath) {
    if (!GrapaEquippedAssets.isKnown(assetPath)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _equippedGrapaAsset = assetPath;
      _pinJustFed = false;
    });
    _saveState();
  }
}
