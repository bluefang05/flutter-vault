import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import 'game_math.dart';
import 'hud_snapshot.dart';
import 'models/collision_result.dart';
import 'models/obstacle_ring.dart';
import 'models/spoon_orb.dart';
import 'powers/neuro_power_profile.dart';
import 'rewind_helpers.dart';

class NbndGame extends FlameGame {
  NbndGame({
    required this.neuroType,
    required this.settings,
    required this.onHudChanged,
    required this.onGameOver,
  }) : profile = NeuroPowerProfile.forType(neuroType) {
    _spoonHalves = profile.maxSpoonHalves;
    _orbSpawnTimer = _nextOrbDelay;
  }

  final NeuroType neuroType;
  final GameSettings settings;
  final NeuroPowerProfile profile;
  final ValueChanged<HudSnapshot> onHudChanged;
  final ValueChanged<int> onGameOver;

  final math.Random _random = math.Random();
  final List<ObstacleRing> _rings = <ObstacleRing>[];
  final List<SpoonOrb> _spoonOrbs = <SpoonOrb>[];
  final Queue<_GameSnapshot> _history = Queue<_GameSnapshot>();

  GameRunState _state = GameRunState.ready;
  double _elapsed = 0;
  double _spawnTimer = .8;
  double _hudTimer = 0;
  double _playerAngle = -math.pi / 2;
  double _moveDirection = 0;
  double _abilityCooldownRemaining = 0;
  double _slowUntil = 0;
  double _freezeRotationUntil = 0;
  double _powerImmunityUntil = 0;
  double _damageGraceUntil = 0;
  double _controlLockedUntil = 0;
  double _resonance = 0;
  double _snapshotTimer = 0;
  double _lastGap = -math.pi / 2;
  double _hitFlashUntil = 0;
  double _shakeUntil = 0;
  double _shakeStrength = 0;
  double _pressureReliefUntil = 0;
  double _orbRecoveryUntil = 0;
  double _abilityFeedbackUntil = 0;
  double _rewindFeedbackUntil = 0;
  late double _orbSpawnTimer;
  int _sequenceIndex = 0;
  int _cleanPasses = 0;
  int _scoreBonus = 0;
  late int _spoonHalves;
  ui.Image? _powerIcon;
  bool _gameOverSent = false;

