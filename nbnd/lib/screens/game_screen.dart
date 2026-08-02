import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/hud_snapshot.dart';
import '../game/nbnd_game.dart';
import '../game/controls/movement_pointer_tracker.dart';
import '../game/powers/neuro_power_profile.dart';
import '../l10n/app_localizations.dart';
import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import '../services/app_storage.dart';
import '../services/sfx_player.dart';
import '../widgets/spoon_life_bar.dart';
import '../widgets/control_hint_overlay.dart';
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
  final MovementPointerTracker _pointerTracker = MovementPointerTracker();
  bool _showControlHint = true;
  bool _lastRunWasRecord = false;
  double _lastMusicRate = 1;

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
      stage: 'pulse',
      abilityCharge: 1,
      resonance: 0,
      spoonHalves: profile.maxSpoonHalves,
      maxSpoonHalves: profile.maxSpoonHalves,
      cleanPasses: 0,
      flowMultiplier: 1,
      rhythmRate: 1,
      breathing: false,
      recovering: false,
      state: GameRunState.ready,
    );
    _game = NbndGame(
      neuroType: widget.neuroType,
      settings: widget.settings,
      onHudChanged: (HudSnapshot value) {
        _syncMusicRate(value);
        if (mounted) setState(() => _hud = value);
      },
      onGameOver: _handleGameOver,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/gameplay/new_record_badge.png'),
      context,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pointerTracker.clear();
    unawaited(SfxPlayer.instance.setGameMusicRate(1));
    unawaited(SfxPlayer.instance.stopGameMusic());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pointerTracker.clear();
      _game.stopMoving();
      _game.pauseGame();
      unawaited(SfxPlayer.instance.pauseGameMusic());
    }
  }

  Future<void> _handleGameOver(int score) async {
    await SfxPlayer.instance.stopGameMusic();
    await SfxPlayer.instance.setGameMusicRate(1);
    if (widget.settings.haptics) {
      await HapticFeedback.heavyImpact();
    }
    if (score <= _bestScore) return;
    _bestScore = score;
    _lastRunWasRecord = true;
    SfxPlayer.instance.playNewRecord();
    await _storage.setInt('best_score', score);
    if (mounted) setState(() {});
  }

  Future<void> _activateAbility() async {
    final bool activated = _game.activateAbility();
    if (!activated) return;
    unawaited(SfxPlayer.instance.playPowerTap());
    if (widget.settings.haptics) {
      await HapticFeedback.mediumImpact();
    }
  }

  void _syncMusicRate(HudSnapshot value) {
    final double targetRate = widget.neuroType == NeuroType.aacc
        ? value.rhythmRate
        : 1;
    if ((targetRate - _lastMusicRate).abs() < .035) return;
    _lastMusicRate = targetRate;
    unawaited(SfxPlayer.instance.setGameMusicRate(targetRate));
  }

  void _pauseGame() {
    _pointerTracker.clear();
    _game.stopMoving();
    _game.pauseGame();
    unawaited(SfxPlayer.instance.pauseGameMusic());
  }

  void _resumeGame() {
    _game.resumeGame();
    unawaited(SfxPlayer.instance.resumeGameMusic());
  }

  void _restartGame() {
    setState(() => _lastRunWasRecord = false);
    _game.restart();
    unawaited(SfxPlayer.instance.playGameMusic());
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
      _pointerTracker.press(event.pointer, ControlPointerZone.power);
      if (_showControlHint) {
        setState(() => _showControlHint = false);
      }
      if (_hud.state == GameRunState.ready) {
        unawaited(SfxPlayer.instance.playGameMusic());
        _game.start();
      } else {
        _activateAbility();
      }
      return;
    }
    final ControlPointerZone zone =
        event.localPosition.dx < constraints.maxWidth / 2
        ? ControlPointerZone.counterClockwise
        : ControlPointerZone.clockwise;
    _pointerTracker.press(event.pointer, zone);
    if (_showControlHint) {
      setState(() => _showControlHint = false);
    }
    if (_hud.state == GameRunState.ready) {
      unawaited(SfxPlayer.instance.playGameMusic());
    }
    _game.setMoveDirection(_pointerTracker.movementDirection);
  }

  void _handlePointerEnd(int pointerId) {
    _pointerTracker.release(pointerId);
    final double direction = _pointerTracker.movementDirection;
    if (direction == 0) {
      _game.stopMoving();
    } else {
      _game.setMoveDirection(direction);
    }
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
            const TopAdBanner(),
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
                        onPointerUp: (PointerUpEvent event) =>
                            _handlePointerEnd(event.pointer),
                        onPointerCancel: (PointerCancelEvent event) =>
                            _handlePointerEnd(event.pointer),
                        child: GameWidget<NbndGame>(game: _game),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: _showControlHint
                            ? ControlHintOverlay(
                                key: const ValueKey<String>('control-hint'),
                                counterClockwise: t.counterClockwise,
                                clockwise: t.clockwise,
                                touchAndHold: t.touchAndHold,
                                powerAction: t.powerAction,
                                touchCenter: t.touchCenter,
                                centerRadius:
                                    (constraints.biggest.shortestSide * .13)
                                        .clamp(58.0, 92.0)
                                        .toDouble(),
                                reducedFlashes: widget.settings.reducedFlashes,
                              )
                            : const SizedBox.shrink(
                                key: ValueKey<String>('control-hint-hidden'),
                              ),
                      ),
                      _Hud(
                        hud: _hud,
                        neuroType: widget.neuroType,
                        bestScore: _bestScore,
                        onPause: _pauseGame,
                      ),
                      if (_hud.state == GameRunState.paused)
                        _MessageOverlay(
                          title: t.pauseTitle,
                          message: t.pauseMessage,
                          action: t.resume,
                          onPressed: _resumeGame,
                        ),
                      if (_hud.state == GameRunState.gameOver)
                        _MessageOverlay(
                          title: t.gameOverTitle,
                          message: t.scoreLine(_hud.score, _bestScore),
                          highlight: _lastRunWasRecord
                              ? t.newRecordTitle
                              : null,
                          recordBadgeAsset: _lastRunWasRecord
                              ? 'assets/images/gameplay/new_record_badge.png'
                              : null,
                          action: t.retry,
                          secondaryAction: t.backToMenu,
                          onSecondaryPressed: () {
                            Navigator.of(context).pop(_bestScore);
                          },
                          onPressed: _restartGame,
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
                          '${neuroType.code} · ${t.powerName(neuroType)}',
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
    this.highlight,
    this.recordBadgeAsset,
    this.secondaryAction,
    this.onSecondaryPressed,
  });

  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;
  final String? highlight;
  final String? recordBadgeAsset;
  final String? secondaryAction;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1.08,
          colors: <Color>[Color(0xB0090A12), Color(0xE8050610)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Card(
            color: const Color(0xF20B0E18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (highlight != null) ...<Widget>[
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: .82, end: 1),
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.elasticOut,
                      builder:
                          (BuildContext context, double scale, Widget? child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (recordBadgeAsset != null)
                            Image.asset(
                              recordBadgeAsset!,
                              height: 124,
                              fit: BoxFit.contain,
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFFFD45C),
                                  Color(0xFFFF8A5C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD45C,
                                  ).withValues(alpha: .26),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Color(0xFF1B1320),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    highlight!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: const Color(0xFF1B1320),
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .7,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: .78),
                    ),
                  ),
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
