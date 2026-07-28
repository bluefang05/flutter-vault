import 'package:flutter/material.dart';

import '../game/powers/neuro_power_profile.dart';
import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import '../l10n/app_localizations.dart';
import '../services/app_storage.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppStorage _storage = AppStorage.instance;
  NeuroType _selected = NeuroType.tdah;
  GameSettings _settings = const GameSettings();
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final NeuroType selected =
        NeuroType.fromCode(await _storage.getString('selected_neuro'));
    final int bestScore = await _storage.getInt('best_score') ?? 0;
    final GameSettings settings = GameSettings(
      haptics: await _storage.getBool('haptics') ?? true,
      reducedFlashes: await _storage.getBool('reduced_flashes') ?? false,
      practiceMode: await _storage.getBool('practice_mode') ?? false,
      showAdPlaceholder: await _storage.getBool('show_ad_placeholder') ?? true,
    );
    if (!mounted) return;
    setState(() {
      _selected = selected;
      _bestScore = bestScore;
      _settings = settings;
    });
  }

  Future<void> _select(NeuroType type) async {
    setState(() => _selected = type);
    await _storage.setString('selected_neuro', type.code);
  }

  Future<void> _openSettings() async {
    final GameSettings? updated = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute<GameSettings>(
        builder: (BuildContext context) => SettingsScreen(settings: _settings),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _settings = updated);
    }
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
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.homeSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Row(
                            children: <Widget>[
                              Chip(label: Text('Récord: $_bestScore')),
                              const SizedBox(width: 8),
                              if (_settings.practiceMode)
                                const Chip(label: Text('Práctica')),
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
                child: Text(
                  t.choosePower,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: NeuroType.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final NeuroType type = NeuroType.values[index];
                  final NeuroPowerProfile profile =
                      NeuroPowerProfile.forType(type);
                  final bool selected = type == _selected;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _select(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? type.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: type.color.withValues(alpha: .16),
                              foregroundColor: type.color,
                              child: Text(type.code.substring(0, 1)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${type.code} · ${type.powerName}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    type.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${t.initialReserve}: '
                                    '${profile.maxSpoonHalves ~/ 2} cucharas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: type.color),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected ? type.color : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('${t.play} con ${_selected.code}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