  double get _playerRadius => math.min(size.x, size.y) * .19;
  double get _playerHalfAngle => .24;
  double get _outerSpawnRadius => math.max(size.x, size.y) * .68;
  double get _minimumRingSeparation => math.max(92, _playerRadius * 1.35);
  int get score => (_elapsed * 100).floor() + _scoreBonus;
  List<ObstacleRing> get _tocCandidates => _rings
      .where(
        (ObstacleRing ring) =>
            !ring.resolved &&
            ring.radius + ring.thickness / 2 >= _playerRadius - 18,
      )
      .toList(growable: false);
  bool get _abilityHasEffect => abilityHasEffect(
    neuroType: neuroType,
    targetCount: neuroType == NeuroType.toc
        ? _tocCandidates.length
        : _rings.where((ObstacleRing ring) => !ring.resolved).length,
    historyCount: _history.length,
  );
  bool get canActivateAbility =>
      _state == GameRunState.running &&
      _abilityCooldownRemaining <= 0 &&
      _abilityHasEffect;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _powerIcon = await images.load(neuroType.flameIconAsset);
  }

  void start() {
    _state = GameRunState.running;
    _emitHud(force: true);
  }

  void restart() {
    _rings.clear();
    _spoonOrbs.clear();
    _history.clear();
    _state = GameRunState.running;
    _elapsed = 0;
    _spawnTimer = .75;
    _playerAngle = -math.pi / 2;
    _moveDirection = 0;
    _abilityCooldownRemaining = 0;
    _slowUntil = 0;
    _freezeRotationUntil = 0;
    _powerImmunityUntil = 0;
    _damageGraceUntil = 0;
    _controlLockedUntil = 0;
    _resonance = 0;
    _lastGap = -math.pi / 2;
    _hitFlashUntil = 0;
    _shakeUntil = 0;
    _shakeStrength = 0;
    _pressureReliefUntil = 0;
    _orbRecoveryUntil = 0;
    _abilityFeedbackUntil = 0;
    _rewindFeedbackUntil = 0;
    _orbSpawnTimer = _nextOrbDelay;
    _sequenceIndex = 0;
    _cleanPasses = 0;
    _scoreBonus = 0;
    _spoonHalves = profile.maxSpoonHalves;
    _gameOverSent = false;
    _emitHud(force: true);
  }

  void pauseGame() {
    if (_state == GameRunState.running) {
      _state = GameRunState.paused;
      pauseEngine();
      _emitHud(force: true);
    }
  }

  void resumeGame() {
    if (_state == GameRunState.paused) {
      _state = GameRunState.running;
      resumeEngine();
      _emitHud(force: true);
    }
  }

  void setMoveDirection(double value) {
    _moveDirection = value.clamp(-1.0, 1.0).toDouble();
    if (_state == GameRunState.ready) {
      start();
    }
  }

  void stopMoving() {
    _moveDirection = 0;
  }

  bool activateAbility() {
    if (!canActivateAbility) {
      return false;
    }

    bool activated = true;
    switch (neuroType) {
      case NeuroType.tdah:
        _slowUntil = _elapsed + 2.4;
        break;
      case NeuroType.tea:
        _freezeRotationUntil = _elapsed + 3;
        break;
      case NeuroType.tlp:
        for (final ObstacleRing ring in _rings) {
          ring.radius += 82 + (_resonance * 38);
        }
        _resonance = 0;
        break;
      case NeuroType.tid:
        _playerAngle = normalizeAngle(_playerAngle + math.pi);
        _powerImmunityUntil = _elapsed + .65;
        break;
      case NeuroType.toc:
        final List<ObstacleRing> candidates = _tocCandidates;
        if (candidates.isNotEmpty) {
          final ObstacleRing nearest = candidates.reduce(
            (ObstacleRing a, ObstacleRing b) =>
                (a.radius - _playerRadius).abs() <
                    (b.radius - _playerRadius).abs()
                ? a
                : b,
          );
          nearest.gapCenters[0] = _playerAngle;
          nearest.gapWidth = math.max(nearest.gapWidth, math.pi / 2.7);
        }
        break;
      case NeuroType.alexitimia:
        _slowUntil = _elapsed + 1.8;
        _powerImmunityUntil = _elapsed + .9;
        break;
      case NeuroType.anhedonia:
        _powerImmunityUntil = _elapsed + 3.5;
        break;
      case NeuroType.tag:
        activated = _rewindOneSecond();
        if (activated) {
          _powerImmunityUntil = _elapsed + .35;
        }
        break;
    }

    if (!activated) return false;
    _abilityCooldownRemaining = profile.cooldown;
    _abilityFeedbackUntil = _elapsed + .42;
    _emitHud(force: true);
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state != GameRunState.running || size.x <= 0 || size.y <= 0) {
      return;
    }

    const double maxFrameDt = .25;
    const double maxStepDt = 1 / 120;
    final double boundedDt = dt.clamp(0.0, maxFrameDt).toDouble();
    final int steps = math.max(1, (boundedDt / maxStepDt).ceil());
    final double stepDt = boundedDt / steps;
    for (int step = 0; step < steps; step++) {
      _updateStep(stepDt);
      if (_state != GameRunState.running) break;
    }
    _emitHud();
  }

  void _updateStep(double dt) {
    final double practiceFactor = settings.practiceMode ? .72 : 1;
    final bool slowed = _elapsed < _slowUntil;
    final double worldScale = slowed ? .42 : 1;
    final double gameDt = dt * practiceFactor;
    final double worldDt = gameDt * worldScale;

    _elapsed += gameDt;
    _abilityCooldownRemaining = math.max(0, _abilityCooldownRemaining - gameDt);
    if (_elapsed >= _controlLockedUntil) {
      _playerAngle = normalizeAngle(
        _playerAngle + _moveDirection * profile.playerSpeed * gameDt,
      );
    }

    _spawnTimer -= worldDt;
    if (_spawnTimer <= 0) {
      if (_canSpawnRing) {
        _spawnRing();
        _spawnTimer = _spawnInterval;
      } else {
        _spawnTimer = .08;
      }
    }

    final bool freezeRotation = _elapsed < _freezeRotationUntil;
    bool automaticRewindRequested = false;
    for (final ObstacleRing ring in _rings) {
      ring.update(worldDt, freezeRotation: freezeRotation);
      if (_checkCollision(ring)) {
        automaticRewindRequested = true;
        break;
      }
      _markResolved(ring);
    }
    if (automaticRewindRequested && _rewindOneSecond()) {
      _abilityCooldownRemaining = profile.cooldown;
      _powerImmunityUntil = _elapsed + .35;
      _rewindFeedbackUntil = _elapsed + .55;
      _emitHud(force: true);
      return;
    }
    _rings.removeWhere((ObstacleRing ring) => ring.resolved);

    _orbSpawnTimer -= gameDt;
    if (_orbSpawnTimer <= 0) {
      _spawnSpoonOrb();
      _orbSpawnTimer = _nextOrbDelay;
    }
    for (final SpoonOrb orb in _spoonOrbs) {
      orb.update(worldDt);
      _checkOrbCollection(orb);
      if (orb.radius < _playerRadius * .35) {
        orb.resolved = true;
      }
    }
    _spoonOrbs.removeWhere((SpoonOrb orb) => orb.resolved);

    _recordHistory(gameDt);
    _hudTimer += gameDt;
  }

  double get _difficulty {
    final double raw = 1 + (_elapsed / 32);
    final double practice = settings.practiceMode ? .78 : 1;
    final double recovery = _elapsed < _pressureReliefUntil ? .84 : 1;
    return raw * practice * recovery;
  }

  double get _spawnInterval {
    final double base = math.max(.52, 1.38 - (_elapsed * .008));
    return _isBreathing ? base * 1.65 : base;
  }

  // A short low-pressure window lets attention reset without stopping play.
  bool get _isBreathing {
    if (_elapsed < 12) return false;
    final double cycle = _elapsed % 20;
    return cycle >= 16 && cycle < 19;
  }

  double get _nextOrbDelay => 18 + _random.nextDouble() * 10;

  bool get _canSpawnRing => hasMinimumRingSeparation(
    spawnRadius: _outerSpawnRadius,
    existingRadii: _rings
        .where((ObstacleRing ring) => !ring.resolved)
        .map((ObstacleRing ring) => ring.radius),
    minimumSeparation: _minimumRingSeparation,
  );

  String get _stage {
    if (_elapsed < 20) return 'pulse';
    if (_elapsed < 45) return 'resonance';
    return 'fracture';
  }

  void _spawnRing() {
    final double gapWidth = math.max(
      math.pi / 5.5,
      profile.baseGapWidth - (_elapsed * .0016),
    );

    final List<double> gaps = <double>[];
    if (neuroType == NeuroType.toc) {
      final double step = math.pi / 3;
      _lastGap = normalizeAngle(-math.pi / 2 + (_sequenceIndex * step));
      _sequenceIndex = (_sequenceIndex + 1) % 6;
    } else if (neuroType == NeuroType.tea) {
      final bool repeatPattern = _random.nextDouble() < .7;
      if (!repeatPattern) {
        _lastGap = normalizeAngle(
          _lastGap + (_random.nextBool() ? math.pi / 3 : -math.pi / 3),
        );
      }
    } else {
      final double randomAngle = _random.nextDouble() * math.pi * 2;
      _lastGap = normalizeAngle(
        _lastGap * (1 - profile.patternRandomness) +
            randomAngle * profile.patternRandomness,
      );
    }

    gaps.add(_lastGap);
    if (neuroType == NeuroType.tid) {
      gaps.add(normalizeAngle(_lastGap + math.pi));
    }

    final double direction = _random.nextBool() ? 1 : -1;
    _rings.add(
      ObstacleRing(
        radius: _outerSpawnRadius,
        thickness: 15,
        gapCenters: gaps,
        gapWidth: gapWidth,
        inwardSpeed: 72 * _difficulty,
        rotationSpeed: direction * (.18 + _difficulty * .06),
        preview: neuroType == NeuroType.tea || neuroType == NeuroType.tag,
      ),
    );
  }

  void _spawnSpoonOrb() {
    final double direction = _random.nextBool() ? 1 : -1;
    _spoonOrbs.add(
      SpoonOrb(
        radius: _outerSpawnRadius,
        angle: _random.nextDouble() * math.pi * 2,
        inwardSpeed: 54 * math.min(_difficulty, 1.65),
        angularSpeed: direction * (.10 + _random.nextDouble() * .08),
      ),
    );
  }

  void _checkOrbCollection(SpoonOrb orb) {
    if (orb.resolved) return;
    final double distance = polarDistance(
      firstRadius: _playerRadius,
      firstAngle: _playerAngle,
      secondRadius: orb.radius,
      secondAngle: orb.angle,
    );
    if (distance > 23) return;

    final int previousHalves = _spoonHalves;
    _spoonHalves = recoverSpoonHalf(
      currentHalves: _spoonHalves,
      maxHalves: profile.maxSpoonHalves,
    );
    _scoreBonus += _spoonHalves > previousHalves ? 120 : 40;
    _orbRecoveryUntil = _elapsed + 1.1;
    orb.resolved = true;
    if (settings.haptics) {
      HapticFeedback.lightImpact();
    }
    _emitHud(force: true);
  }

  bool _checkCollision(ObstacleRing ring) {
    if (ring.checkedCollision || ring.resolved) {
      return false;
    }
    final RingCollisionAssessment assessment = assessRingCollision(
      previousRadius: ring.previousRadius,
      currentRadius: ring.radius,
      ringThickness: ring.thickness,
      playerRadius: _playerRadius,
      playerRadialHalfSize: 12,
      playerAngle: _playerAngle,
      playerHalfAngle: _playerHalfAngle,
      gapCenters: ring.gapCenters,
      gapWidth: ring.gapWidth,
    );
    final RingResolution resolution = resolveRingContact(
      assessment: assessment,
      alreadyProcessed: ring.checkedCollision,
      powerImmune: _elapsed < _powerImmunityUntil,
      damageGrace: _elapsed < _damageGraceUntil,
    );
    if (!resolution.processed) return false;

    final bool damaging =
        resolution.outcome == RingOutcome.lightHit ||
        resolution.outcome == RingOutcome.strongHit;
    if (damaging &&
        neuroType == NeuroType.tag &&
        _abilityCooldownRemaining <= 0 &&
        hasSufficientRewindHistory(_history.length)) {
      return true;
    }

    ring.checkedCollision = true;
    if (resolution.awardsCleanPass) {
      if (resolution.nearMiss) {
        _resonance = math.min(1, _resonance + .22);
      }
      _registerCleanPass(nearMiss: resolution.nearMiss);
      if (resolution.outcome == RingOutcome.powerProtected) {
        _abilityFeedbackUntil = math.max(_abilityFeedbackUntil, _elapsed + .22);
      }
      return false;
    }
    if (!damaging) return false;

    _applyHitDamage(resolution.damageHalves);
    _triggerHitFeedback(resolution.outcome == RingOutcome.strongHit);
    if (_spoonHalves > 0) return false;

    _state = GameRunState.gameOver;
    _moveDirection = 0;
    _emitHud(force: true);
    if (!_gameOverSent) {
      _gameOverSent = true;
      onGameOver(score);
    }
    return false;
  }

  void _applyHitDamage(int halves) {
    _spoonHalves = spoonHalvesAfterDamage(
      currentHalves: _spoonHalves,
      damageHalves: halves,
    );
    _cleanPasses = 0;
    _pressureReliefUntil = _elapsed + 4;
    _damageGraceUntil = _elapsed + .55;
    _controlLockedUntil = _elapsed + .12;
    _emitHud(force: true);
  }

  void _triggerHitFeedback(bool strongHit) {
    if (!settings.reducedFlashes) {
      _hitFlashUntil = _elapsed + .22;
    }
    _shakeUntil = _elapsed + (strongHit ? .38 : .26);
    _shakeStrength = strongHit ? 8 : 5;
    if (settings.haptics) {
      HapticFeedback.mediumImpact();
    }
  }

  void _registerCleanPass({required bool nearMiss}) {
    _cleanPasses += 1;
    _scoreBonus += cleanPassReward(_cleanPasses, nearMiss: nearMiss);
    if (nearMiss && settings.haptics) {
      HapticFeedback.selectionClick();
    }
    _emitHud(force: true);
  }

  void _markResolved(ObstacleRing ring) {
    if (ring.resolved) return;
    if (ring.radius + ring.thickness / 2 < _playerRadius - 18) {
      ring.resolved = true;
    }
  }

  void _recordHistory(double dt) {
    if (neuroType != NeuroType.tag) return;
    _snapshotTimer += dt;
    if (_snapshotTimer < .1) return;
    _snapshotTimer = 0;
    _history.add(
      _GameSnapshot(
        elapsed: _elapsed,
        playerAngle: _playerAngle,
        spoonHalves: _spoonHalves,
        scoreBonus: _scoreBonus,
        cleanPasses: _cleanPasses,
        resonance: _resonance,
        spawnTimer: _spawnTimer,
        orbSpawnTimer: _orbSpawnTimer,
        abilityCooldownRemaining: _abilityCooldownRemaining,
        powerImmunityUntil: _powerImmunityUntil,
        damageGraceUntil: _damageGraceUntil,
        pressureReliefUntil: _pressureReliefUntil,
        lastGap: _lastGap,
        sequenceIndex: _sequenceIndex,
        rings: _rings
            .map(
              (ObstacleRing ring) => _RingSnapshot(
                radius: ring.radius,
                previousRadius: ring.previousRadius,
                thickness: ring.thickness,
                gapCenters: List<double>.from(ring.gapCenters),
                gapWidth: ring.gapWidth,
                inwardSpeed: ring.inwardSpeed,
                rotationSpeed: ring.rotationSpeed,
                preview: ring.preview,
                checkedCollision: ring.checkedCollision,
                resolved: ring.resolved,
              ),
            )
            .toList(growable: false),
        orbs: _spoonOrbs
            .map(
              (SpoonOrb orb) => _OrbSnapshot(
                radius: orb.radius,
                angle: orb.angle,
                inwardSpeed: orb.inwardSpeed,
                angularSpeed: orb.angularSpeed,
                resolved: orb.resolved,
              ),
            )
            .toList(growable: false),
      ),
    );
    while (_history.length > 12) {
      _history.removeFirst();
    }
  }

  bool _rewindOneSecond() {
    if (!hasSufficientRewindHistory(_history.length)) return false;
    final _GameSnapshot snapshot = _history.first;
    _elapsed = snapshot.elapsed;
    _playerAngle = snapshot.playerAngle;
    _spoonHalves = snapshot.spoonHalves;
    _scoreBonus = snapshot.scoreBonus;
    _cleanPasses = snapshot.cleanPasses;
    _resonance = snapshot.resonance;
    _spawnTimer = snapshot.spawnTimer;
    _orbSpawnTimer = snapshot.orbSpawnTimer;
    _abilityCooldownRemaining = snapshot.abilityCooldownRemaining;
    _powerImmunityUntil = snapshot.powerImmunityUntil;
    _damageGraceUntil = snapshot.damageGraceUntil;
    _pressureReliefUntil = snapshot.pressureReliefUntil;
    _lastGap = snapshot.lastGap;
    _sequenceIndex = snapshot.sequenceIndex;

    restoreSnapshotList<ObstacleRing, _RingSnapshot>(
      target: _rings,
      snapshots: snapshot.rings,
      restore: (_RingSnapshot saved) {
        final ObstacleRing ring = ObstacleRing(
          radius: saved.radius,
          thickness: saved.thickness,
          gapCenters: List<double>.from(saved.gapCenters),
          gapWidth: saved.gapWidth,
          inwardSpeed: saved.inwardSpeed,
          rotationSpeed: saved.rotationSpeed,
          preview: saved.preview,
        );
        ring.previousRadius = saved.previousRadius;
        ring.checkedCollision = saved.checkedCollision;
        ring.resolved = saved.resolved;
        return ring;
      },
    );
    restoreSnapshotList<SpoonOrb, _OrbSnapshot>(
      target: _spoonOrbs,
      snapshots: snapshot.orbs,
      restore: (_OrbSnapshot saved) {
        final SpoonOrb orb = SpoonOrb(
          radius: saved.radius,
          angle: saved.angle,
          inwardSpeed: saved.inwardSpeed,
          angularSpeed: saved.angularSpeed,
        );
        orb.resolved = saved.resolved;
        return orb;
      },
    );
    for (final ObstacleRing ring in _rings) {
      if (!ring.checkedCollision &&
          sweptRingTouchesPlayer(
            previousRadius: ring.previousRadius,
            currentRadius: ring.radius,
            ringThickness: ring.thickness,
            playerRadius: _playerRadius,
            playerRadialHalfSize: 12,
          )) {
        ring.previousRadius = ring.radius;
      }
    }
    _history.clear();
    _rewindFeedbackUntil = _elapsed + .55;
    _emitHud(force: true);
    return true;
  }

  void _emitHud({bool force = false}) {
    if (!force && _hudTimer < .08) return;
    _hudTimer = 0;
    onHudChanged(
      HudSnapshot(
        seconds: _elapsed,
        score: score,
        stage: _stage,
        abilityCharge: profile.cooldown == 0
            ? 1
            : 1 - (_abilityCooldownRemaining / profile.cooldown),
        resonance: _resonance,
        spoonHalves: _spoonHalves,
        maxSpoonHalves: profile.maxSpoonHalves,
        cleanPasses: _cleanPasses,
        flowMultiplier: flowMultiplier(_cleanPasses),
        breathing: _isBreathing,
        recovering: _elapsed < _orbRecoveryUntil,
        state: _state,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    final Offset center = Offset(size.x / 2, size.y / 2);
    final Rect fullRect = Offset.zero & Size(size.x, size.y);
    final Paint background = Paint()
      ..shader = RadialGradient(
        colors: <Color>[Color(0xFF17182B), Color(0xFF070811)],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, background);

    super.render(canvas);

    final Offset shakeOffset = _cameraShakeOffset();
    canvas.save();
    canvas.translate(shakeOffset.dx, shakeOffset.dy);

    _drawGrid(canvas, center);
    _drawCore(canvas, center);
    _drawRewindFeedback(canvas, center);
    _drawPreview(canvas, center);
    for (final ObstacleRing ring in _rings) {
      _drawRing(canvas, center, ring);
    }
    for (final SpoonOrb orb in _spoonOrbs) {
      _drawSpoonOrb(canvas, center, orb);
    }
    _drawPlayer(canvas, center);

    if (_elapsed < _hitFlashUntil) {
      final double flashT = ((_hitFlashUntil - _elapsed) / .22).clamp(0.0, 1.0);
      canvas.drawRect(
        fullRect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: flashT * .10),
      );
    }
    canvas.restore();
  }

  Offset _cameraShakeOffset() {
    if (_elapsed >= _shakeUntil) {
      return Offset.zero;
    }
    final double progress = ((_shakeUntil - _elapsed) / .38).clamp(0.0, 1.0);
    final double intensity = _shakeStrength * progress;
    return Offset(
      (_random.nextDouble() - .5) * intensity,
      (_random.nextDouble() - .5) * intensity,
    );
  }

  void _drawGrid(Canvas canvas, Offset center) {
    final Paint paint = Paint()
      ..color = neuroType.color.withValues(alpha: .10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int index = 1; index <= 5; index++) {
      canvas.drawCircle(center, _playerRadius * index / 2, paint);
    }
    for (int index = 0; index < 6; index++) {
      final double angle = index * math.pi / 3;
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * _outerSpawnRadius,
        paint,
      );
    }
  }

  void _drawCore(Canvas canvas, Offset center) {
    final double charge = profile.cooldown == 0
        ? 1
        : 1 - (_abilityCooldownRemaining / profile.cooldown).clamp(0.0, 1.0);
    final bool ready = charge >= .999 && _abilityHasEffect;
    final double pulseAmplitude = settings.reducedFlashes ? .015 : .045;
    final double pulse = ready
        ? .5 + .5 * math.sin(_elapsed * math.pi * 1.35)
        : 0;
    final double activationExpansion = _elapsed < _abilityFeedbackUntil
        ? ((_abilityFeedbackUntil - _elapsed) / .42).clamp(0.0, 1.0) * .14
        : 0;
    final double radius =
        _playerRadius *
        .45 *
        (1 + pulse * pulseAmplitude + activationExpansion);
    final Color coreColor = ready
        ? Color.lerp(neuroType.color, const Color(0xFFFFFFFF), .34)!
        : neuroType.color;
    if (ready) {
      canvas.drawCircle(
        center,
        radius + 13 + pulse * 3,
        Paint()
          ..color = coreColor.withValues(
            alpha: settings.reducedFlashes ? .10 : .12 + pulse * .08,
          ),
      );
    }
    final Paint fill = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          coreColor.withValues(alpha: ready ? .58 : .42),
          neuroType.color.withValues(alpha: .10),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = coreColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 7),
      -math.pi / 2,
      math.pi * 2 * charge,
      false,
      Paint()
        ..color = ready ? coreColor : neuroType.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4,
    );
    _drawPowerIcon(canvas, center, radius, ready);
  }

  void _drawPowerIcon(Canvas canvas, Offset center, double radius, bool ready) {
    final ui.Image? icon = _powerIcon;
    if (icon == null) return;

    final bool cooldownFull =
        profile.cooldown == 0 || _abilityCooldownRemaining <= 0;
    final double activationScale = _elapsed < _abilityFeedbackUntil
        ? ((_abilityFeedbackUntil - _elapsed) / .42).clamp(0.0, 1.0) * .08
        : 0;
    final double iconSide =
        radius * (ready ? 1.30 : 1.22) * (1 + activationScale);
    final double alpha = ready
        ? 1
        : cooldownFull && !_abilityHasEffect
        ? .52
        : .74;
    final Rect destination = Rect.fromCenter(
      center: center,
      width: iconSide,
      height: iconSide,
    );
    final Rect source = Rect.fromLTWH(
      0,
      0,
      icon.width.toDouble(),
      icon.height.toDouble(),
    );
    if (alpha < 1) {
      canvas.saveLayer(
        destination,
        Paint()..color = Color(0xFFFFFFFF).withValues(alpha: alpha),
      );
    }
    canvas.drawImageRect(
      icon,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
    if (alpha < 1) {
      canvas.restore();
    }
  }

  void _drawRewindFeedback(Canvas canvas, Offset center) {
    if (_elapsed >= _rewindFeedbackUntil) return;
    final double progress =
        1 - ((_rewindFeedbackUntil - _elapsed) / .55).clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      _playerRadius * (.55 + progress * 1.9),
      Paint()
        ..color = const Color(
          0xFFFFD166,
        ).withValues(alpha: (1 - progress) * .36)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * (1 - progress) + 1,
    );
  }

  void _drawPreview(Canvas canvas, Offset center) {
    if (neuroType != NeuroType.tea && neuroType != NeuroType.tag) return;
    final ObstacleRing? previewRing = _rings
        .where((ObstacleRing ring) => ring.radius > _playerRadius)
        .firstOrNull;
    if (previewRing == null) return;
    final double gap = previewRing.gapCenters.first;
    final Paint paint = Paint()
      ..color = neuroType.color.withValues(
        alpha: neuroType == NeuroType.tag ? .28 : .55,
      )
      ..strokeWidth = neuroType == NeuroType.tag ? 2 : 3;
    canvas.drawLine(
      center + Offset(math.cos(gap), math.sin(gap)) * (_playerRadius * .55),
      center + Offset(math.cos(gap), math.sin(gap)) * (previewRing.radius - 10),
      paint,
    );
  }

  void _drawRing(Canvas canvas, Offset center, ObstacleRing ring) {
    const int slices = 96;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = ring.thickness
      ..color = _ringColor(ring);
    final Rect rect = Rect.fromCircle(center: center, radius: ring.radius);
    final double slice = math.pi * 2 / slices;
    for (int index = 0; index < slices; index++) {
      final double angle = index * slice;
      if (!ring.isAngleSafe(angle + slice / 2)) {
        canvas.drawArc(rect, angle, slice * 1.08, false, paint);
      }
    }
  }

  Color _ringColor(ObstacleRing ring) {
    final double distance = (ring.radius - _playerRadius).abs();
    final double proximity = (1 - distance / 240).clamp(0.0, 1.0).toDouble();
    final double alpha = settings.reducedFlashes ? .72 : .55 + proximity * .4;
    if (_stage == 'fracture') {
      return Color.lerp(
        neuroType.color,
        const Color(0xFFFF5F7A),
        .35,
      )!.withValues(alpha: alpha);
    }
    return neuroType.color.withValues(alpha: alpha);
  }

  void _drawSpoonOrb(Canvas canvas, Offset center, SpoonOrb orb) {
    final Offset position =
        center + Offset(math.cos(orb.angle), math.sin(orb.angle)) * orb.radius;
    final double pulse = settings.reducedFlashes
        ? 1
        : .5 + .5 * math.sin(_elapsed * 5.5);
    final double haloRadius = 14 + pulse * 5;
    canvas.drawCircle(
      position,
      haloRadius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFFD45C).withValues(alpha: .38),
            const Color(0xFFFFD45C).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: position, radius: haloRadius)),
    );
    canvas.drawCircle(position, 8, Paint()..color = const Color(0xFFFFD45C));
    canvas.drawCircle(position, 3, Paint()..color = const Color(0xFFFFFFFF));
  }

  void _drawPlayer(Canvas canvas, Offset center) {
    final Offset position =
        center +
        Offset(math.cos(_playerAngle), math.sin(_playerAngle)) * _playerRadius;
    final bool powerProtected = _elapsed < _powerImmunityUntil;
    final bool damageGrace = _elapsed < _damageGraceUntil;
    final bool flashing = _elapsed < _hitFlashUntil;
    final Color playerColor = powerProtected
        ? Color.lerp(neuroType.color, const Color(0xFFFFFFFF), .45)!
        : flashing
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFB58CFF);
    canvas.drawCircle(
      position,
      powerProtected ? 18 : 13,
      Paint()
        ..color = playerColor.withValues(alpha: powerProtected ? .28 : .10),
    );
    canvas.drawCircle(
      position,
      11,
      Paint()
        ..color = playerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      position,
      3.5,
      Paint()..color = playerColor.withValues(alpha: damageGrace ? .30 : .65),
    );
  }
}

