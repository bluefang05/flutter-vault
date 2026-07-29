import 'package:flutter/material.dart';

import '../game/powers/neuro_power_profile.dart';
import '../l10n/app_localizations.dart';
import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import '../services/app_storage.dart';
import '../widgets/neuro_profile_icon.dart';
import 'game_screen.dart';
import 'profile_info_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppStorage _storage = AppStorage.instance;
  late final PageController _powerController;
  NeuroType _selected = NeuroType.tdah;
  GameSettings _settings = const GameSettings();
  int _bestScore = 0;
  bool _assetsPrecached = false;

  @override
  void initState() {
    super.initState();
    _powerController = PageController(viewportFraction: .88);
    _loadPreferences();
  }

  @override
  void dispose() {
    _powerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsPrecached) return;
    _assetsPrecached = true;
    precacheImage(
      const AssetImage('assets/images/character_placeholder.png'),
      context,
    );
    for (final String spoonAsset in const <String>[
      'assets/images/spoons/spoon_full.png',
      'assets/images/spoons/spoon_half.png',
      'assets/images/spoons/spoon_empty.png',
    ]) {
      precacheImage(AssetImage(spoonAsset), context);
    }
    for (final NeuroType type in NeuroType.values) {
      precacheImage(AssetImage(type.iconAsset), context);
    }
  }

  Future<void> _loadPreferences() async {
    final NeuroType selected = NeuroType.fromCode(
      await _storage.getString('selected_neuro'),
    );
    final int bestScore = await _storage.getInt('best_score') ?? 0;
    final GameSettings settings = GameSettings(
      haptics: await _storage.getBool('haptics') ?? true,
      reducedFlashes: await _storage.getBool('reduced_flashes') ?? false,
      practiceMode: await _storage.getBool('practice_mode') ?? false,
    );
    if (!mounted) return;
    setState(() {
      _selected = selected;
      _bestScore = bestScore;
      _settings = settings;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_powerController.hasClients) return;
      _powerController.jumpToPage(NeuroType.values.indexOf(selected));
    });
  }

  Future<void> _select(NeuroType type) async {
    if (type == _selected) return;
    setState(() => _selected = type);
    await _storage.setString('selected_neuro', type.code);
  }

  Future<void> _openSettings() async {
    final GameSettings? updated = await Navigator.of(context)
        .push<GameSettings>(
          MaterialPageRoute<GameSettings>(
            builder: (BuildContext context) =>
                SettingsScreen(settings: _settings),
          ),
        );
    if (updated != null && mounted) {
      setState(() => _settings = updated);
    }
  }

  Future<void> _openProfileInfo([NeuroType? initialType]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ProfileInfoScreen(initialType: initialType ?? _selected),
      ),
    );
  }

  Future<void> _startGame() async {
    final int? result = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (BuildContext context) => GameScreen(
          neuroType: _selected,
          settings: _settings,
          initialBestScore: _bestScore,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result > _bestScore) {
      setState(() => _bestScore = result);
    } else {
      await _loadPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            t.appTitle,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.homeSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _openSettings,
                      tooltip: t.settings,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/character_placeholder.png',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -.22),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Color(0xD9090A12),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: .92,
                                        end: 1,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                            child: NeuroProfileIcon(
                              key: ValueKey<NeuroType>(_selected),
                              neuroType: _selected,
                              size: 62,
                              selected: true,
                              borderColor: _selected.color,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Row(
                            children: <Widget>[
                              Chip(label: Text('${t.record}: $_bestScore')),
                              const SizedBox(width: 8),
                              if (_settings.practiceMode)
                                Chip(label: Text(t.practiceMode)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        t.choosePower,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      key: const ValueKey<String>('learn-profiles-home'),
                      onPressed: () => _openProfileInfo(),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: Text(t.learnProfiles),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 212,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PageView.builder(
                      controller: _powerController,
                      itemCount: NeuroType.values.length,
                      onPageChanged: (int index) =>
                          _select(NeuroType.values[index]),
                      itemBuilder: (BuildContext context, int index) {
                        final NeuroType type = NeuroType.values[index];
                        final NeuroPowerProfile profile =
                            NeuroPowerProfile.forType(type);
                        final bool selected = type == _selected;
                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.fromLTRB(
                            8,
                            selected ? 0 : 12,
                            8,
                            selected ? 0 : 12,
                          ),
                          child: _PowerCard(
                            type: type,
                            profile: profile,
                            selected: selected,
                            initialReserveLabel: t.initialReserve,
                            recommendedStartLabel: t.recommendedStart,
                            onInfo: () => _openProfileInfo(type),
                            onTap: () => _select(type),
                          ),
                        );
                      },
                    ),
                    const Positioned(
                      left: 8,
                      child: _SwipeHint(
                        color: Color(0xFFFF6E9A),
                        icon: Icons.chevron_left_rounded,
                      ),
                    ),
                    const Positioned(
                      right: 8,
                      child: _SwipeHint(
                        color: Color(0xFF55E6C1),
                        icon: Icons.chevron_right_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(t.playWith(_selected.code)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerCard extends StatelessWidget {
  const _PowerCard({
    required this.type,
    required this.profile,
    required this.selected,
    required this.initialReserveLabel,
    required this.recommendedStartLabel,
    required this.onInfo,
    required this.onTap,
  });

  final NeuroType type;
  final NeuroPowerProfile profile;
  final bool selected;
  final String initialReserveLabel;
  final String recommendedStartLabel;
  final VoidCallback onInfo;
  final VoidCallback onTap;

  bool get _recommendedStart => type == NeuroType.tdah || type == NeuroType.tag;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? type.color : Colors.transparent,
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                type.color.withValues(alpha: .24),
                const Color(0xFF090A12),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 72),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    NeuroProfileIcon(
                      neuroType: type,
                      size: 58,
                      selected: selected,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).neuroTypeName(type),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context).powerName(type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(color: type.color),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context).neuroDescription(type),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$initialReserveLabel: ${AppLocalizations.of(context).spoonsCount(profile.maxSpoonHalves ~/ 2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: type.color),
                          ),
                          if (_recommendedStart) ...<Widget>[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: type.color.withValues(alpha: .14),
                                  border: Border.all(
                                    color: type.color.withValues(alpha: .45),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    recommendedStartLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: type.color,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      key: ValueKey<String>('profile-info-${type.code}'),
                      visualDensity: VisualDensity.compact,
                      tooltip: AppLocalizations.of(context).learnProfiles,
                      onPressed: onInfo,
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: selected ? type.color : Colors.white60,
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.swipe_rounded,
                      color: selected ? type.color : Colors.white54,
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

class _SwipeHint extends StatefulWidget {
  const _SwipeHint({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
      lowerBound: .35,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: .20),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color, width: 1.5),
        ),
        child: Icon(widget.icon, color: widget.color, size: 34),
      ),
    );
  }
}
