import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/user_progress.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (_) {
      // Graceful fallback if SharedPreferences fails to open
    }
  }

  // Theme & Accessibility
  static String getThemeMode() {
    return _prefs?.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  static Future<bool> setThemeMode(String mode) async {
    return (await _prefs?.setString(AppConstants.keyThemeMode, mode)) ?? false;
  }

  static bool getHighContrast() {
    return _prefs?.getBool(AppConstants.keyHighContrast) ?? false;
  }

  static Future<bool> setHighContrast(bool value) async {
    return (await _prefs?.setBool(AppConstants.keyHighContrast, value)) ?? false;
  }

  static double getTextScale() {
    return _prefs?.getDouble(AppConstants.keyTextScale) ?? 1.0;
  }

  static Future<bool> setTextScale(double scale) async {
    return (await _prefs?.setDouble(AppConstants.keyTextScale, scale)) ?? false;
  }

  static bool getHapticsEnabled() {
    return _prefs?.getBool(AppConstants.keyHapticsEnabled) ?? true;
  }

  static Future<bool> setHapticsEnabled(bool enabled) async {
    return (await _prefs?.setBool(AppConstants.keyHapticsEnabled, enabled)) ?? false;
  }

  static bool getSoundEffectsEnabled() {
    return _prefs?.getBool('gestura_sound_effects') ?? true;
  }

  static Future<bool> setSoundEffectsEnabled(bool enabled) async {
    return (await _prefs?.setBool('gestura_sound_effects', enabled)) ?? false;
  }

  static bool getReduceMotion() {
    return _prefs?.getBool('gestura_reduce_motion') ?? false;
  }

  static Future<bool> setReduceMotion(bool value) async {
    return (await _prefs?.setBool('gestura_reduce_motion', value)) ?? false;
  }

  static bool getWarmFilter() {
    return _prefs?.getBool('gestura_warm_filter') ?? false;
  }

  static Future<bool> setWarmFilter(bool value) async {
    return (await _prefs?.setBool('gestura_warm_filter', value)) ?? false;
  }

  static bool getAutoNarration() {
    return _prefs?.getBool('gestura_auto_narration') ?? false;
  }

  static Future<bool> setAutoNarration(bool value) async {
    return (await _prefs?.setBool('gestura_auto_narration', value)) ?? false;
  }

  static double getSpeechRate() {
    return _prefs?.getDouble('gestura_speech_rate') ?? 0.48;
  }

  static Future<bool> setSpeechRate(double rate) async {
    return (await _prefs?.setDouble('gestura_speech_rate', rate)) ?? false;
  }

  static String? getLanguage() {
    return _prefs?.getString('gestura_language');
  }

  static Future<bool> setLanguage(String? langCode) async {
    if (langCode == null) {
      return (await _prefs?.remove('gestura_language')) ?? false;
    }
    return (await _prefs?.setString('gestura_language', langCode)) ?? false;
  }

  // Bookmarks (Gestures saved by user)

  static List<String> getBookmarks() {
    return _prefs?.getStringList(AppConstants.keyBookmarks) ?? [];
  }

  static Future<bool> toggleBookmark(String gestureId) async {
    final list = getBookmarks().toList();
    if (list.contains(gestureId)) {
      list.remove(gestureId);
    } else {
      list.add(gestureId);
    }
    return (await _prefs?.setStringList(AppConstants.keyBookmarks, list)) ?? false;
  }

  static bool isBookmarked(String gestureId) {
    return getBookmarks().contains(gestureId);
  }

  // Progress & Stats
  static UserProgress loadProgress() {
    final raw = _prefs?.getString(AppConstants.keyUserProgress);
    if (raw == null || raw.isEmpty) {
      return UserProgress.initial();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (_) {
      return UserProgress.initial();
    }
  }

  static Future<bool> saveProgress(UserProgress progress) async {
    final raw = jsonEncode(progress.toJson());
    return (await _prefs?.setString(AppConstants.keyUserProgress, raw)) ?? false;
  }

  static Future<bool> clearAll() async {
    return (await _prefs?.clear()) ?? false;
  }
}

