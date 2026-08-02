import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class SfxPlayer {
  SfxPlayer._();

  static final SfxPlayer instance = SfxPlayer._();
  static final AudioContext _musicAudioContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );
  static final AudioContext _effectAudioContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  final AudioPlayer _hurtPlayer = AudioPlayer(playerId: 'hurt_collision');
  final AudioPlayer _spoonPlayer = AudioPlayer(playerId: 'spoon_collect');
  final AudioPlayer _recordPlayer = AudioPlayer(playerId: 'new_record');
  final AudioPlayer _powerTapPlayer = AudioPlayer(playerId: 'power_tap');
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'game_music');
  double _requestedMusicRate = 1;
  double _appliedMusicRate = 1;
  bool _updatingMusicRate = false;

  Future<void> playGameMusic() async {
    await _ignoreAudioFailures(() async {
      await _musicPlayer.setAudioContext(_musicAudioContext);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setPlaybackRate(_requestedMusicRate);
      _appliedMusicRate = _requestedMusicRate;
      await _musicPlayer.play(
        AssetSource('audio/music/game_loop.mp3'),
        volume: .34,
      );
    });
  }

  Future<void> pauseGameMusic() => _ignoreAudioFailures(_musicPlayer.pause);

  Future<void> resumeGameMusic() => _ignoreAudioFailures(_musicPlayer.resume);

  Future<void> stopGameMusic() => _ignoreAudioFailures(_musicPlayer.stop);

  Future<void> setGameMusicRate(double rate) async {
    _requestedMusicRate = rate.clamp(.5, 1.5).toDouble();
    if (_updatingMusicRate) return;
    _updatingMusicRate = true;
    try {
      while ((_requestedMusicRate - _appliedMusicRate).abs() > .001) {
        final double target = _requestedMusicRate;
        await _ignoreAudioFailures(() => _musicPlayer.setPlaybackRate(target));
        _appliedMusicRate = target;
      }
    } finally {
      _updatingMusicRate = false;
    }
  }

  Future<void> playHurtCollision() async {
    await _playEffect(
      player: _hurtPlayer,
      source: 'audio/sfx/hurt_collision.mp3',
      volume: .9,
    );
  }

  Future<void> playSpoonCollected() async {
    await _playEffect(
      player: _spoonPlayer,
      source: 'audio/sfx/spoon_collect.mp3',
      volume: .82,
    );
  }

  Future<void> playNewRecord() async {
    await _playEffect(
      player: _recordPlayer,
      source: 'audio/sfx/new_record.mp3',
      volume: .9,
    );
  }

  Future<void> playPowerTap() async {
    await _playEffect(
      player: _powerTapPlayer,
      source: 'audio/sfx/power_tap.mp3',
      volume: .78,
    );
  }

  Future<void> _playEffect({
    required AudioPlayer player,
    required String source,
    required double volume,
  }) {
    return _ignoreAudioFailures(() async {
      await player.setAudioContext(_effectAudioContext);
      await player.stop();
      await player.play(
        AssetSource(source),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
    });
  }

  Future<void> _ignoreAudioFailures(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Audio should never block gameplay when a platform denies playback.
    }
  }
}