class _GameSnapshot {
  const _GameSnapshot({
    required this.elapsed,
    required this.playerAngle,
    required this.spoonHalves,
    required this.scoreBonus,
    required this.cleanPasses,
    required this.resonance,
    required this.spawnTimer,
    required this.orbSpawnTimer,
    required this.abilityCooldownRemaining,
    required this.powerImmunityUntil,
    required this.damageGraceUntil,
    required this.pressureReliefUntil,
    required this.lastGap,
    required this.sequenceIndex,
    required this.rings,
    required this.orbs,
  });

  final double elapsed;
  final double playerAngle;
  final int spoonHalves;
  final int scoreBonus;
  final int cleanPasses;
  final double resonance;
  final double spawnTimer;
  final double orbSpawnTimer;
  final double abilityCooldownRemaining;
  final double powerImmunityUntil;
  final double damageGraceUntil;
  final double pressureReliefUntil;
  final double lastGap;
  final int sequenceIndex;
  final List<_RingSnapshot> rings;
  final List<_OrbSnapshot> orbs;
}

class _RingSnapshot {
  const _RingSnapshot({
    required this.radius,
    required this.previousRadius,
    required this.thickness,
    required this.gapCenters,
    required this.gapWidth,
    required this.inwardSpeed,
    required this.rotationSpeed,
    required this.preview,
    required this.checkedCollision,
    required this.resolved,
  });

  final double radius;
  final double previousRadius;
  final double thickness;
  final List<double> gapCenters;
  final double gapWidth;
  final double inwardSpeed;
  final double rotationSpeed;
  final bool preview;
  final bool checkedCollision;
  final bool resolved;
}

class _OrbSnapshot {
  const _OrbSnapshot({
    required this.radius,
    required this.angle,
    required this.inwardSpeed,
    required this.angularSpeed,
    required this.resolved,
  });

  final double radius;
  final double angle;
  final double inwardSpeed;
  final double angularSpeed;
  final bool resolved;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
