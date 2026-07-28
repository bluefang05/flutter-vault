import 'dart:collection';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../models/game_settings.dart';
import '../models/neuro_type.dart';
import 'game_math.dart';
import 'hud_snapshot.dart';
import 'models/obstacle_ring.dart';
import 'powers/neuro_power_profile.dart';

class NbndGame extends FlameGame {
  NbndGame({
    required this.neuroType,
    required this.settings,
    required this.onHudChanged,
    required this.onGameOver,
  }) : profile = NeuroPowerProfile.forType(neuroType) {
    _spoonHalves = profile.maxSpoonHalves;
  }

  final NeuroType neuroType;
  final GameSettings settings;
  final NeuroPowerProfile profile;
  final ValueChanged<HudSnapshot> onHudChanged;
  final ValueChanged<int> onGameOver;

  final math.Random _random = math.Random();
  final List<ObstacleRing> _rings = <ObstacleRing>[];
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
  double _invulnerableUntil = 0;
  double _resonance = 0;
  double _snapshotTimer = 0;
  double _lastGap = -math.pi / 2;
  double _hitFlashUntil = 0;
  double _shakeUntil = 0;
  double _shakeStrength = 0;
  double _pressureReliefUntil = 0;
  int _sequenceIndex = 0;
  int _cleanPasses = 0;
  int _scoreBonus = 0;
  late int _spoonHalves;
  bool _gameOverSent = false;

  double get _playerRadius => math.min(size.x, size.y) * .19;
  double get _playerHalfAngle => .24;
  double get _outerSpawnRadius => math.max(size.x, size.y) * .68;
  int get score => (_elapsed * 100).floor() + _scoreBonus;
  bool get canActivateAbility =>
      _state == GameRunState.running && _abilityCooldownRemaining <= 0;

  void start() {
    _state = GameRunState.running;
    _emitHud(force: true);
  }

  void restart() {
    _rings.clear();
    _history.clear();
    _state = GameRunState.running;
    _elapsed = 0;
    _spawnTimer = .75;
    _playerAngle = -math.pi / 2;
    _moveDirection = 0;
    _abilityCooldownRemaining = 0;
    _slowUntil = 0;
    _freezeRotationUntil = 0;
    _invulnerableUntil = 0;
    _resonance = 0;
    _lastGap = -math.pi / 2;
    _hitFlashUntil = 0;
    _shakeUntil = 0;
    _shakeStrength = 0;
    _pressureReliefUntil = 0;
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

  void activateAbility() {
    if (!canActivateAbility) {
      return;
    }

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
        _invulnerableUntil = _elapsed + .65;
        break;
      case NeuroType.toc:
        final List<ObstacleRing> candidates = _rings
            .where(
              (ObstacleRing ring) =>
                  !ring.resolved &&
                  ring.radius + ring.thickness / 2 >= _playerRadius - 18,
            )
            .toList(growable: false);
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
        _invulnerableUntil = _elapsed + .9;
        break;
      case NeuroType.anhedonia:
        _invulnerableUntil = _elapsed + 3.5;
        _shakeStrength = 3;
        _hitFlashUntil = _elapsed + .18;
        _triggerHitFeedback(false);
        break;
      case NeuroType.tag:
        _rewindOneSecond();
        break;
    }

    _abilityCooldownRemaining = profile.cooldown;
    _emitHud(force: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state != GameRunState.running || size.x <= 0 || size.y <= 0) {
      return;
    }

    final double practiceFactor = settings.practiceMode ? .72 : 1;
    final bool slowed = _elapsed < _slowUntil;
    final double worldScale = slowed ? .42 : 1;
    final double gameDt = dt * practiceFactor;
    final double worldDt = gameDt * worldScale;

    _elapsed += gameDt;
    _abilityCooldownRemaining = math.max(0, _abilityCooldownRemaining - gameDt);
    _playerAngle = normalizeAngle(
      _playerAngle + _moveDirection * profile.playerSpeed * gameDt,
    );

    _spawnTimer -= worldDt;
    if (_spawnTimer <= 0) {
      _spawnRing();
      _spawnTimer = _spawnInterval;
    }

    final bool freezeRotation = _elapsed < _freezeRotationUntil;
    for (final ObstacleRing ring in _rings) {
      ring.update(worldDt, freezeRotation: freezeRotation);
      _checkCollision(ring);
      _markResolved(ring);
    }
    _rings.removeWhere((ObstacleRing ring) => ring.resolved);

    _recordHistory(gameDt);
    _hudTimer += gameDt;
    _emitHud();
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

  String get _stage {
    if (_elapsed < 20) return 'PULSO';
    if (_elapsed < 45) return 'RESONANCIA';
    return 'FRACTURA';
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

  void _checkCollision(ObstacleRing ring) {
    if (ring.checkedCollision || ring.resolved) {
      return;
    }
    final double playerInner = _playerRadius - 12;
    final double playerOuter = _playerRadius + 12;
    final double ringInner = ring.radius - ring.thickness / 2;
    final double ringOuter = ring.radius + ring.thickness / 2;
    final bool radialOverlap =
        ringOuter >= playerInner && ringInner <= playerOuter;
    if (!radialOverlap) {
      return;
    }

    final bool crossed =
        ring.previousRadius >= playerInner && ring.radius <= playerOuter;
    if (!crossed) {
      return;
    }

    ring.checkedCollision = true;

    if (_elapsed < _invulnerableUntil) {
      _registerCleanPass(nearMiss: false);
      return;
    }

    final double effectiveGapWidth = math.max(
      0,
      ring.gapWidth - _playerHalfAngle * 2,
    );
    final bool safe = ring.gapCenters.any((double gap) {
      return angularDistance(_playerAngle, gap) <= effectiveGapWidth / 2;
    });
    if (safe) {
      final double nearestEdgeDistance = ring.gapCenters
          .map(
            (double gap) =>
                ((effectiveGapWidth / 2) - angularDistance(_playerAngle, gap))
                    .abs(),
          )
          .fold<double>(double.infinity, math.min);
      if (nearestEdgeDistance < .12) {
        _resonance = math.min(1, _resonance + .22);
      }
      final bool nearMiss = nearestEdgeDistance < .12;
      _registerCleanPass(nearMiss: nearMiss);
      return;
    }

    if (neuroType == NeuroType.tag &&
        _abilityCooldownRemaining <= 0 &&
        _history.isNotEmpty) {
      _rewindOneSecond();
      _abilityCooldownRemaining = profile.cooldown;
      _invulnerableUntil = _elapsed + .7;
      _emitHud(force: true);
      return;
    }

    final bool strongHit = _isStrongHit(ring);
    _applyHitDamage(strongHit ? 2 : 1);
    _triggerHitFeedback(strongHit);
    if (_spoonHalves > 0) return;

    _state = GameRunState.gameOver;
    _moveDirection = 0;
    _emitHud(force: true);
    if (!_gameOverSent) {
      _gameOverSent = true;
      onGameOver(score);
    }
  }

  bool _isStrongHit(ObstacleRing ring) {
    final double effectiveGapWidth = math.max(
      0,
      ring.gapWidth - _playerHalfAngle * 2,
    );
    final double nearestDistance = ring.gapCenters
        .map((double gap) => angularDistance(_playerAngle, gap))
        .fold<double>(double.infinity, math.min);
    return nearestDistance > (effectiveGapWidth / 2) - .06;
  }

  void _applyHitDamage(int halves) {
    _spoonHalves = math.max(0, _spoonHalves - halves);
    _cleanPasses = 0;
    _pressureReliefUntil = _elapsed + 4;
    _invulnerableUntil = _elapsed + .55;
    _moveDirection = 0;
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
        rings: _rings
            .map(
              (ObstacleRing ring) => _RingSnapshot(
                radius: ring.radius,
                centers: List<double>.from(ring.gapCenters),
              ),
            )
            .toList(growable: false),
      ),
    );
    while (_history.length > 12) {
      _history.removeFirst();
    }
  }

