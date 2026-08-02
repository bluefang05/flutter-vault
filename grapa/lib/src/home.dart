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
  static const _rewardPerMission = 10;
  static const _maxDailyMissionRewards = 5;
  static const _maxDailyReward = _rewardPerMission * _maxDailyMissionRewards;
  int _tab = 0;
  int _coins = 50;
  int _totalCoinsEarned = 50;
  int _streak = 0;
  int _pinHearts = 3;
  int _dailyRewardsEarned = 0;
  bool _pinJustFed = false;
  String _equippedGrapaAsset = GrapaEquippedAssets.dressPremium;
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
      final savedGrapaAsset = preferences.getString(_equippedGrapaAssetKey);
      _equippedGrapaAsset =
          savedGrapaAsset != null &&
              GrapaEquippedAssets.isKnown(savedGrapaAsset)
          ? savedGrapaAsset
          : GrapaEquippedAssets.dressPremium;
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
      if (_lastCompletedDate != null)
        preferences.setString(_lastCompletedDateKey, _lastCompletedDate!),
    ]);
  }

  Future<void> _rollOverDayIfNeeded() async {
    final today = _todayKey;
    if (today == _activeDate || !mounted) return;
    setState(() {
      for (final mission in _missions) {
        mission
          ..done = false
          ..rewardedToday = false;
      }
      _dailyRewardsEarned = 0;
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
          MissionCategoryAssets.inferFromText(draft.title),
          const Color(0xFFE58BA5),
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
        ..categoryAsset = MissionCategoryAssets.inferFromText(draft.title);
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
    }
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
              onToggle: _toggleMission,
              onEdit: _editMission,
              onDelete: _deleteMission,
              onAdd: _addMission,
            ),
            _AdventureView(
              coins: _coins,
              completed: _completed,
              total: _missions.length,
              onOpenToday: () => setState(() => _tab = 0),
            ),
            _PinView(
              hearts: _pinHearts,
              justFed: _pinJustFed,
              canFeed: _canFeedPin,
              onFeed: _feedPin,
            ),
            _ProfileView(
              streak: _streak,
              coins: _coins,
              totalCoinsEarned: _totalCoinsEarned,
              equippedGrapaAsset: _equippedGrapaAsset,
              onEquipGrapaAsset: _equipGrapaAsset,
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
    setState(() {
      _coins -= 10;
      _pinHearts = math.min(5, _pinHearts + 1);
      _pinJustFed = true;
    });
    _saveState();
  }

  void _equipGrapaAsset(String assetPath) {
    if (!GrapaEquippedAssets.isKnown(assetPath)) return;
    setState(() {
      _equippedGrapaAsset = assetPath;
      _pinJustFed = false;
    });
    _saveState();
  }
}
