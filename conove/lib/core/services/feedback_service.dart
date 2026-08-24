import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class FeedbackService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static void lightClick() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.selectionClick();
    }
  }

  static void success() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.mediumImpact();
    }
    _playSound('audio/sfx_correct.mp3');
  }

  static void error() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.heavyImpact();
    }
    _playSound('audio/sfx_incorrect.mp3');
  }

  static void complete() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.mediumImpact();
    }
    _playSound('audio/sfx_complete.mp3');
  }

  static void neutral() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.selectionClick();
    }
    _playSound('audio/sfx_neutral.mp3');
  }

  static void bookmark() => neutral();

  static void tabPop() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.selectionClick();
    }
    _playSound('audio/sfx_tab_pop.mp3');
  }

  static void levelUp() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.heavyImpact();
    }
    _playSound('audio/sfx_levelup.mp3');
  }

  static void tick() {
    _playSound('audio/sfx_tick.mp3');
  }

  static Future<void> _playSound(String assetPath) async {
    if (!StorageService.getSoundEffectsEnabled()) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath), volume: 0.5);
    } catch (_) {
      // Graceful fallback if platform audio is disabled
    }
  }
}