  void _rewindOneSecond() {
    if (_history.isEmpty) return;
    final _GameSnapshot snapshot = _history.first;
    _playerAngle = snapshot.playerAngle;
    final int count = math.min(_rings.length, snapshot.rings.length);
    for (int index = 0; index < count; index++) {
      _rings[index].radius = snapshot.rings[index].radius;
      _rings[index].previousRadius = snapshot.rings[index].radius;
      _rings[index].gapCenters
        ..clear()
        ..addAll(snapshot.rings[index].centers);
      _rings[index].checkedCollision = false;
    }
    _history.clear();
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
    _drawPreview(canvas, center);
    for (final ObstacleRing ring in _rings) {
      _drawRing(canvas, center, ring);
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
    final double radius = _playerRadius * .45;
    final double charge = profile.cooldown == 0
        ? 1
        : 1 - (_abilityCooldownRemaining / profile.cooldown).clamp(0.0, 1.0);
    final Paint fill = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          neuroType.color.withValues(alpha: .42),
          neuroType.color.withValues(alpha: .10),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = neuroType.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 7),
      -math.pi / 2,
      math.pi * 2 * charge,
      false,
      Paint()
        ..color = charge >= 1 ? const Color(0xFFFFFFFF) : neuroType.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      center,
      radius * .42,
      Paint()
        ..color = const Color(
          0xFFFFFFFF,
        ).withValues(alpha: charge >= 1 ? .9 : .3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      center.translate(0, -radius * .18),
      center.translate(0, radius * .22),
      Paint()
        ..color = const Color(
          0xFFFFFFFF,
        ).withValues(alpha: charge >= 1 ? .95 : .42)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
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
    if (_stage == 'FRACTURA') {
      return Color.lerp(
        neuroType.color,
        const Color(0xFFFF5F7A),
        .35,
      )!.withValues(alpha: alpha);
    }
    return neuroType.color.withValues(alpha: alpha);
  }

  void _drawPlayer(Canvas canvas, Offset center) {
    final Offset position =
        center +
        Offset(math.cos(_playerAngle), math.sin(_playerAngle)) * _playerRadius;
    final bool invulnerable = _elapsed < _invulnerableUntil;
    final bool flashing = _elapsed < _hitFlashUntil;
    final Color playerColor = flashing
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFB58CFF);
    canvas.drawCircle(
      position,
      invulnerable ? 17 : 13,
      Paint()..color = playerColor.withValues(alpha: invulnerable ? .25 : .10),
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
      Paint()..color = playerColor.withValues(alpha: .65),
    );
  }
}

class _GameSnapshot {
  const _GameSnapshot({
    required this.elapsed,
    required this.playerAngle,
    required this.rings,
  });

  final double elapsed;
  final double playerAngle;
  final List<_RingSnapshot> rings;
}

class _RingSnapshot {
  const _RingSnapshot({required this.radius, required this.centers});

  final double radius;
  final List<double> centers;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
