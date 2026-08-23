import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;
  static final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier<bool>(false);
  static String? _currentSpeakingId;

  static ValueNotifier<String?> currentSpeakingIdNotifier = ValueNotifier<String?>(null);

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.48); // Natural, clear cadence for accessibility
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        isSpeakingNotifier.value = true;
      });

      _tts.setCompletionHandler(() {
        isSpeakingNotifier.value = false;
        currentSpeakingIdNotifier.value = null;
        _currentSpeakingId = null;
      });

      _tts.setCancelHandler(() {
        isSpeakingNotifier.value = false;
        currentSpeakingIdNotifier.value = null;
        _currentSpeakingId = null;
      });

      _tts.setErrorHandler((msg) {
        isSpeakingNotifier.value = false;
        currentSpeakingIdNotifier.value = null;
        _currentSpeakingId = null;
        if (kDebugMode) {
          print('TTS Error: $msg');
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('TTS Init failed: $e');
      }
    }
  }

  static Future<void> speak(String text, {String? gestureId}) async {
    await init();
    try {
      // If currently speaking this exact gesture, stop it (toggle)
      if (isSpeakingNotifier.value && _currentSpeakingId == gestureId && gestureId != null) {
        await stop();
        return;
      }

      await stop();
      _currentSpeakingId = gestureId;
      currentSpeakingIdNotifier.value = gestureId;
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('TTS Speak Error: $e');
      }
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
      isSpeakingNotifier.value = false;
      currentSpeakingIdNotifier.value = null;
      _currentSpeakingId = null;
    } catch (_) {}
  }

  static bool isSpeakingGesture(String? gestureId) {
    return isSpeakingNotifier.value && _currentSpeakingId == gestureId;
  }
}
