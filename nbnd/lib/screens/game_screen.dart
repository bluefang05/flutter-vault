import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/hud_snapshot.dart';
import '../game/nbnd_game.dart';
import '../game/powers/neuro_power_profile.dart';
import '../l10n/app_localizations.dart';
import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import '../services/app_storage.dart';
import '../widgets/spoon_life_bar.dart';
import '../widgets/top_ad_banner.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.neuroType,
    required this.settings,
    required this.initialBestScore,
  });

  final NeuroType neuroType;
  final GameSettings settings;
  final int initialBestScore;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final AppStorage _storage = AppStorage.instance;
  late final NbndGame _game;
  late int _bestScore = widget.initialBestScore;
  late HudSnapshot _hud;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final NeuroPowerProfile profile = NeuroPowerProfile.forType(
      widget.neuroType,
    );
    _hud = HudSnapshot(
      seconds: 0,
      score: 0,
      stage: 'PULSO',
      abilityCharge: 1,
      resonance: 0,
      spoonHalves: profile.maxSpoonHalves,
      maxSpoonHalves: profile.maxSpoonHalves,
      cleanPasses: 0,
      flowMultiplier: 1,
      breathing: false,
      state: GameRunState.ready,
    );
    _game = NbndGame(
      neuroType: widget.neuroType,
      settings: widget.settings,
      onHudChanged: (HudSnapshot value) {
        if (mounted) setState(() => _hud = value);
      },
      onGameOver: _handleGameOver,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _game.pauseGame();
    }
  }

  Future<void> _handleGameOver(int score) async {
    if (widget.settings.haptics) {
      await HapticFeedback.heavyImpact();
    }
    if (score <= _bestScore) return;
    _bestScore = score;
    await _storage.setInt('best_score', score);
    if (mounted) setState(() {});
  }

  Future<void> _activateAbility() async {
    if (_game.canActivateAbility && widget.settings.haptics) {
      await HapticFeedback.mediumImpact();
    }
    _game.activateAbility();
  }

  void _handlePointerDown(PointerDownEvent event, BoxConstraints constraints) {
    final Offset center = Offset(
      constraints.maxWidth / 2,
      constraints.maxHeight / 2,
    );
    final double activationRadius = (constraints.biggest.shortestSide * .13)
        .clamp(58.0, 92.0)
        .toDouble();
    if ((event.localPosition - center).distance <= activationRadius) {
      _game.stopMoving();
      _activateAbility();
      return;
    }
    final double direction = event.localPosition.dx < constraints.maxWidth / 2
        ? -1
        : 1;
    _game.setMoveDirection(direction);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return PopScope<int>(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, int? result) {
        if (didPop) return;
        Navigator.of(context).pop(result ?? _bestScore);
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            TopAdBanner(visible: widget.settings.showAdPlaceholder),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (PointerDownEvent event) =>
                            _handlePointerDown(event, constraints),
                        onPointerUp: (_) => _game.stopMoving(),
                        onPointerCancel: (_) => _game.stopMoving(),
                        child: GameWidget<NbndGame>(game: _game),
                      ),
                      _Hud(
                        hud: _hud,
                        neuroType: widget.neuroType,
                        bestScore: _bestScore,
                        onPause: _game.pauseGame,
                      ),
                      if (_hud.state == GameRunState.ready)
                        _MessageOverlay(
                          title: widget.neuroType.powerName,
                          message: t.startPrompt,
                          action: t.startPrompt,
                          onPressed: _game.start,
                        ),
                      if (_hud.state == GameRunState.paused)
                        _MessageOverlay(
                          title: t.pauseTitle,
                          message: t.pauseMessage,
                          action: t.resume,
                          onPressed: _game.resumeGame,
                        ),
                      if (_hud.state == GameRunState.gameOver)
                        _MessageOverlay(
                          title: t.gameOverTitle,
                          message: t.scoreLine(_hud.score, _bestScore),
                          action: t.retry,
                          secondaryAction: t.backToMenu,
                          onSecondaryPressed: () {
                            Navigator.of(context).pop(_bestScore);
                          },
                          onPressed: _game.restart,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.hud,
    required this.neuroType,
    required this.bestScore,
    required this.onPause,
  });

  final HudSnapshot hud;
  final NeuroType neuroType;
  final int bestScore;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${neuroType.code} · ${neuroType.powerName}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: neuroType.color),
                        ),
                        Text(
                          t.stageLabel(hud.stage, hud.seconds),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            hud.breathing
                                ? t.breathingMoment
                                : t.flowLine(
                                    hud.cleanPasses,
                                    hud.flowMultiplier,
                                  ),
                            key: ValueKey<String>(
                              '${hud.breathing}-${hud.cleanPasses}',
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: hud.breathing
                                      ? Colors.white70
                                      : neuroType.color,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${hud.score}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${t.record} $bestScore',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SpoonLifeBar(
                currentHalves: hud.spoonHalves,
                maxHalves: hud.maxSpoonHalves,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageOverlay extends StatelessWidget {
  const _MessageOverlay({
    required this.title,
    required this.message,
    required this.action,
    required this.onPressed,
    this.secondaryAction,
    this.onSecondaryPressed,
  });

  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;
  final String? secondaryAction;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: onPressed, child: Text(action)),
                  if (secondaryAction != null &&
                      onSecondaryPressed != null) ...<Widget>[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: onSecondaryPressed,
                      child: Text(secondaryAction!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
